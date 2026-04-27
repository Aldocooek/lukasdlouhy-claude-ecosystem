# Peer Ecosystem Cherry-Picking & Collaboration

Welcome to the **Claude Code Ecosystem Protocol** — a framework for sharing, auditing, and collaboratively improving AI development workflows.

## What This Repo Is

A snapshot of Lukáš Dlouhý's `~/.claude/` configuration: rules, hooks, skills, expertise YAML, and scripts. Designed to be:
- **Audited** — review the code before adopting
- **Cherry-picked** — copy only what fits your stack
- **Shared** — fork this protocol, publish your own ecosystem
- **Evolved** — contribute improvements, suggest additions

This is not a monolithic framework. It's a peer protocol for code-sharing at the Claude Code harness level.

## How to Cherry-Pick

### 1. Clone to Temp & Audit

```bash
# Clone Filip's ecosystem (example)
git clone https://github.com/filipdopita-tech/claude-ecosystem-setup.git /tmp/filip-ecosystem
cd /tmp/filip-ecosystem

# Read COMPARISON.md, PEER_PROMPT.md, rules/, skills/ to understand philosophy
cat COMPARISON.md
ls -la rules/ skills/ hooks/

# Spot-check a few files for quality/security
head -20 rules/*.md
```

### 2. Cherry-Pick Specific Files

```bash
# Copy only what you want to ~/.claude/
cp /tmp/filip-ecosystem/rules/cost-discipline.md ~/.claude/rules/

# Or symlink if you trust the source and want to track upstream changes
ln -s /tmp/filip-ecosystem/skills/gsap-split ~/.claude/skills/
```

### 3. Integrate Into Your Harness

- Wire hooks into `~/.claude/settings.json` or `~/.claude/settings.local.json`
- Test skills/rules in isolation first (e.g., `@rule cost-discipline` in a prompt)
- If something breaks, delete the symlink/copy and revert

## How to Mirror Your Own Ecosystem

Want to publish your own `~/.claude/` ecosystem? Follow this checklist:

### Sanitization & Leak Scan

1. **Backup original** — `cp -r ~/.claude ~/.claude.backup`
2. **Remove secrets** — Delete or redact:
   - `.env`, `.env.*` files
   - `credentials.json`, `mcp-keys.env`, `master.env`
   - SSH keys (`id_rsa`, `id_ed25519`, `*.pem`, `*.key`)
   - API keys, tokens, Bearer strings in configs
   - Personal notes/diary in memory/ or sessions/
   - Project-specific cache, telemetry, logs
3. **Scan & verify** — Run the leak scanner:
   ```bash
   bash scripts/sanitize.sh
   ```
4. **Stage minimal set** — Copy only:
   - `rules/` (decision guardrails)
   - `hooks/` (Git/CI integrations)
   - `skills/` (reusable prompts/templates)
   - `expertise/` (domain YAML configs)
   - `scripts/` (utilities)
   - Documentation (`README.md`, `COLLABORATION.md`, etc.)
5. **Create repo** — Push to `<your-github>/claude-ecosystem-setup`
6. **Update this table** — Submit a PR adding your entry below

### Peer Ecosystems

| Peer | GitHub | Stack | Maturity | Notable Items | Added |
|------|--------|-------|----------|---------------|-------|
| **Filip Dopita** | [filipdopita-tech/claude-ecosystem-setup](https://github.com/filipdopita-tech/claude-ecosystem-setup) | multi-modal (code+design+finance), high-volume skill system | Mature (291 skills, 89/100) | Full skill registry, advanced hook system, cross-domain expertise | 2026-04-15 |
| **Lukáš Dlouhý** | [lukasdlouhy/claude-ecosystem-setup](https://github.com/lukasdlouhy/claude-ecosystem-setup) | video/animation, marketing/CRO, cost-aware routing | Growing (~75/100 after boost) | Cost-discipline rules, GSAP skill split, HyperFrames CLI, token budgets | 2026-04-26 |
| *(Your Name)* | `https://github.com/<you>/claude-ecosystem-setup` | *Your stack* | *Your maturity* | *Your top 3 items* | *Date* |

To add yourself:
1. Publish your ecosystem to GitHub
2. Open a PR against this repo with a new row
3. Include a brief description + link to your repo
4. Tag fellow peers for feedback

## PR & Issue Protocol

### Suggesting a New Peer

**Title:** `feat: add <peer-name> to peer table`

**Body:**
```markdown
## Ecosystem

- **GitHub**: https://github.com/<peer>/claude-ecosystem-setup
- **Stack**: [describe your focus]
- **Maturity**: [e.g., "Growing", "Mature"]
- **Notable items**: [top 3-5 things worth cherry-picking]

## Verification

- [ ] I have published a public repo following this protocol
- [ ] I have run `bash scripts/sanitize.sh` and confirmed no leaks
- [ ] I am comfortable with this entry being public
```

### Contributing Improvements

Found a bug? Have a better rule? Open an issue:

**Title:** `[rule-name] <short description>`
**Label:** `suggestion`, `bug`, or `improvement`

Example:
```markdown
Title: [cost-discipline] Add Haiku decision tree for web scraping

Current: rule assumes all web work is Sonnet.
Proposed: Decision tree based on data size + time sensitivity.
Alternative: Use this rule in your own ecosystem instead of ours.
```

## Attribution & Reciprocity

When you cherry-pick from a peer ecosystem:
- **Credit them** — mention in your README or CHANGELOG
- **Link back** — include the source repo URL
- **Share improvements** — if you enhance a rule/skill, consider PRing it back
- **Check COMPARISON.md** — understand their philosophy before wholesale adoption

## Questions?

- **How do I know if a rule is safe?** — Read the source, check the date updated, look for peer reviews in issues/PRs.
- **What if I disagree with a peer's approach?** — Fork it, modify, publish your variant. Diversity is the point.
- **Can I commercialize something from another ecosystem?** — Check the license (most are MIT). Attribution required.
- **How often do peers update?** — Varies. Pin to a git tag or branch if you symlink to avoid surprises.

## License Notes

All peer ecosystems should be MIT-licensed to preserve remix culture. See [LICENSE](./LICENSE).

---

**Last updated:** 2026-04-26

**Maintained by:** Lukáš Dlouhý ([dlouhyphoto@gmail.com](mailto:dlouhyphoto@gmail.com))
