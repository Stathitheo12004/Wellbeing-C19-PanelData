# 📁 **Wellbeing in Crisis – COVID-19, Socioeconomics & Mental Health**  
Stata | Economics | Panel Data Econometrics

This project investigates how subjective wellbeing (SWB) in the UK was shaped by socioeconomic factors during the COVID-19 pandemic. Using longitudinal data from the Understanding Society (UKHLS) survey, it applies Fixed Effects (FE), Correlated Random Effects (CRE), and Difference-in-Differences (DiD) estimators to assess how income, education, and employment influenced mental distress across regions.

# 🔍 Overview of Process

## Data & Motivation:
- We use UKHLS panel data (waves 7–11), focusing on individuals in the North East and North West of England. Mental wellbeing is proxied using GHQ-12 scores. Key explanatory variables include net income (log-transformed), education levels, and job status, alongside demographic controls.

## Econometric Strategy:
- Techniques include Pooled OLS, Random Effects, Fixed Effects, and CRE models. Model selection is informed by the Breusch-Pagan Lagrange Multiplier and Hausman tests.  
- A Difference-in-Differences framework estimates the treatment effect of the pandemic on mental health, using marital status as the treatment indicator and the first UK lockdown as the event.

## Literature & Insights:
- Higher income, education, and paid employment are associated with reduced mental distress. FE models outperform RE due to unobserved heterogeneity. DiD analysis reveals that married individuals experienced greater wellbeing declines post-lockdown—suggesting relational stress under crisis conditions.  
- These results are consistent with SWB literature (e.g., Clark & Linzer, 2014; Pieh et al., 2021) and demonstrate the usefulness of micro-level panel data in policy-relevant mental health research.

To run the project on your own machine, please import the dataset and STATA code from the following dta and do.File:
### 📂 Download the dataset: [Data.dta](./Data.dta)

### 📂 Download the code: [STATA File.do](./STATA%20File.do)
