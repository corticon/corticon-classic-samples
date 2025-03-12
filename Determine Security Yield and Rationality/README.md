### Determine Security Yield and Rationality

#### **Use Case**
This ruleflow assesses the **rationality of stock evaluations** by analyzing historical market data and market reports. It determines:
1. **The yield of a stock based on a predicted target price.**
2. **The rationality of the target price, report title, and summary.**
3. **A final evaluation level based on these factors.**

This helps in identifying stocks with unrealistic predictions or misleading market reports.

---

### **Key Decision Points**
#### **1. Find Previous Market Date**
- Retrieves the most recent available market date before the stock evaluation date.
- Ensures stock analysis is based on the latest relevant data.

**Logic:**
- Finds the second most recent market date (`previousStockDate`) from `MarketData` for a given stock.

---

#### **2. Evaluate Target Price Rationality**
- Determines whether the **predicted target price** is reasonable based on past closing prices.

**Logic:**
- Computes **implied yield**:  

    impliedYield = (MarketReport.predictedTargetPrice / MDPrevious.closingPrice) * 100
 

- Rationality thresholds:
  - **Unreasonable**: Yield < -150% or > 150%.
  - **Reasonable**: Yield between -150% and 150%.

---

#### **3. Evaluate Title Rationality**
- Checks if a **market report title** contains misleading words.

**Logic:**
- If the title contains **"insider"**, it is labeled **Unreasonable**.
- Otherwise, it is labeled **Reasonable**.

---

#### **4. Evaluate Summary Rationality**
- Analyzes the **summary text** of a market report.

**Logic:**
- If the summary contains **"according to reliable sources"**, it is **Unreasonable**.
- Otherwise, it is **Reasonable**.

---

#### **5. Determine Overall Security Evaluation Level**
- Assigns a **level** based on the rationality of the **target price, title, and summary**.

**Logic:**
- Level **0**: All rationality checks are **Reasonable**.
- Level **1**: **Target Price is Unreasonable**, but Title & Summary are **Reasonable**.
- Level **2**: **Either Title or Summary is Unreasonable**.

---

This ruleflow helps ensure **accurate stock evaluations** and detects **unreliable market reports**, improving investment decision-making.