### Stock Portfolio Choices

#### **Use Case**  
This ruleflow models **stock portfolio management** by evaluating current holdings, ranking stocks by return on investment (ROI), and executing **automated stock purchases** based on available cash. It aims to **optimize future portfolio value** by prioritizing investments in high-performing stocks.  

---

### **Key Decision Points**  

#### **1. Baseline Calculations (Portfolio & Stock Evaluations)**  
- **ROI Calculation:**  

ROI\=(Future Price​/Current Price)×100

- **Quantity Calculation:**  

Quantity=Net Current Value​ / Current Price

- **Net Future Value Calculation:**  

Net Future Value=Quantity * Future Price

- **Portfolio Aggregations:**  
  - **Total current value** of holdings.  
  - **Projected future portfolio value.**  
  - **Cash adjustment after stock purchases.**  

- **Stock Ranking by ROI:**  
  - Stocks are **sorted in descending order** of ROI.  
  - The top four stocks are assigned **ranks 1 to 4** for prioritization in purchasing.  

---

#### **2. Buying Additional Stocks**  
- **Filters ensure only the top four ranked stocks** (based on ROI) are considered for purchase.  
- **Purchase Conditions:**  
  - Portfolio **must have enough cash** to buy at least one unit.  
  - The stock’s **current value must be below $5,000** to allow further buying.  
- **Purchase Execution:**  
  - If conditions are met, **one additional unit is purchased**.  
  - **Cash balance is reduced** accordingly.  
- **Priority Execution:**  
  - **Stock #1 is checked first**, then **Stock #2, #3, and #4**, ensuring capital is allocated to the **highest ROI stock first**.  

---

This ruleflow automates **portfolio management** by ensuring **capital is allocated efficiently**, prioritizing **high-return stocks**, and maintaining a **structured investment strategy**.