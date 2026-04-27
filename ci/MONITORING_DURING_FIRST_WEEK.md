# Monitoring During First Week

Track these metrics and behaviors during the first week of Claude Code CI activation to measure ROI, cost, and quality.

## Daily Monitoring Checklist

### GitHub Actions Tab

Check daily (or more frequently if PRs are active):

1. Workflow run history
   - How many times did workflows run? (Expected: 1 per PR + 1 weekly scan)
   - Average run duration per workflow type
   - Success rate (% of runs that completed without error)

2. PR review quality
   - Did Claude catch real issues or bugs?
   - False positives (flagged non-issues)?
   - Tone and helpfulness of comments
   - Time to completion (2–5 minutes per PR)

3. Action logs for errors
   - Check each failed run's logs
   - Common failure modes: API errors, syntax parsing issues, timeouts
   - Note in COST_DIARY_TEMPLATE.md

### Anthropic API Console

Visit https://console.anthropic.com daily:

1. Token usage dashboard
   - Daily token count (input + output)
   - Running total for the week
   - Cost per day and total weekly cost

2. Cost vs. estimate
   - Did PR review actually cost $0.10–0.50?
   - Did security scan cost $0.50–1.00?
   - If higher, note why (longer conversations, more code analyzed, etc.)

3. Rate limits
   - Are you hitting any rate limits? (Should not on starter tier)
   - API latency (should be <2 sec per request)

### Repository Metrics

1. PR activity
   - Number of PRs merged this week
   - Average review time with Claude enabled vs. baseline
   - Did Claude accelerate or slow down code review?

2. Test coverage (if test-gen enabled)
   - Did generated tests increase coverage %?
   - Were generated tests actually used or modified?

3. Documentation (if docs workflow enabled)
   - Did Claude's edits to README improve clarity?
   - Were changes committed or ignored?

## Failure Modes to Watch

Monitor for these common issues during first week:

### False Positive Security Flags

Claude may over-flag benign code as security risks:
- Example: flagging `eval()` when used safely
- Example: warning about hardcoded URLs in configs
- Example: alerting on test credentials that are clearly for testing

**Action:** Log these in COST_DIARY_TEMPLATE.md. After 1 week, if >10% of flags are false positives, consider:
- Adjusting the security scanning prompt
- Adding `.claude-ignore` comments to known false-positive patterns
- Disabling security scan and using only PR review

### Runaway Test Generation

If test-gen enabled, Claude may generate excessive tests:
- Example: 100+ new test cases for a simple function
- Example: generated tests that don't compile or fail immediately

**Action:** If this happens, immediately disable test-gen:
```bash
gh workflow disable claude-test-gen.yml
```
Review generated tests before committing. Adjust prompt to be more selective.

### Out-of-Sync Generated Docs

If docs workflow enabled, Claude may update README with incorrect or outdated info:
- Example: version numbers don't match actual code
- Example: examples that don't match current API

**Action:** Review auto-generated doc PRs before merging. Consider disabling auto-commit and requiring manual approval first.

### High-Cost Runaway Conversation

A single PR review might trigger multiple back-and-forth turns, causing cost to spike:
- Example: complex PR triggers 10+ turns instead of expected 3–5
- Example: large file causes token count to explode

**Action:** If any single PR costs >$3, pause immediately:
```bash
gh workflow disable claude-pr-review.yml
```
Review workflow logs. Investigate:
- Did PR have exceptionally large file?
- Did review loop get stuck on one issue?
- Reduce `max-turns` from 5 to 3 and re-enable

### API Errors or Throttling

Anthropic API may rate-limit or error on high concurrency:
- Example: "rate limit exceeded" in workflow logs
- Example: "429 Too Many Requests"

**Action:** If rate-limit occurs, space out workflow runs:
- Disable auto-run on every PR; enable only on main branch
- Add 5–10 minute delay between workflow triggers

## Critical Alert Thresholds

Stop and investigate immediately if:

| Metric | Threshold | Action |
|--------|-----------|--------|
| Single PR cost | >$3 | Disable workflow, debug |
| Weekly cost | >$20 | Review frequency, reduce turns |
| False positive rate | >20% | Adjust prompts, consider disabling |
| Workflow failure rate | >10% | Check logs, contact Anthropic support |
| API errors | >3 in a day | Space out runs, check account limits |

## First Week Metrics Summary

At end of week 1, capture:

1. **Cost metrics**
   - Total spend (actual from Anthropic dashboard)
   - Cost per PR
   - Cost per security scan
   - Cost per test-gen run

2. **Quality metrics**
   - True positives: issues Claude caught that were real
   - False positives: non-issues Claude flagged
   - Signal-to-noise ratio (true positives / total flags)
   - Developer satisfaction (subjective: helpful vs. noisy?)

3. **Efficiency metrics**
   - Average time from PR open to review comment
   - Time saved vs. manual code review (estimate)
   - Number of workflow runs
   - Number of errors or failures

4. **Cost-benefit ratio**
   - Total cost for week
   - Estimated value (hours saved × hourly rate)
   - Break-even threshold: is this worth the cost?

Example summary:

```
Week 1 Summary:
- 5 PRs reviewed, 1 security scan, 0 test-gen runs
- Total cost: $4.27
- True positives: 8 real issues caught
- False positives: 2 (20% false positive rate)
- Average time to review: 3 min
- Time saved estimate: ~2 hours of manual review
- ROI: Positive if your time is worth >$2/hour
```

## Recommended Monitoring Schedule

- **Daily:** Check GitHub Actions > last 24 hours of runs, check Anthropic console for daily cost
- **3x/week:** Review PR comments for quality, check for errors or failures
- **End of week:** Aggregate metrics into COST_DIARY_TEMPLATE.md, calculate ROI

## What to Do After First Week

Based on first-week observations:

- **Cost is low, quality is high:** Keep all enabled workflows, consider enabling test-gen
- **Cost is high, quality is good:** Reduce frequency (e.g., PR review only on main branch)
- **Cost is high, quality is poor:** Disable workflows, adjust prompts, try again
- **Quality is mixed:** Identify specific failure modes, fix prompts, continue monitoring

See `ci/ROLLBACK.md` for how to disable workflows if needed.
