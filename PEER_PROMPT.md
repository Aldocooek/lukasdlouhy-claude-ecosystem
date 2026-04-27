# Peer Ecosystem Invitation

Copy and paste the section between START and END below to invite a peer to adopt your ecosystem.

---

## START COPY HERE

Hi! I thought you might be interested in a new project: **peer Claude Code ecosystem sharing**.

I've published my `~/.claude/` configuration (rules, hooks, skills, expertise) to a public repo. You can cherry-pick whatever fits your stack, no strings attached.

**Two repos to check out:**

1. **Filip Dopita's** — [filipdopita-tech/claude-ecosystem-setup](https://github.com/filipdopita-tech/claude-ecosystem-setup)  
   Mature ecosystem (291 skills, 18 rules, 41 hooks). Covers code, design, finance.

2. **My ecosystem** — [lukasdlouhy/claude-ecosystem-setup](https://github.com/lukasdlouhy/claude-ecosystem-setup)  
   Growing ecosystem (~16 skills, 7 rules, 5 hooks). Focused on video/animation, marketing/CRO, cost-aware AI routing.

**Why it matters:**

Claude Code harness configs are rarely shared. These repos make that possible. You can:
- Copy specific rules/skills without adopting the whole system
- See how others organize expertise YAML and hooks
- Contribute improvements back to peers
- Build your own ecosystem and join the peer table

**How to get started:**

```bash
# Audit a peer ecosystem
git clone https://github.com/lukasdlouhy/claude-ecosystem-setup.git /tmp/
cd /tmp && cat README.md COLLABORATION.md

# Cherry-pick a rule or skill
cp /tmp/rules/cost-discipline.md ~/.claude/rules/

# Or read the full protocol
cat /tmp/COLLABORATION.md
```

**Questions?**

- Want to know what's in each repo? Read `COMPARISON.md`
- How to sanitize & publish your own? See `COLLABORATION.md`
- What are the top things to steal? Check the README "What's Worth Stealing" section

Looking forward to seeing your ecosystem. No pressure — this is just about making AI development workflows more transparent and shareable.

— Lukáš

P.S. Both repos are MIT-licensed. Fork, remix, improve freely.

---

## Sanitization & Leak Scan Checklist

Before sending this message, verify:

- [ ] Your `~/.claude/` is free of `.env`, API keys, credentials.json
- [ ] All symlinks in your published repo point to public content only
- [ ] You've run `bash scripts/sanitize.sh` and it reports clean
- [ ] Personal notes, memory/, sessions/, cache/ are excluded in `.gitignore`
- [ ] GitHub repo is public and MIT-licensed
- [ ] README.md, COLLABORATION.md, and at least 3 shareable skills/rules are included
- [ ] You've read and agree with the peer protocol in COLLABORATION.md

## END COPY HERE

---

**Notes for the sender (Lukáš):**

- Customize the stack focus and repo links to match your audience
- Adjust tone: more formal for colleagues, casual for friends
- If sending to multiple peers, consider a group message instead
- Allow ~1 week for them to respond; some may not be interested
- If they publish their ecosystem, add them to the peer table in COLLABORATION.md

**Timing:** Send after you've published your repo and confirmed all files are clean.

Last updated: 2026-04-26
