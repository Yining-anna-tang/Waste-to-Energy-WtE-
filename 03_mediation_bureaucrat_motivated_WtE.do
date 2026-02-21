*---------------------------------------
* Step 1. Construct experimental independent variables (skip if already created)
*---------------------------------------
gen social_equity_perception_high = inlist(group,1,3)   // High social equity perception=1, Low/Control=0
gen bureaucrat_motivated_WtE_high = inlist(group,1,2)   // High bureaucrat motivated WtE=1, Low/Control=0

*---------------------------------------
* Step 2. Mediation analysis (bureaucrat_motivated_WtE_high → mediator → y)
*---------------------------------------
eststo clear

* Model 1: IV → DV (total effect)
eststo m1: regress y bureaucrat_motivated_WtE_high, robust

* Model 2: IV → mediator
eststo m2: regress mediator bureaucrat_motivated_WtE_high, robust

* Model 3: IV + mediator → DV (direct effect)
eststo m3: regress y bureaucrat_motivated_WtE_high mediator, robust

*---------------------------------------
* Step 3. Export results table
*---------------------------------------
esttab m1 m2 m3 using "/Users/yiningtang/Desktop/results/3_mediation_X1_bureaucrat_motivated_WtE.rtf", replace ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2 ar2, labels("N" "R-sq" "Adj. R-sq")) ///
    mtitles("Step 1: Total effect (y on bureaucrat_motivated_WtE_high)" ///
            "Step 2: Mediator model (mediator on bureaucrat_motivated_WtE_high)" ///
            "Step 3: Direct effect (y on bureaucrat_motivated_WtE_high + mediator)") ///
    label varlabels(_cons "Constant" ///
                    bureaucrat_motivated_WtE_high "High bureaucrat motivated WtE (=1)" ///
                    mediator "Mediator") ///
    nogaps compress nonotes ///
    title("Mediation: bureaucrat motivated WtE → mediator → y")

*---------------------------------------
* Step 4. Bootstrap test of the indirect effect (consistent with the original design)
*---------------------------------------
bootstrap ind_eff = (_b[mediator]*_b[bureaucrat_motivated_WtE_high]) ///
    , reps(1000) seed(12345): ///
    regress y bureaucrat_motivated_WtE_high mediator

estat bootstrap, all

drop social_equity_perception_high bureaucrat_motivated_WtE_high _est_m1 _est_m2 _est_m3
