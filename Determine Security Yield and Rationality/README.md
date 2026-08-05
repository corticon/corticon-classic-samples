# Determine Security Yield and Rationality

This ruleflow assesses the rationality of stock evaluations by analyzing historical market data and market reports. It determines the yield of a stock based on a predicted target price, the rationality of the target price, report title, and summary, and a final evaluation level based on these factors. This helps identify stocks with unrealistic predictions or misleading market reports.

## Key Decision Points

### 1. Find Previous Market Date

- Retrieves the most recent available market date before the stock evaluation date, ensuring analysis is based on the latest relevant data.
- Logic: finds the second most recent market date (previousStockDate) from MarketData for a given stock.

### 2. Evaluate Target Price Rationality

- Determines whether the predicted target price is reasonable based on past closing prices.
- Logic: computes implied yield as `impliedYield = (MarketReport.predictedTargetPrice / MDPrevious.closingPrice) * 100`.
- Rationality thresholds: unreasonable if yield is below -150% or above 150%; reasonable if yield is between -150% and 150%.

### 3. Evaluate Title Rationality

- Checks whether a market report title contains misleading words.
- Logic: if the title contains "insider," it is labeled unreasonable; otherwise it is reasonable.

### 4. Evaluate Summary Rationality

- Analyzes the summary text of a market report.
- Logic: if the summary contains "according to reliable sources," it is unreasonable; otherwise it is reasonable.

### 5. Determine Overall Security Evaluation Level

- Assigns a level based on the rationality of the target price, title, and summary.
- Logic: Level 0 if all checks are reasonable; Level 1 if the target price is unreasonable but title and summary are reasonable; Level 2 if either the title or summary is unreasonable.

This ruleflow helps ensure accurate stock evaluations and detects unreliable market reports, improving investment decision-making.
