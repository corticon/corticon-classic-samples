# 99 Bottles of Beer ("Song")

A playful decision service that "sings" the countdown song — but the reason to study it is the **iteration**, not the lyrics.

## What it demonstrates
- **In-rulesheet looping** via `allLogicalLoops: true`. A single rulesheet re-fires against itself, decrementing a counter (`Beer.qtyLeft -= 1`) until its guard condition (`qtyLeft > 3`) stops matching. This is the canonical answer to "how do I loop in Corticon without a procedural language."
- **Constrained custom datatype** — `beerCount` enforces `value in [0..100]`, so the counter can never go out of range.
- **Graduated rule statement severities** (Info → Violation) to change the emitted message as the count winds down.

## Why it's useful
This is the smallest, clearest example of self-terminating iteration in the repo — a great first stop for anyone learning how rules can repeat.
