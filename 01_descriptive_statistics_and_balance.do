* Install packages (if not installed)
cap which estpost
if _rc ssc install estout, replace

* Output directory
local outdir "/Users/yiningtang/Desktop/results"
cap mkdir "`outdir'"

* 0. Group sample size: tabulate experimental groups and export
local groupfile "`outdir'/0_group_sample_size.rtf"
cap erase "`groupfile'"
estpost tabulate group
esttab using "`groupfile'", ///
    cells("b(fmt(0) label(Count)) pct(fmt(1) label(Percent (%)))") ///
    label noobs nonumber compress ///
    title("Experimental groups: sample size and percent") ///
    replace

* Group interpretation:
* bureaucrat motivated WtE × social equity perception

* 1. Descriptive statistics for demographic and experimental variables
local outfile "`outdir'/1_demographics_and_controls_summary.rtf"
cap erase "`outfile'"

* Updated variable list (using new variable names)
local demo_vars gender age marital_status political_affiliation highest_education monthly_income work_experience ///
               control_1 control_2 control_3 control_4 mediator

* Generate frequency tables (count and percent) and append into a single RTF file
local i = 0
foreach v of local demo_vars {

    local ++i

    estpost tabulate `v'

    esttab using "`outfile'", ///
        cells("b(fmt(0) label(Count)) pct(fmt(1) label(Percent (%)))") ///
        label noobs nonumber compress ///
        title("`v': frequency and percent") ///
        `=cond(`i'==1, "replace", "append")'
}

display as text "Saved to: `groupfile'"
display as text "Saved to: `outfile'"
