📘 Project Overview
This repository contains the empirical materials, variable documentation, and analytical framework for the study:
“Bureaucrat Incentives Embedded in Waste-to-Energy (WtE) Combustion Enhance Local Government Performance Competitiveness.”
China leads global waste-to-energy (WtE) capacity expansion, accounting for approximately 38.4%–50.0% of total installed capacity worldwide. Unlike existing studies that emphasize technical efficiency or carbon reduction outcomes, this project investigates the political and institutional consequences of embedding WtE expansion into bureaucratic performance evaluation systems.

Drawing on:
A nationally representative survey dataset (CGSS 2021, n = 8,148)
A supplementary experimental dataset (n = 1,711)
Configurational causal analysis (fsQCA)
we examine how perceived environmental improvement enhances:
Government environmental governance satisfaction (SGEG)
Local government performance competitiveness
Bureaucratic political competitiveness under promotion-based incentive systems
Our findings show that visible environmental improvements strengthen perceived governance performance, and that perceived social equity (SEP) amplifies this effect.

🎯 Research Questions
Does perceived environmental improvement enhance local government performance competitiveness?
Do bureaucratic incentives embedded in WtE combustion strengthen public evaluations of governance?
Does perceived social equity amplify the relationship between environmental improvement and government performance?
What combinations of environmental, behavioral, and cognitive factors jointly produce high government competitiveness?

🧪 Research Design
Study 1: National Survey Analysis (CGSS 2021)
Dataset: China General Social Survey (CGSS 2021)
Sample size: 8,148 respondents
Method: Machine learning + regression analysis
Goal: Examine how perceived environmental improvement affects SGEG
Study 2: WtE Experimental Context
Platform: Credamo online experimental platform
Sample size: 1,711 respondents
Context: Waste-to-Energy governance scenario
Goal: Identify causal interpretation in WtE-specific environmental perception
Study 3: Configurational Analysis (fsQCA)
Groups: T1–T4
Method: Fuzzy-set Qualitative Comparative Analysis
Goal: Identify causal configurations leading to high SGEG

📊 Key Variables
🎯 Output Variable
Abbreviation	Variable Name
SGEG	Satisfaction with Government Environmental Governance
SGEG serves as a proxy for local government performance competitiveness, measured using CGSS item H8 (5-point Likert scale).
🔑 Core Input Variable
Abbreviation	Variable Name
ILE	Improvement of Living Environment
Constructed from CGSS items H6 (5-year comparison) and H7 (10-year comparison), capturing perceived environmental improvement over time.
📌 Additional Input Variables
#	Abbreviation	Description
EPPD	Environmental protection purchase decision
EAI	Environmental awareness index
FACEI	Family action on community environmental issues
EPSP	Environmental protection social participation
UFSC	Urban food safety concerns
WPIC	Water pollution impact on community
WEP_Tax	Willingness to environmental protection tax
UW_RNR	Unwillingness to reduce natural resources for economic development
EWIC	Extreme weather impact on community
ECK	Environmental cause knowledge
ESA	Environmental stewardship awareness
ESK	Environmental strategy knowledge
APIC	Air pollution impact on community
EPK	Environmental policy knowledge
AUGP	Acceptance of urban green penalties
REnth	Recycling enthusiasm
WWGD	Willingness to work on garbage disposal
SEP	Social equity perception
TFC	Traditional family concept

🧠 Theoretical Contributions
This study offers three major contributions:
Political Incentive Perspective on WtE Expansion
Moves beyond efficiency analysis to examine how bureaucratic performance evaluation systems embed environmental infrastructure into political promotion mechanisms.
Environmental Visibility and Political Competitiveness
Demonstrates that visible environmental improvement strengthens perceived local government competitiveness.
Interaction of Equity and Governance Performance
Identifies social equity perception as a key moderating factor that amplifies environmental governance evaluation.

🛠 Methodological Framework
Machine learning models
SHAP interpretability analysis
Regression and interaction models
fsQCA configurational causality analysis
Likert-scale measurement operationalization

