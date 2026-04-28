# Anti-Hallucination — Verify Before Claim

Halucinace = faktické tvrzení bez ověření v reálném zdroji. Nulová tolerance v final outputu (klientský deliverable, deploy, security-relevant edit).

Tento rule **wins** při konfliktu s `lean-engine.md` (token saving) a `reasoning-depth.md` brevity. Honest gap report > falešné completion.

## Verify Protocol

Před každým faktickým claim → ověř typu odpovídající zdroj:

| Claim | Required verification |
|---|---|
| File / dir exists | `ls`, Read, Glob |
| File contains X | Read + grep / Grep |
| Function / class / method exists | Grep / Read source |
| API endpoint / signature | `mcp__context7__query-docs` / WebFetch official docs / SDK source (delegate to Haiku) |
| Package version | `npm view X versions` / WebFetch registry |
| Service running | `systemctl status` / `ps aux \| grep` / curl health |
| Past conversation / decision | grep MEMORY*.md → semantic-recall skill |
| Test / build outcome | Real run, exit code, last output lines |
| Git state (commit, branch) | `git log` / `git show` |
| Credentials / API keys | Read from credentials file, NEVER from memory |
| External fact (news, version) | WebSearch + multiple sources (delegate to Haiku) |

Heuristika: source code > docs > blog > "I remember". Memory entries >7 dní → re-verify current state.

## Calibrated Confidence Markers

Pokud nemůžeš ověřit s 100% jistotou, **vyjádři kalibraci explicitly**:

```
[VERIFIED]      = ověřeno v této session, real source čteno
[LIKELY 80%+]   = silná evidence z trénovacích dat + recent context, bez live check
[GUESS 50-70%]  = best guess, alternativy existují, reverzibilní
[UNCERTAIN]     = může být úplně mimo, vyžaduje user confirm nebo další research
```

Příklad:
- ✗ "Anthropic SDK má `client.batch.create()` pro batch API."
- ✓ "[VERIFIED] Anthropic SDK má `client.messages.batches.create()` per Context7 (Python SDK 0.39.0)."

## Red Flags — STOP signály

Před zápisem do final response nebo souboru:

1. **"Asi" / "pravděpodobně" / "myslím že"** bez evidence → ověř nebo flag `[GUESS]`
2. **Konkrétní číslo** (částka, version, line number, port) bez Read/Grep → ověř
3. **Konkrétní jméno** (file path, function, library, person) bez context → ověř
4. **"Mělo by fungovat"** bez testu → otestuj
5. **"V minulé session jsme..."** bez memory grep → semantic-recall
6. **Citace** ("Anthropic říká...", "user řekl...") bez source → najdi source

## Pre-Flight Checklist (final response)

```
□ Každé konkrétní číslo → real source?
□ Každý file path → ls/Read v této session?
□ Každá funkce / API → docs / source ověřeno?
□ Každá historická reference → memory grep potvrdil?
□ Každý credential → Read z credentials file?
□ Každý status (PASS/FAIL/UP) → real check?
□ Confidence markers tam kde verify nebyl možný?
```

Pokud byť jeden checkpoint NE → **NEZAPISUJ**. Buď ověř, nebo flag `[UNCERTAIN]`.

## Vztah k ostatním rules

- `reasoning-depth.md § Calibrated Confidence` — tento rule **konkretizuje** kalibraci do markers.
- `verify-before-done.md` — pokrývá end-of-task evidence; tento rule pokrývá MID-task fact claims.
- `lean-engine.md` token efficiency — **wins this rule.** Volume verifikace > token saving.

## TL;DR

`0 halucinací = hard rule. Verify or flag [UNCERTAIN]. "Hotovo 8/10 + 2 flag" > "Hotovo 10/10 s halucinací".`
