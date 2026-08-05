# Residential Mortgage Eligibility and Scoring

This ruleflow evaluates mortgage loan applications based on various risk factors and eligibility criteria. It categorizes loans into risk grades (A+, A-, B, and so on) and determines eligibility for mortgage programs. The rules consider factors such as loan-to-value ratio (LTV), credit score, late payments, bankruptcy, foreclosure history, and loan documentation.

## Key Decision Points

### 1. Loan-to-Value (LTV) and Credit Score Calculation

- LTV is calculated as: `LTV = (BorrowerRequestedLoanAmount / AppraisedPropertyValue) * 100`
- The credit score used is the lowest score from multiple credit agencies.

### 2. Late Payment Analysis

- Tracks instances of 30-day, 60-day, 90-day, and 120-day late payments on mortgage accounts.
- Totals are summed across all credit liabilities.

### 3. Bankruptcy, Foreclosure, and Judgment Analysis

- Determines months since bankruptcy, foreclosure, or judgment discharge.
- Sets high values (for example, 1000 months) for applicants without such records to prevent false negatives.

### 4. Mortgage Risk Grading

- Loan applications are assigned risk grades (A+, A-, B+, and so on).
- Risk grade is determined by LTV range, credit score, number of late mortgage payments, months since bankruptcy, foreclosure, or judgment discharge, property type (single-family, condo, townhouse), loan amount range, and occupancy intent (owner vs. non-owner).

### 5. Eligibility Determination

- Applicants are evaluated for Regular, ScoreAdvantage, or Select mortgage programs.
- Each program has unique eligibility criteria based on financial risk factors.
- The final decision assigns eligible loan products and applicable risk categories.

This ruleflow automates mortgage eligibility evaluation, ensuring applications are processed consistently against predefined lending criteria.
