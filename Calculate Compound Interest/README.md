### **Calculate Compound Interest**

#### **Use Case**
This ruleflow is designed to compute both **simple interest** and **compound interest** based on loan parameters. It determines the rate per period from the **Annual Percentage Rate (APR)** based on the compounding frequency (daily, weekly, monthly, annually). The goal is to calculate how much interest accumulates over time using both simple and compound interest formulas.

#### **Types of Decisions Being Made**
1. **Determining the compounding frequency**  
   - Converts `ratePeriodInterval` (e.g., daily, weekly, monthly, annually) into the correct number of times the interest is compounded per year.
   
2. **Calculating Simple Interest**  
   - Uses the formula:  
     \[
     \text{Simple Interest} = \text{Principal} \times \text{Rate per Year} \times \text{Number of Years}
     \]

3. **Calculating Compound Interest**  
   - Uses the formula:  
     \[
     A = P \times \left(1 + \frac{r}{n}\right)^{n \times t}
     \]
     where:
     - \( A \) = Final Amount (including interest)  
     - \( P \) = Principal  
     - \( r \) = Annual Interest Rate  
     - \( n \) = Number of times interest is compounded per year  
     - \( t \) = Number of years  
   - The compound interest is then extracted as:  
     \[
     \text{Compound Interest} = A - P
     \]



This project efficiently models financial calculations in Corticon, ensuring accurate interest computations for various compounding intervals.

![](images/compound_interest_test.png)