*---------------------------------------
* Step 1. Construct experimental independent variables (skip if already created)
*---------------------------------------
gen social_equity_perception_high = inlist(group,1,3)   // High social equity perception=1, Low/Control=0
gen bureaucrat_motivated_WtE_high = inlist(group,1,2)   // Backup: High bureaucrat motivated WtE=1

*---------------------------------------
* Step 2. Mediation analysis (X2 = social_equity_perception_high → mediator → y)
*---------------------------------------
eststo clear

* Model 1: Total effect  y ← social_equity_perception_high
eststo x2_m1: regress y social_equity_perception_high, robust

* Model 2: Mediator equation  mediator ← social_equity_perception_high
eststo x2_m2: regress mediator social_equity_perception_high, robust

* Model 3: Direct effect  y ← social_equity_perception_high + mediator
eststo x2_m3: regress y social_equity_perception_high mediator, robust

*---------------------------------------
* Step 3. Export results table
*---------------------------------------
esttab x2_m1 x2_m2 x2_m3 using "/Users/yiningtang/Desktop/results/4_mediation_X2_social_equity_perception.rtf", replace ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2 ar2, labels("N" "R-sq" "Adj. R-sq")) ///
    mtitles("Step 1: Total effect (y on social_equity_perception_high)" ///
            "Step 2: Mediator model (mediator on social_equity_perception_high)" ///
            "Step 3: Direct effect (y on social_equity_perception_high + mediator)") ///
    label varlabels(_cons "Constant" ///
                    social_equity_perception_high "High social equity perception (=1)" ///
                    mediator "Mediator") ///
    nogaps compress nonotes ///
    title("Mediation (X2): social equity perception → mediator → y")

*---------------------------------------
* Step 4. Bootstrap test of the indirect effect
*---------------------------------------
bootstrap ind_eff = (_b[mediator]*_b[social_equity_perception_high]) ///
    , reps(1000) seed(12345): ///
    regress y social_equity_perception_high mediator

estat bootstrap, all
