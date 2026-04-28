# Writing Sentence Craft — Prose Quality Rules

Aktivuj při: content / copy / IG carousel/reel / LinkedIn post / cold email / video script / landing page / brief.
Neaplikuj na: TodoWrite, tool output parsing, code comments, deploy logs, conversational responses.

6 sentence-level pravidel které doplňují `lean-engine.md` (kód) o pravidla pro prose.

## R1: Affirmative form

State what IS, not what isn't. Negace zpomaluje čtenáře.

- ✗ "Tohle není špatné řešení."
- ✓ "Tohle řešení funguje."

Skip když negace nese reálnou sémantiku (hard prohibition: "NIKDY nepushuj bez review").

## R2: Stress at sentence end

Nová / významná informace patří na konec věty. Čtenář si zapamatuje poslední slova.

- ✗ "INP 287ms má tato landing page po deploy."
- ✓ "Po deploy má tato landing page INP 287ms."

Aplikuj v: CTA, key metrics v carousel/reel hooks, risk flags.

## R3: Break long sentences

Cíl délky podle formátu:
- Marketing/sales/IG copy: **< 25 slov/věta**
- Technický dokument / brief: **< 40 slov/věta**

Věty > 30 slov split. Vary length (kombinace krátká + dlouhá = rytmus).

## R4: No excessive bullets

Bullets jsou pro multi-item content. Single sentence NEDÁVEJ do bullet.

- ✗ "Klíčový bod: • LCP 2.8s je nad target."
- ✓ "Klíčový bod: LCP 2.8s je nad target."

Fake "5 důvodů" / "10 kroků" listy kde položky nejsou paralelní = banned. Pokud každá bullet má vlastní subject + verb a dohromady tvoří argument → použij odstavec s transitions.

## R5: Vary sentence openings

Nezačínej 2+ consecutive věty identicky. Marker AI-generated textu.

- ✗ "Nástroj má 22 agentů. Nástroj má 53 skills. Nástroj má 15 MCPs."
- ✓ "Nástroj má 22 agentů. Skills počítáme 53. MCPs jsou aktivní 3."

Kritické v: IG carousel slide-to-slide, LinkedIn paragraphs, cold email sekvence.

## R6: Term consistency

Stejná zkratka / term po celém dokumentu. Nemíchej synonymy v jednom outputu.

- "agent" / "subagent" / "specialist" → vyber jeden a drž
- "landing page" / "LP" / "marketingová stránka" → vyber jeden
- Zkratky po první introduction nerozepisuj (LCP, INP, CTR — first-use full, pak zkratka)

Exception: záměrná variace v copy (short caption, hook variation).

## Priority při konfliktu

- **Brand voice / tone** (anti-sycophancy, terse) → `anti-sycophancy.md` wins
- **Sentence-level craft** (R1-R6 výše) → tento rule
- **Lean code** → `lean-engine.md` (jiný scope — kód, ne prose)
- Všechny tři platí paralelně, žádný explicit konflikt
