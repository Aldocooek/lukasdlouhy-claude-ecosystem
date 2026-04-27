# Sample Prompts Reference

The prompts used by these workflows, with annotations explaining the design choices.

---

## Design Principles

Every prompt in this CI integration follows four rules:

1. **Single deliverable.** The prompt requests exactly one thing: a JSON object
   with a fixed schema. No "first do X, then do Y" chaining.
2. **Structured output.** Prompts say "Return ONLY a JSON object" with the exact
   schema inline. This prevents prose wrapping and makes `jq` parsing reliable.
3. **No open-ended reasoning.** Prompts describe a bounded task. No "think deeply
   about all possible implications" which invites multi-step internal reasoning
   that burns turns and tokens.
4. **Explicit severity vocabulary.** Prompts define the allowed values for severity,
   category, and grade fields. This prevents free-form strings that break
   downstream filtering.

---

## PR Review Prompt

Used in: `claude-pr-review.yml`

```
Review the following PR diff. Identify: bugs (logic errors, null dereferences,
off-by-one), security issues (injection, hardcoded secrets, insecure defaults,
auth bypass), performance regressions (N+1 queries, unbounded loops, missing
indexes), and missing or inadequate tests. For security findings, apply a
red-team perspective as if you are a security-redteam agent. Return ONLY a
JSON object with this exact schema, no prose outside the JSON:
{
  "summary": "one sentence",
  "findings": [
    {
      "severity": "HIGH|MEDIUM|LOW|INFO",
      "category": "bug|security|performance|tests|style",
      "file": "path/to/file.ext",
      "line": 42,
      "title": "short title",
      "detail": "explanation and suggested fix"
    }
  ],
  "overall_grade": "PASS|WARN|FAIL",
  "high_count": 0,
  "medium_count": 0
}
```

### Why it is structured this way

- **"Return ONLY a JSON object ... no prose outside the JSON"** — without this,
  Claude often wraps the JSON in a markdown code fence or adds a preamble sentence.
  Both break `jq` parsing.
- **Schema is inline** — copying the schema into the prompt means Claude does not
  have to infer field names. Consistent field names are critical for the
  `high_count` check that fails the CI step.
- **"security-redteam perspective"** — framing security as a named persona/agent
  increases the depth and adversarial quality of security findings without
  requiring a separate API call.
- **Four categories, not open-ended** — asking for "any issues" produces
  inconsistent category strings. Enumerating bugs/security/performance/tests
  focuses the output and makes filtering by category reliable.

---

## Test Generation Prompt

Used in: `claude-test-gen.yml`

```
You are a test engineer. Given the source file below, generate a complete,
runnable test file. Follow the project's existing test patterns if detectable.
Include: unit tests for all exported functions/classes, edge cases, and error
paths. Return ONLY the test file content with no markdown fences or prose.
The test file should be saved alongside the source at the path you infer from
the project structure (e.g., src/foo.test.ts for src/foo.ts).

Source file path: <path>

Source content:
<content>
```

### Why it is structured this way

- **"Return ONLY the test file content"** — the output is written directly to a
  `.test.ts` / `_test.go` file. Any prose or markdown fences would produce a
  non-runnable file. This is the most critical constraint.
- **"Follow the project's existing test patterns if detectable"** — Claude will
  scan the source for import patterns (Jest vs Vitest vs pytest) and mirror them.
  Without this hint, Claude defaults to a generic pattern that may not match the
  runner in `package.json`.
- **Source file path is explicit** — Claude uses the path to infer the correct
  test file name and location, rather than guessing.
- **No "also check for X"** — the prompt lists three specific deliverables
  (exports, edge cases, error paths). Open-ended "be thorough" instructions
  produce verbose tests that often fail because they assume API behavior that
  does not match the actual source.

---

## Security Scan Prompt

Used in: `claude-security-scan.yml`

```
You are a senior application security engineer performing a full security audit.
Analyze the codebase snapshot below. Apply a red-team mindset. Check for:
hardcoded secrets/credentials, injection vulnerabilities (SQL, command, LDAP,
XPath), insecure deserialization, broken authentication/authorization, SSRF,
path traversal, insecure dependencies (flag any obviously outdated or vulnerable
package references), missing input validation, cryptographic weaknesses, insecure
direct object references, and infrastructure misconfigurations (Dockerfile,
Terraform, CI YAML). Return ONLY a JSON object matching this exact schema:
{
  "grade": "A|B|C|D|F",
  "executive_summary": "2-3 sentences",
  "critical_count": 0,
  "high_count": 0,
  "medium_count": 0,
  "low_count": 0,
  "findings": [...],
  "positive_observations": [...]
}
```

### Why it is structured this way

- **Named vulnerability categories** — listing SSRF, LDAP injection, insecure
  deserialization etc. by name activates Claude's training on those specific
  vulnerability classes rather than relying on generic "security issues" recall.
- **Grade field (A–F)** — the issue-opening logic uses `grade` as a simple
  threshold trigger. A string like "good" or "risky" would require fuzzy matching;
  a letter grade is deterministic.
- **`positive_observations` array** — including a positives field reduces
  false-positive bias. Without it, Claude tends to find something in every
  category to justify the audit. Asking for positives creates a more balanced
  output that developers trust more and are less likely to ignore.
- **"infrastructure misconfigurations (Dockerfile, Terraform, CI YAML)"** —
  explicitly calling out config file types ensures Claude does not skip
  `.yml` and `.tf` files, which are common blind spots in code-focused reviews.

---

## Docs Update Prompt

Used in: `claude-docs-update.yml`

```
You are a technical writer. You are given diffs of changed source files and
the current state of documentation files. Identify which documentation is now
stale or incomplete due to the source changes. Return ONLY a JSON object:
{
  "needs_update": true,
  "summary": "one sentence describing what changed",
  "doc_updates": [
    {
      "file": "README.md",
      "reason": "why this doc needs updating",
      "updated_content": "FULL new content for the file"
    }
  ]
}
```

### Why it is structured this way

- **`needs_update: true/false`** — the workflow checks this before writing any
  files. Without it, Claude might return empty `doc_updates` arrays when nothing
  needs changing, but the workflow would still create a branch and open a PR.
  The boolean short-circuits that path.
- **`updated_content: "FULL new content"`** — asking for full content rather than
  a diff is safer: applying a diff programmatically is fragile and diff format
  varies. Writing the full file is unambiguous and the git diff in the PR shows
  exactly what changed.
- **`reason` field** — including a reason per file helps reviewers understand
  what the bot changed and why, making human review faster and increasing trust
  in auto-generated docs PRs.
- **"You are a technical writer"** — role assignment improves tone consistency.
  Without it, Claude occasionally outputs developer-voice shorthand ("TODO: update
  this") rather than finished documentation prose.
