# Cost Diary: First Week of Claude Code CI

Use this template to log daily costs, observations, and ROI calculations for your first week of Claude Code CI activation.

## Instructions

1. Copy this file to your target repository: `cp ci/COST_DIARY_TEMPLATE.md <repo>/.claude/COST_DIARY.md`
2. Fill in one section per day (Days 1–7)
3. Check Anthropic dashboard daily (https://console.anthropic.com) for token count and cost
4. Log GitHub Actions activity from the Actions tab
5. At end of week, fill in "Weekly Summary" and calculate ROI

---

## Day 1

**Date:** _______________

**PRs reviewed by Claude:** ___

**Security scans run:** ___

**Test-gen runs:** ___

**Total workflow runs:** ___

**Cost (from Anthropic dashboard):** $___

**True positives caught:** ___
(Examples: actual bugs, security issues, real improvements)

**False positives:** ___
(Examples: non-issues flagged, benign patterns flagged as risks)

**Notes:**
```
(What went well? What was unexpected? Any errors?)
```

---

## Day 2

**Date:** _______________

**PRs reviewed by Claude:** ___

**Security scans run:** ___

**Test-gen runs:** ___

**Total workflow runs:** ___

**Cost (from Anthropic dashboard):** $___

**True positives caught:** ___

**False positives:** ___

**Notes:**
```
```

---

## Day 3

**Date:** _______________

**PRs reviewed by Claude:** ___

**Security scans run:** ___

**Test-gen runs:** ___

**Total workflow runs:** ___

**Cost (from Anthropic dashboard):** $___

**True positives caught:** ___

**False positives:** ___

**Notes:**
```
```

---

## Day 4

**Date:** _______________

**PRs reviewed by Claude:** ___

**Security scans run:** ___

**Test-gen runs:** ___

**Total workflow runs:** ___

**Cost (from Anthropic dashboard):** $___

**True positives caught:** ___

**False positives:** ___

**Notes:**
```
```

---

## Day 5

**Date:** _______________

**PRs reviewed by Claude:** ___

**Security scans run:** ___

**Test-gen runs:** ___

**Total workflow runs:** ___

**Cost (from Anthropic dashboard):** $___

**True positives caught:** ___

**False positives:** ___

**Notes:**
```
```

---

## Day 6

**Date:** _______________

**PRs reviewed by Claude:** ___

**Security scans run:** ___

**Test-gen runs:** ___

**Total workflow runs:** ___

**Cost (from Anthropic dashboard):** $___

**True positives caught:** ___

**False positives:** ___

**Notes:**
```
```

---

## Day 7

**Date:** _______________

**PRs reviewed by Claude:** ___

**Security scans run:** ___

**Test-gen runs:** ___

**Total workflow runs:** ___

**Cost (from Anthropic dashboard):** $___

**True positives caught:** ___

**False positives:** ___

**Notes:**
```
```

---

## Weekly Summary

### Cost Metrics

| Metric | Value |
|--------|-------|
| Total cost this week | $_____ |
| Cost per PR review | $_____ |
| Cost per security scan | $_____ |
| Cost per test-gen run | $_____ |
| Highest single run cost | $_____ |
| Lowest single run cost | $_____ |

### Quality Metrics

| Metric | Count |
|--------|-------|
| Total true positives | ____ |
| Total false positives | ____ |
| True positive rate | ___% |
| False positive rate | ___% |
| Average review time | __ min |
| Workflow failure rate | ___% |

### ROI Calculation

Estimate your return on investment:

```
Time saved from Claude reviews: ____ hours
Your hourly rate: $____/hour
Estimated value: $____

Total cost this week: $____

Net ROI: $____ (value - cost)
```

If negative, consider:
- Reducing workflow frequency (only on main branch, not all PRs)
- Reducing max-turns from 5 to 3
- Disabling expensive workflows (test-gen)
- Trying again in 2 weeks with larger codebase

### Decision

Based on this week's metrics, select one:

- [ ] **Continue with all workflows enabled:** Cost is low, quality is high
- [ ] **Continue with selective workflows:** Disable test-gen, keep PR review and security scan
- [ ] **Reduce frequency:** Enable only on main branch, not all PRs
- [ ] **Pause and investigate:** Cost or quality issues need fixing
- [ ] **Disable entirely:** Not worth the cost at this time

### Action Items for Next Week

List any changes to make in Week 2:

1. ___________________________________________
2. ___________________________________________
3. ___________________________________________

### Detailed Quality Assessment

**PR Review Feedback:**

Did Claude's PR reviews feel helpful, accurate, and well-scoped?

```
Example PR 1: [Helpful / Noisy / Inaccurate]
  - Claude caught: [issue/issue/non-issue]
  
Example PR 2: [Helpful / Noisy / Inaccurate]
  - Claude caught: [issue/issue/non-issue]
```

**False Positive Patterns:**

If you noticed recurring false positives, note them here:

```
Pattern: [e.g., "flags eval() even when safe"]
Frequency: [e.g., "2 times this week"]
Solution: [e.g., "add .claude-ignore comment", "adjust prompt", "disable this check"]
```

**Suggested Prompt Adjustments:**

If Claude's reviews need refinement, what would help?

```
Example: "Focus more on architectural issues, less on style"
Example: "Reduce false positives on dependency warnings"
Example: "More concise reviews (currently too verbose)"
```

### Next Steps

Based on this first week, select your plan for Week 2:

**Plan A: Scale Up**
- Keep all workflows enabled
- Add test-gen runs on demand
- Monitor costs daily
- Revisit in 2 weeks

**Plan B: Maintain**
- Keep PR review and security scan enabled
- Disable test-gen for now
- Review costs weekly instead of daily
- Revisit in 1 month

**Plan C: Optimize**
- Adjust prompts and cost caps based on observations
- Disable problematic workflows
- Reduce frequency (e.g., PR review only on main)
- Retry with tuned settings

**Plan D: Pause**
- Disable all workflows temporarily
- Investigate cost/quality issues
- Retry in 2 weeks after improvements
- Or abandon if not ROI-positive

---

## Appendix: Useful Commands

Check token usage from CLI (if available):

```bash
# Anthropic API usage (requires API access)
curl https://api.anthropic.com/v1/usage \
  -H "api-key: $ANTHROPIC_API_KEY"
```

Check GitHub workflow costs:

```bash
# List workflow runs and their duration
gh run list --repo "owner/repo-name" --limit 20

# View specific run details
gh run view <run-id> --repo "owner/repo-name"

# Export run history for analysis
gh run list --repo "owner/repo-name" --json name,status,durationMinutes,createdAt
```

