# Stock Portfolio Choices

This ruleflow models stock portfolio management by evaluating current holdings, ranking stocks by return on investment (ROI), and executing automated stock purchases based on available cash. It aims to optimize future portfolio value by prioritizing investments in high-performing stocks.

<<<<<<< Updated upstream
## Key Decision Points
=======
---
## What it demonstrates
- **Ranking via sorted collection** — `holdings->sortedByDesc(roi)->at(n).roiRank = n` assigns explicit ranks.
- **Iterative budget consumption** — an `"iterative": true` subflow repeatedly buys one share of the highest-ranked affordable stock, decrementing `Portfolio.cash` and re-checking limits until no purchase qualifies.
- **Rank-targeted aliases + filters and `overrideRuleIds`** to enforce buy priority (rank 1 before rank 2, …).

---
>>>>>>> Stashed changes

### 1. Baseline Calculations (Portfolio and Stock Evaluations)

- ROI calculation: `ROI = (Future Price / Current Price) * 100`
- Quantity calculation: `Quantity = Net Current Value / Current Price`
- Net future value calculation: `Net Future Value = Quantity * Future Price`
- Portfolio aggregations: total current value of holdings, projected future portfolio value, and cash adjustment after stock purchases.
- Stock ranking by ROI: stocks are sorted in descending order of ROI, and the top four are assigned ranks 1 to 4 for purchase prioritization.

### 2. Buying Additional Stocks

- Filters ensure only the top four ranked stocks (by ROI) are considered for purchase.
- Purchase conditions: the portfolio must have enough cash to buy at least one unit, and the stock's current value must be below $5,000 to allow further buying.
- Purchase execution: if the conditions are met, one additional unit is purchased and the cash balance is reduced accordingly.
- Priority execution: stock #1 is checked first, then #2, #3, and #4, ensuring capital is allocated to the highest-ROI stock first.

This ruleflow automates portfolio management by allocating capital efficiently, prioritizing high-return stocks, and maintaining a structured investment strategy.
