---
id: classic_Numerals
title: Roman numerals to numbers
tags:
  - Corticon classic
---

Convert number to Roman numerals

---

[Download Rule Assets](https://github.com/corticon/accelerators/raw/main/docs/classic-templates/project-zips/RomanNumerals.zip)

---



This rule puzzle is focused on data transformation. This is pretty common in most rule implementations, albeit this puzzle is a bit atypical.

Create a rules project that converts any Arabic number to Roman numerals (see: https://www.rapidtables.com/math/symbols/roman_numerals.html). For example: input = “94” (either as an integer or as a string) and output = “XCIV”. Assume two scenarios where the original Arabic number is an Integer value, but also represented as a (separate) String value.

Perhaps the hardest part of this problem is “extracting” or “parsing” the place values – in other words, determining what number is in the “tens place” or the “hundreds place”. If our original Arabic input is 258, then it’s easy for us to see that we have 2 “hundreds”, 5 “tens” and 8 “ones”, or alternatively, 200 plus 50 plus 8. But how can the rules determine this?

Hint: make intelligent use of the many rule operators you have available in Corticon to create your rules.