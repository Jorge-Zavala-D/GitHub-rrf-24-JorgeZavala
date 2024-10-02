* RRF 2024 - Analyzing Data Template	
*-------------------------------------------------------------------------------	
* Load data
*------------------------------------------------------------------------------- 
	
	*load analysis data 
	use "${data}\Final\TZA_CCT_analysis.dta", clear

*-------------------------------------------------------------------------------	
* Summary stats
*------------------------------------------------------------------------------- 

	* defining globals with variables used for summary
	global sumvars 		hh_size n_child_5 n_elder food_cons_usd food_cons_usd_w nonfood_cons_usd nonfood_cons_usd_w area_acre area_acre_w
	
	* Summary table - overall and by districts
	eststo all: 	estpost sum $sumvars
	eststo d1:		estpost sum $sumvars if district==1
	eststo d2:		estpost sum $sumvars if district==2
	eststo d3:		estpost sum $sumvars if district==3
	
	
	* Exporting table in csv
	esttab 	all d1 d2 d3 ///
			using "${outputs}\Sumstats.csv", replace ///
			label ///
			main(mean %6.2f) aux(sd) ///
			nonotes
	
	* Also export in tex for latex
	esttab 	all d1 d2 d3 ///
			using "${outputs}\Sumstats.tex", replace ///
			label ///
			main(mean %6.2f) aux(sd) ///
			nonotes
			
*-------------------------------------------------------------------------------	
* Balance tables
*------------------------------------------------------------------------------- 	
	
	* Balance (if they purchased cows or not)
	iebaltab 	$sumvars, ///
				grpvar(treatment) ///
				rowvarlabels	///
				format(%6.2f)	///
				savecsv("${outputs}\Balance.csv") ///
				savetex("${outputs}\Balance.tex") ///
				nonote addnote(Balance treatment control) replace 			

				
*-------------------------------------------------------------------------------	
* Regressions
*------------------------------------------------------------------------------- 				
				
	* Model 1: Regress of food consumption value on treatment
	regress food_cons_usd treatment
	eststo reg1		// store regression results
	
	estadd local clustering "No"
	
	* Model 2: Add controls 
	regress food_cons_usd treatment hh_size n_child_17 n_adult n_elder livestock_now livestock_before drought_flood crop_damage 
	eststo reg2		// store regression results
	
	estadd local clustering "No"

	* Model 3: Add clustering by village
	regress food_cons_usd treatment hh_size i.floor i.roof i.walls i.water i.enegry i.rel_head i.female_head n_child_5 n_child_17 n_adult n_elder livestock_now livestock_before drought_flood crop_damage trust_mem trust_lead assoc health i.crop, cl(vid)		// store regression results
	eststo reg3		// store regression results
	
	
	estadd local clustering "Yes"
	
	
	* Export results in tex
	esttab 	reg1 reg2 reg3 ///
			using "$outputs/regressions.tex" , ///
			label ///
			b(%9.2f) se(%9.2f) ///
			nomtitles ///
			mgroup("Food consumption (USD)", pattern(1 0 0 ) span) ///
			scalars("clustering Clustering") ///
			replace
	esttab 	reg1 reg2 reg3 ///
			using "$outputs/regressions.csv" , ///
			label ///
			b(%9.2f) se(%9.2f) ///
			nomtitles ///
			mgroup("Food consumption (USD)", pattern(1 0 0 ) span) ///
			scalars("clustering Clustering") ///
			replace			
*-------------------------------------------------------------------------------			
* Graphs 
*-------------------------------------------------------------------------------	

	* Bar graph by treatment for all districts 
	gr bar area_acre_w, ///
		over(treatment) ///
		by(district, row(1) note("") ///
		legend(pos(6)) ///
		title("Area cultivated by tratment assignment across districts")) ///
		asy ///
		legend(row(1) order(0 "Assignment:" 1 "Control" 2 "Treatment")) ///
		subtitle(,pos(6) bcolor(none)) ///
		blabel(total, format(%9.1f)) ///
		ytitle("Average area cultivated in acres") name(g1, replace)
	
	gr export "$outputs/fig1.png", replace		
			
	* Distribution of non food consumption by female headed hhs with means
	forvalues f = 0/1 {
	    sum nonfood_cons_usd_w if female_head == `f'
		local mean_`f' = r(mean)
	}
	
	
	twoway	(kdensity nonfood_cons_usd_w if female_head == 0 , color(red)) ///
			(kdensity nonfood_cons_usd_w if female_head == 1, color(blue)), ///
			xline(`mean_0', lcolor(red) 	lpattern(dash)) ///
			xline(`mean_1', lcolor(blue) 	lpattern(dash)) ///
			legend(order(0 "Household Head:" 1 "Male" 2 "Female" ) row(1) pos(6)) ///
			xtitle("Distribution of non food consumption") ///
			ytitle("Density") ///
			title("Distribution of non food consumption") ///
			note("Dashed lines represent the averages")
			
	gr export "$outputs/fig2.png", replace				
			
*-------------------------------------------------------------------------------			
* Graphs: Secondary data
*-------------------------------------------------------------------------------			
			
	use "${data}/Final/TZA_amenity_analysis.dta", clear
	
	* createa  variable to highlight the districts in sample
	encode district, gen(dist)
	gen district_sample = 0
	replace district_sample = 1 if dist==1 | dist==3 | dist==6
	separate n_school, by(district_sample)
	separate n_medical, by(district_sample)
	
	* Separate indicators by sample
	
	* Graph bar for number of schools by districts
	gr hbar 	n_school0 n_school1, ///
				nofill ///
				over(district, sort(n_school)) ///
				legend(order(0 "Sample:" 1 "In-sample" 2 "Out-of-sample") row(1)  pos(6)) ///
				ytitle("Number of schools") ///
				name(g1, replace)
				
	* Graph bar for number of medical facilities by districts				
	gr hbar 	n_medical0 n_medical1, ///
				nofill ///
				over(district, sort(n_medical)) ///
				legend(order(0 "Sample:" 1 "In-sample" 2 "Out-of-sample") row(1)  pos(6)) ///
				ytitle("Number of medical facilities") ///
				name(g2, replace)
				
				
	grc1leg2 	g1 g2, ///
				row(1) legend() ///
				ycommon xcommon ///
				title("Comparison schools and medical facilites", size(???))
			
	
	gr export "$outputs/fig3.png", replace			

****************************************************************************end!
	
