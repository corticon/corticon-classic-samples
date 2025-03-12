# Residential Mortgage Eligibility and Scoring


#### **Use Case**
This ruleflow evaluates mortgage loan applications based on various risk factors and eligibility criteria. It categorizes loans into different risk grades (A+, A-, B, etc.) and determines eligibility for mortgage programs. The rules consider factors such as loan-to-value ratio (LTV), credit score, late payments, bankruptcy, foreclosure history, and loan documentation.

---

### **Key Decision Points**
#### **1. Loan-to-Value (LTV) and Credit Score Calculation**
- LTV is calculated as:  
<span class="katex-display" style=""><span class="katex"><span class="katex-mathml"><math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
                <semantics>
                    <mrow>
                        <mtext>LTV</mtext>
                        <mo>=</mo>
                        <mrow>
                            <mo fence="true">(</mo>
                            <mfrac>
                                <mtext>Borrower&nbsp;Requested&nbsp;Loan&nbsp;Amount</mtext>
                                <mtext>Appraised&nbsp;Property&nbsp;Value</mtext>
                            </mfrac>
                            <mo fence="true">)</mo>
                        </mrow>
                        <mo>×</mo>
                        <mn>100</mn>
                    </mrow>
                    <annotation encoding="application/x-tex">\text{LTV} = \left(\frac{\text{Borrower Requested Loan Amount}}{\text{Appraised Property Value}}\right) \times 100</annotation>
                </semantics>
            </math></span><span class="katex-html" aria-hidden="true"><span class="base"><span class="strut" style="height: 0.6833em;"></span><span class="mord text"><span class="mord">LTV</span></span><span class="mspace" style="margin-right: 0.2778em;"></span><span class="mrel">=</span><span class="mspace" style="margin-right: 0.2778em;"></span></span><span class="base"><span class="strut" style="height: 2.4em; vertical-align: -0.95em;"></span><span class="minner"><span class="mopen delimcenter" style="top: 0em;"><span class="delimsizing size3">(</span></span><span class="mord"><span class="mopen nulldelimiter"></span><span class="mfrac"><span class="vlist-t vlist-t2"><span class="vlist-r"><span class="vlist" style="height: 1.3714em;"><span style="top: -2.314em;"><span class="pstrut" style="height: 3em;"></span><span class="mord"><span class="mord text"><span class="mord">Appraised&nbsp;Property&nbsp;Value</span></span></span></span><span style="top: -3.23em;"><span class="pstrut" style="height: 3em;"></span><span class="frac-line" style="border-bottom-width: 0.04em;"></span></span><span style="top: -3.677em;"><span class="pstrut" style="height: 3em;"></span><span class="mord"><span class="mord text"><span class="mord">Borrower&nbsp;Requested&nbsp;Loan&nbsp;Amount</span></span></span></span></span><span class="vlist-s">​</span></span><span class="vlist-r"><span class="vlist" style="height: 0.8804em;"><span></span></span></span></span></span><span class="mclose nulldelimiter"></span></span><span class="mclose delimcenter" style="top: 0em;"><span class="delimsizing size3">)</span></span></span><span class="mspace" style="margin-right: 0.2222em;"></span><span class="mbin">×</span><span class="mspace" style="margin-right: 0.2222em;"></span></span><span class="base"><span class="strut" style="height: 0.6444em;"></span><span class="mord">100</span></span></span></span></span>

- The credit score used is the lowest score from multiple credit agencies.

#### **2. Late Payment Analysis**
- Tracks instances of **30-day, 60-day, 90-day, and 120-day late payments** on mortgage accounts.
- Totals are summed across all credit liabilities.

#### **3. Bankruptcy, Foreclosure, and Judgment Analysis**
- Determines months since bankruptcy, foreclosure, or judgment discharge.
- Sets high values (e.g., 1000 months) for applicants without such records to prevent false negatives.

#### **4. Mortgage Risk Grading**
- Loan applications are assigned risk grades (`A+`, `A-`, `B+`, etc.).
- Risk grade determination factors:
  - LTV range.
  - Credit score.
  - Number of late mortgage payments.
  - Months since bankruptcy, foreclosure, or judgment discharge.
  - Property type (Single-Family, Condo, Townhouse).
  - Loan amount range.
  - Occupancy intent (Owner vs. Non-Owner).

#### **5. Eligibility Determination**
- Applicants are evaluated for **Regular**, **ScoreAdvantage**, or **Select** mortgage programs.
- Each program has unique eligibility criteria based on financial risk factors.
- Final decision assigns eligible loan products and applicable risk categories.

---

This ruleflow automates **mortgage eligibility evaluation**, ensuring applications are processed consistently based on predefined lending criteria.