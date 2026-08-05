# Probabilistic Reasoning (Bayes Probability)

This ruleflow applies Bayesian probability to infer the most likely classification of an object based on observed evidence such as color, shape, and size. It assigns certainty factors (CFs) to possible conclusions and refines probabilities by logically combining multiple evidence sources.

## Key Decision Points

### 1. Initial Evidence Analysis

- Assigns probabilities (certainty factors, CFs) to potential conclusions based on single observations. For example, a yellow object might be a banana (CF = 0.5) or a lemon (CF = 0.5), but not a raspberry (CF = -1.0).
- Each rule defines the likelihood of an object being a specific entity based on its color, shape, or size.

### 2. Combining Evidence (Bayesian Updating)

- Multiple pieces of evidence (for example, color, shape, and size) are combined to adjust probabilities.
- If an object is yellow and oval, the certainty of it being a lemon increases.
- If an object is long, it could be a banana or a submarine with different CFs.
- If conflicting evidence exists (for example, red and banana, which is impossible), the system rules it out.

### 3. Filtering and Displaying Results

- Contradictory evidence eliminates possibilities (for example, an object cannot be a banana if it is red).
- All possible classifications are displayed with their final CF values.

### 4. Selecting the Most Likely Conclusion

- The classification with the highest CF is chosen as the final answer.
- The final output states: "It is most likely a [classification] because it is [observed traits]; CF = [certainty factor]."

This ruleflow mimics probabilistic reasoning, making it useful for classification systems, diagnostic tools, and decision support systems.