🔬 Policy Implications
Environmental infrastructure can function as a political signaling mechanism.
Visible environmental gains enhance bureaucratic promotion competitiveness.
Equity perception is critical for sustaining public support.
WtE governance effectiveness depends not only on technical performance but also on political incentive alignment.

📎 Data Availability
CGSS datasets are publicly available via the official CGSS website two years after completion.
Experimental data collected via Credamo platform (access subject to project approval).

## 1️⃣ Code and Data Usage (Stata Reproducibility Guide)

This repository provides fully reproducible Stata code and experimental data for replicating all empirical results reported in the manuscript.

---

## 2️⃣ Software Requirements

The analysis was conducted using:

* Stata version 17 or higher
* Required Stata package:

```stata
ssc install estout, replace
```

This package is used for exporting regression and descriptive statistics tables.

---

## 3️⃣ Data File

The experimental dataset is provided as:

```text
Supplementary experimental dataset (n = 1,711).dta
```

This dataset contains:

* Experimental group assignment (`group`)
* Independent variables:

  * bureaucrat motivated WtE condition
  * social equity perception condition
* Mediator variable:

  * mediator (perceived predictability)
* Outcome variable:

  * y (behavioral or evaluative outcome)
* Control variables:

  * control_1
  * control_2
  * control_3
  * control_4
* Demographic variables

---

## 4️⃣ How to Run the Analysis

Before running the code, open Stata and set the working directory to the project folder:

```stata
cd "YOUR_PROJECT_FOLDER_PATH"
```

Then load the dataset:

```stata
use "Supplementary experimental dataset (n = 1,711).dta", clear
```

---

## 5️⃣ Code Files and Their Functions

Run the following `.do` files in numerical order:

---

### 01_descriptive_statistics_and_balance.do

Purpose:

* Generates group sample size tables
* Generates descriptive statistics for demographic variables and controls
* Performs balance checks across experimental groups

Output:

```text
results/
0_group_sample_size.rtf
1_demographics_and_controls_summary.rtf
```

---

### 02_anova_and_regression_main_interaction.do

Purpose:

* Estimates main effects of:

  * bureaucrat motivated WtE
  * social equity perception
* Estimates interaction effects
* Equivalent to two-way ANOVA and regression models

Output:

```text
results/
2_anova_basic_results.rtf
```

---

### 03_mediation_bureaucrat_motivated_WtE.do

Purpose:

Tests mediation pathway:

```text
bureaucrat motivated WtE → mediator → y
```

Includes:

* Total effect estimation
* Direct effect estimation
* Bootstrap indirect effect test

Output:

```text
results/
3_mediation_X1_bureaucrat_motivated_WtE.rtf
```

---

### 04_mediation_social_equity_perception.do

Purpose:

Tests mediation pathway:

```text
social equity perception → mediator → y
```

Includes:

* Total effect estimation
* Direct effect estimation
* Bootstrap indirect effect test

Output:

```text
results/
4_mediation_X2_social_equity_perception.rtf
```

---

## 6️⃣ Output Files

All results will be automatically exported to:

```text
/Users/yiningtang/Desktop/results/
```

You may modify the output directory in each `.do` file:

```stata
local outdir "YOUR_OUTPUT_DIRECTORY"
```

---

## 7️⃣ Experimental Design Structure

Experimental groups are coded as:

| Group | bureaucrat motivated WtE | social equity perception |
| ----- | ------------------------ | ------------------------ |
| 1     | High                     | High                     |
| 2     | High                     | Low                      |
| 3     | Low                      | High                     |
| 4     | Low                      | Low                      |
| 5     | Control group            |                          |

---

## 8️⃣ Full Replication

To fully replicate all results:

Run in order:

```stata
do 01_descriptive_statistics_and_balance.do
do 02_anova_and_regression_main_interaction.do
do 03_mediation_bureaucrat_motivated_WtE.do
do 04_mediation_social_equity_perception.do
```

---

## 9️⃣ Reproducibility Statement

All reported results in the manuscript can be reproduced directly using the provided dataset and Stata scripts without modification.

---

```text
master.do
```



