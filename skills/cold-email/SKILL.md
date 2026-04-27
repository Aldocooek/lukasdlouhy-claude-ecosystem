---
name: cold-email
description: Outbound B2B cold email writing — subject lines, openers, value props, CTAs, follow-up cadence, and deliverability basics.
allowed-tools: Read, Write, Edit
last-updated: 2026-04-27
version: 1.0.0
triggers:
  - cold email
  - outbound
  - B2B email
  - outreach sequence
---

# Cold Email — B2B Outbound Writing

## Subject Line Patterns

The subject line earns the open. Nothing else.

Patterns that work:
- **Specificity over cleverness.** "3 customers like you reduced churn by 18%" beats "Quick question".
- **Name the pain or the outcome.** "Your onboarding drop-off" or "Idea for [Company] retention".
- **Short wins.** 3–6 words, no punctuation at the end, sentence case only.

Avoid: "Just following up", "Touching base", "Checking in", ALL CAPS, excessive punctuation.

## Opener — Relevance Hook, Not Flattery

First sentence must prove you did 5 minutes of research. It is not "I love what you're doing at [Company]."

Good openers:
- Trigger-based: "Saw you just raised your Series A — congrats. Scaling sales ops without bloating headcount is usually the next puzzle."
- Pain-based: "Companies in [vertical] with [X employees] typically hit a wall with [specific problem] around the [Y] stage."
- Mutual: "We work with [similar company] — they had the same [problem] before switching."

One sentence only. Transition immediately to value.

## One-Line Value Prop

State what you do and who it is for in one sentence. No buzzwords.

Template: "We help [ICP] [achieve outcome] without [common tradeoff]."

Example: "We help growth-stage SaaS teams cut time-to-close by 30% without adding headcount."

Do not explain HOW yet. The email earns a reply, not a sale.

## Single CTA

One ask per email. The ask should be low-friction.

Good CTAs:
- "Worth a 20-minute call this week?" (yes/no, easy to answer)
- "Relevant to share a 2-minute Loom?" (async, lower commitment)
- "Can I send you a one-pager?" (micro-commitment)

Bad CTAs:
- "Let me know if you want to schedule a call, learn more, or have any questions." (pick one)
- "Click here to book a 45-minute discovery call." (too much commitment too early)

## Follow-Up Cadence

Max 4 touches total. Stop if no reply.

| Touch | Timing | Angle |
|-------|--------|-------|
| 1 | Day 0 | Main email |
| 2 | Day 3–5 | Add one new piece of value (case study, insight, stat) |
| 3 | Day 8–12 | Short "still relevant?" bump — 2 sentences max |
| 4 | Day 18–21 | Break-up email: "I'll stop reaching out — leaving this here in case timing changes." |

Never apologize for following up. Never say "just" or "hope this finds you well."

## Deliverability Basics

Getting to inbox is a prerequisite. Infrastructure matters before copy does.

- **Plain text.** No HTML formatting, no images, no tracking pixels in early sequences. Gmail and Outlook treat heavy HTML as marketing, not personal email.
- **Warm the domain.** New domains need 4–6 weeks of warmup (tools: Instantly, Mailreach, Lemwarm). Never cold-blast from a fresh domain.
- **Spam triggers to cut:** "free", "guarantee", "no obligation", "click here", "$$$", excessive caps, multiple exclamation marks.
- **Volume limits.** Cap at 30–50 sends/day per mailbox. Use multiple mailboxes for scale.
- **SPF + DKIM + DMARC.** Required. Verify at mail-tester.com before launching.
- **Signature.** Include full name, title, company, phone. No logos, no social icons — they flag HTML.
- **Unsubscribe.** Required in most jurisdictions (CAN-SPAM, GDPR). A plain-text "reply 'unsubscribe' to be removed" line is sufficient.

## Full Email Template

```
Subject: [Specific pain or outcome] at [Company]

[Relevance hook — 1 sentence proving research]

[One-line value prop — what you do and for whom]

[One proof point — stat, named customer, or outcome]

[Single low-friction CTA]

[First name]
[Title] at [Company]
[Phone]
```

## What Not to Do

- Do not start with "My name is..." — they can see who sent it.
- Do not use a wall of text. 5 sentences maximum for touch 1.
- Do not pitch features. Pitch outcomes.
- Do not personalize at scale with obvious mail-merge ("Hi {first_name},").
- Do not send without testing deliverability score first (mail-tester.com, score 9+/10).
