# DNA Transcription and Translation

This ruleflow models DNA transcription and protein synthesis by simulating messenger RNA (mRNA) translation by ribosomes and transfer RNA (tRNA) codon matching. It follows the biological mechanisms where genetic information is converted into proteins based on a set of codon-to-amino-acid rules.

## Key Decision Points

### 1. mRNA Translation by Ribosomes (Ribosome Ruleflow)

- Ribosome attachment: a ribosome attaches to an mRNA strand only if fewer than 3 ribosomes are currently processing the strand.
- Codon processing: the ribosome reads three nucleotides (a codon) at a time, matches the codon to a corresponding tRNA molecule, and adds the amino acid abbreviation and symbol to the growing protein chain.
- Handling stop codons: if the codon is UAA, UAG, or UGA, the ribosome detaches and the completed protein sequence is stored.

### 2. tRNA Assembly and Amino Acid Assignment (tRNA Ruleflow)

- Codon-anticodon pairing: each tRNA molecule is assigned a codon (3 nucleotides) and an anticodon (complementary nucleotides).
- Amino acid mapping: each codon corresponds to a specific amino acid (for example, AUG to Methionine (M), UUU to Phenylalanine (F)). Stop codons (UAA, UAG, UGA) terminate translation.

## Biological and Computational Alignment

- Iterative processing of mRNA simulates ribosome movement along the strand in increments of 3 bases.
- Codon-anticodon matching ensures tRNA molecules correctly bind to mRNA codons.
- Dynamic protein chain assembly builds protein sequences step by step, reflecting real cellular translation.

This ruleflow models genetic translation, making it useful for bioinformatics, molecular biology simulations, and educational purposes.
