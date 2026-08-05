# Classic Auto Risk

This ruleflow evaluates auto insurance risk and eligibility based on vehicle characteristics, driver profile, and policy history. It assigns risk levels, eligibility status, and premium adjustments to determine whether a client qualifies for a policy and at what cost.

## Key Decision Points

### 1. Client Eligibility and Preferred Status

- Determines whether a client is a Preferred Client based on their history with multiple product types (for example, at least three product types).
- Preferred clients receive discounts and lower risk scores.

### 2. Vehicle Risk Factors

- Theft risk is high if the car is a convertible, priced over $45,000, or on a high-theft probability list.
- Occupant injury risk is higher if the car has no airbags, is a convertible without a roll bar, or lacks advanced safety features.
- Eligibility rating is Not Eligible if occupant injury risk is extremely high, or Provisional if theft or injury risk is high.

### 3. Driver Risk Factors

- Age-based risk classification for young drivers (males under 25, females under 20) and senior drivers (over 70).
- Driving record raises risk for DUI convictions, multiple accidents, or excessive moving violations.
- Training certifications reduce risk for young and senior drivers.

### 4. Insurance Scoring and Premium Adjustments

- Eligibility score is increased by high-risk attributes (accidents, DUIs, theft-prone cars) and decreased by preferred status or driver training.
- Premium is adjusted based on vehicle type, safety features, and risk factors, with discounts for airbags, anti-theft systems, and good driving history.

### 5. Final Insurance Decision

- Scores under 100 are approved.
- Scores between 100 and 250 require manual underwriting review.
- Scores above 250 are denied coverage.
- Long-term clients (15+ years) are automatically eligible regardless of score.

This ruleflow provides a structured approach to auto insurance risk assessment, supporting consistent underwriting decisions while adjusting pricing based on risk factors.
