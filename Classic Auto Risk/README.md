### **Classic Auto Risk**  

#### **Use Case**  
This ruleflow evaluates **auto insurance risk and eligibility** based on multiple factors such as **vehicle characteristics, driver profile, and policy history**. It assigns **risk levels, eligibility status, and premium adjustments** to determine whether a client qualifies for an insurance policy and at what cost.  

---

### **Key Decision Points**  

#### **1. Client Eligibility & Preferred Status**  
- Determines if a client is a **"Preferred Client"** based on their **history with multiple product types** (e.g., at least three product types).  
- Preferred clients **receive discounts** and lower risk scores.  

#### **2. Vehicle Risk Factors**  
- **Theft Risk:**  
  - High if the car is a **convertible, priced over $45,000, or on a high-theft probability list**.  
- **Occupant Injury Risk:**  
  - Higher if the car has **no airbags, is a convertible without a roll bar, or lacks advanced safety features**.  
- **Eligibility Rating:**  
  - **Not Eligible** if occupant injury risk is extremely high.  
  - **Provisional Eligibility** if theft or injury risk is high.  

#### **3. Driver Risk Factors**  
- **Age-Based Risk Classification:**  
  - Young drivers (males under 25, females under 20).  
  - Senior drivers (over 70).  
- **Driving Record:**  
  - High-risk if there are **DUI convictions, multiple accidents, or excessive moving violations**.  
- **Training Certifications:**  
  - Reduces risk for young and senior drivers.  

#### **4. Insurance Scoring & Premium Adjustments**  
- **Eligibility Score:**  
  - Increased by **high-risk attributes** (e.g., accidents, DUIs, theft-prone cars).  
  - Decreased by **preferred client status or driver training**.  
- **Premium Calculation:**  
  - Adjusted based on **vehicle type, safety features, and risk factors**.  
  - Discounts applied for **airbags, anti-theft systems, and good driving history**.  

#### **5. Final Insurance Decision**  
- Clients with **scores under 100** are **approved**.  
- Scores **between 100-250** require **manual underwriting review**.  
- Scores **above 250** are **denied coverage**.  
- **Long-term clients (15+ years)** are automatically eligible regardless of score.  

---

This ruleflow provides **a structured approach to auto insurance risk assessment**, ensuring **fair and consistent underwriting decisions** while optimizing pricing based on risk factors.