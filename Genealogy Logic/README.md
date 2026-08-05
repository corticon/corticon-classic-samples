# Genealogy Logic (Hierarchy Traversal)

This ruleflow models family relationships by analyzing a genealogical hierarchy. It determines family relationships, generations, and ancestry connections based on parent-child linkages.

## Key Decision Points

### 1. Counting Descendants

- Calculates the number of children and total descendants for each person in the hierarchy.
- Accumulates descendant counts recursively across generations.

### 2. Identifying Siblings

- Finds individuals who share the same parent, identifying siblings.

### 3. Determining Generational Relationships

- Computes the difference in generations between two individuals.
- Assigns relationship labels based on generational distance: 0 generations apart is the same person, 1 generation apart is parent and child, 2 generations apart is grandparent and grandchild, and more than 2 generations apart is a great-grandparent or great-grandchild with counted "greats."

### 4. Finding the Closest Common Ancestor

- Determines the closest shared ancestor between two individuals.
- Helps classify relationships such as cousins, aunts, and uncles.

### 5. Defining Family Relationship Types

- Siblings (1 generation apart, same ancestor).
- Aunt/uncle and niece/nephew (1 generation apart, different ancestor levels).
- Cousins (2+ generations apart, same ancestor level).
- Removed cousins (when one cousin is from a different generation than the other).

## Iterative Processing Concepts

- Iterative processing: the iterative option in Corticon allows a rule to execute multiple times within the same execution cycle, looping until a condition is met or all entities are processed. This differs from standard execution, where each rule runs once per applicable entity per cycle. Iterative rules are useful when a value must be accumulated or a hierarchy must be traversed dynamically.
- The `->next` operator: a collection navigation operator used to iterate through ordered collections, moving from one entity to the next in sequence. It is commonly used in linked lists, hierarchical structures, or ordered data sets.
- Incrementing an integer in an iterative rule: when used with an integer such as a generation count, iteration allows the value to be incremented dynamically during execution, which is useful for tracking cumulative counts such as generation numbers in a family tree.

## How These Concepts Apply in This Ruleflow

### Count_Descendants (using `->next` and iterative processing)

- Goal: count the number of descendants of a person by iterating through the hierarchy.
- Logic: `p.numberOfChildren = kid->size` counts direct children; `p.numberOfDescendants = p.numberOfChildren` starts with the direct count; `p.numberOfDescendants += kid.numberOfDescendants` adds children's descendants recursively.
- Iteration is needed because descendants can have their own descendants, so an iterative rule ensures all levels of the hierarchy are traversed. The `->next` operator steps through child entities dynamically.

### Determine_Generation (incrementing an integer with iteration)

- Goal: assign a generation number to each individual.
- Logic: a person with no parent is generation 1; otherwise their generation is `ancestor.generation + 1`.
- Iteration is needed because generation numbers depend on the parent's generation value, so iteration ensures each person's generation is calculated only after their parent's is assigned.

By using iterative processing, Corticon ensures that both descendant counts and generational numbers propagate correctly across the entire hierarchy, making it an effective way to process structured hierarchical data dynamically.
