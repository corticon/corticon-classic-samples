### **Hierarchy Traversal**  

#### **Use Case**  
This ruleflow models **family relationships** by analyzing a **genealogical hierarchy**. It determines **family relationships, generations, and ancestry connections** based on parent-child linkages.  

---

### **Key Decision Points**  

#### **1. Counting Descendants**  
- Calculates the **number of children** and **total descendants** for each person in the hierarchy.  
- Accumulates descendant counts recursively across generations.  

#### **2. Identifying Siblings**  
- Finds individuals who **share the same parent**, identifying **siblings**.  

#### **3. Determining Generational Relationships**  
- Computes the **difference in generations** between two individuals.  
- Assigns relationship labels based on generational distance:  
  - **0 generations apart** → **Same person**  
  - **1 generation apart** → **Parent and Child**  
  - **2 generations apart** → **Grandparent and Grandchild**  
  - **More than 2 generations apart** → **Great-grandparent or Great-grandchild with counted "greats"**  

#### **4. Finding Closest Common Ancestor**  
- Determines the closest shared ancestor between two individuals.  
- Helps classify relationships such as **cousins, aunts, and uncles**.  

#### **5. Defining Family Relationship Types**  
- **Siblings (1 generation apart, same ancestor)**  
- **Aunt/Uncle and Niece/Nephew (1 generation apart, different ancestor levels)**  
- **Cousins (2+ generations apart, same ancestor level)**  
- **Removed cousins (when one cousin is from a different generation than the other)**  

---

This ruleflow provides a **structured approach to family tree analysis**, supporting **genealogical research, ancestry tracking, and relationship determination** based on hierarchical traversal.