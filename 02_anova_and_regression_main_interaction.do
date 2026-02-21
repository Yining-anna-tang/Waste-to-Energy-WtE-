*---------------------------------------
* Basic setup and output path
*---------------------------------------
cap which estpost
if _rc ssc install estout, replace

local outdir "/Users/yiningtang/Desktop/results"
cap mkdir "`outdir'"
local outfile "`outdir'/2_anova_basic_results.rtf"
cap erase "`outfile'"

*---------------------------------------
* Keep only experimental groups (1–4); exclude control group 5
*---------------------------------------
preserve
keep if inlist(group,1,2,3,4)

*---------------------------------------
* Decode group into two factor dimensions:
* bureaucrat_motivated_WtE & social_equity_perception
* Group 1: High bureaucrat motivated WtE, High social equity perception
* Group 2: High bureaucrat motivated WtE, Low  social equity perception
* Group 3: Low  bureaucrat motivated WtE, High social equity perception
* Group 4: Low  bureaucrat motivated WtE, Low  social equity perception
*---------------------------------------
gen byte bureaucrat_motivated_WtE   = inlist(group,1,2)   // High=1, Low=0
gen byte social_equity_perception   = inlist(group,1,3)   // High=1, Low=0

label define highlow 0 "Low" 1 "High"
label values bureaucrat_motivated_WtE highlow
label values social_equity_perception highlow

* Coding checks (optional)
* tab group
* tab bureaucrat_motivated_WtE
* tab social_equity_perception
* table group bureaucrat_motivated_WtE social_equity_perception

*---------------------------------------
* Variable lists
*---------------------------------------
local ctrls_core control_1 control_2 control_3 control_4
local ctrls_demo gender age marital_status political_affiliation highest_education monthly_income work_experience

*---------------------------------------
* Regressions (equivalent to two-way ANOVA with interaction) and export
* mediator : perceived predictability (mediator)
* y        : outcome variable (DV)
* Using regress allows direct R-squared reporting; robust provides robust SEs
*---------------------------------------
eststo clear

* (1) mediator: no controls
eststo m1: regress mediator i.bureaucrat_motivated_WtE##i.social_equity_perception, robust

* (2) y: no controls
eststo m2: regress y i.bureaucrat_motivated_WtE##i.social_equity_perception, robust

* (3) mediator: add controls (core + demographics)
eststo m3: regress mediator i.bureaucrat_motivated_WtE##i.social_equity_perception ///
    `ctrls_core' `ctrls_demo', robust

* (4) y: add controls (core + demographics)
eststo m4: regress y i.bureaucrat_motivated_WtE##i.social_equity_perception ///
    `ctrls_core' `ctrls_demo', robust

* If you only want core controls (no demographics), use:
* eststo m3: regress mediator i.bureaucrat_motivated_WtE##i.social_equity_perception `ctrls_core', robust
* eststo m4: regress y       i.bureaucrat_motivated_WtE##i.social_equity_perception `ctrls_core', robust

*---------------------------------------
* Export results to RTF
*---------------------------------------
esttab m1 m2 m3 m4 using "`outfile'", replace ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2 ar2, labels("N" "R-sq" "Adj. R-sq")) ///
    mtitles("DV=mediator (no ctrl)" "DV=y (no ctrl)" ///
            "DV=mediator (+ctrls)" "DV=y (+ctrls)") ///
    label varlabels(_cons "Constant" ///
        1.bureaucrat_motivated_WtE "High bureaucrat motivated WtE" ///
        1.social_equity_perception "High social equity perception" ///
        1.bureaucrat_motivated_WtE#1.social_equity_perception "bureaucrat motivated WtE × social equity perception" ///
        control_1 "Control 1" ///
        control_2 "Control 2" ///
        control_3 "Control 3" ///
        control_4 "Control 4") ///
    nogaps compress nonotes

restore

di as text "Saved to: `outfile'"
