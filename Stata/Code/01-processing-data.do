* RRF 2024 - Processing Data Template	
*-------------------------------------------------------------------------------	
* Loading data
*------------------------------------------------------------------------------- 	
	
	* Load TZA_CCT_baseline.dta
	use "${data}/Raw/TZA_CCT_baseline.dta", clear
	
*-------------------------------------------------------------------------------	
* Checking for unique ID and fixing duplicates
*------------------------------------------------------------------------------- 		

	* Identify duplicates // KEY (from SurveyCTO is the unique var, otherwise need to create it)
	ieduplicates	hhid ///
					using "${outputs}/duplicates.xlsx", ///
					uniquevars(key) ///
					keepvars(vid enid submissionday) ///
					nodaily
					
	
*-------------------------------------------------------------------------------	
* Define locals to store variables for each level
*------------------------------------------------------------------------------- 							
	*TIDY: Unique ID, Each row an obs, Each col a variable
	
	* IDs
	local ids 		vid hhid enid
	
	* Unit: household
	local hh_vars 	floor roof walls water enegry rel_head 			///
				female_head hh_size n_child_5 n_child_17 n_adult n_elder		///
				food_cons nonfood_cons farm ar_farm ar_farm_unit crop 			///
				crop_other crop_prp livestock_now livestock_before 				///
				drought_flood crop_damage trust_mem trust_lead assoc health 	///
				duration submissionday
	
	* Unit: Household-memebr (no suffixes) This will help the reshape later
	local hh_mem	gender age read clinic_visit sick days_sick 	///
			treat_fin treat_cost ill_impact days_impact
	
	
	* define locals with suffix and for reshape
	foreach mem in `hh_mem' {
		
		local mem_vars 		"`mem_vars' `mem'_*"
		local reshape_mem	"`reshape_mem' `mem'_"
	}
		
	
*-------------------------------------------------------------------------------	
* Tidy Data: HH
*-------------------------------------------------------------------------------	

	*preserve 
		
		* Keep HH vars
		keep `ids' `hh_vars'
		
		* Check if data type is string
		ds, has(type string)
		
		* Fixing submission date
		gen submissiondate = date(submission, "YMD hms")
		format submissiondate %td
		
		* Encoding area farm unit
		encode ar_farm_unit, gen(ar_unit)
		
		* Convert duration into numerical
		destring duration, replace
		
		replace crop_other = proper(crop_other)
		replace crop = 40 if regex(crop_other, "Coconut") == 1
		replace crop = 41 if regex(crop_other, "Sesame") == 1
		
		label def df_CROP 40 "Coconut" 41 "Sesame", add
		
		* Fix data types 
			* numeric should be numeric
			* dates should be in the date format
			* Categorical should have value labels 
		
				
		
		* Turn numeric variables with negative values into missings
		ds, has(type numeric)
		global numVar `r(varlist)'

		foreach numVar of global numVar {
			
			recode `numVar' (-88 =.d)
		}	
		
		sum $numVar
		
		* Explore variables for outliers
		sum ???
		
		* dropping, ordering, labeling before saving
		drop 	???
				
		order 	???
		
		lab var ???
		
		isid ???
		
		* Save data		
		iesave 	"${data}/Intermediate/???", ///
				idvars(???)  version(???) replace ///
				report(path("${outputs}/???.csv") replace)  
		
	restore
	
*-------------------------------------------------------------------------------	
* Tidy Data: HH-member 
*-------------------------------------------------------------------------------*

	preserve 

		keep ???

		* tidy: reshape tp hh-mem level 
		reshape ???
		
		* clean variable names 
		rename ???
		
		* drop missings 
		drop if mi(???)
		
		* Cleaning using iecodebook
		// recode the non-responses to extended missing
		// add variable/value labels
		// create a template first, then edit the template and change the syntax to 
		// iecodebook apply
		iecodebook apply 	using ///
								"${outputs}/hh_mem_codebook.xlsx"
								
		isid ???					
		
		* Save data: Use iesave to save the clean data and create a report 
		iesave 	???  
				
	restore			
	
*-------------------------------------------------------------------------------	
* Tidy Data: Secondary data
*------------------------------------------------------------------------------- 	
	
	* Import secondary data 
	???
	
	* reshape  
	reshape ???
	
	* rename for clarity
	rename ???
	
	* Fix data types
	encode ???
	
	* Label all vars 
	lab var district "District"
	???
	???
	???
	
	* Save
	keeporder ???
	
	save "${data}/Intermediate/???.dta", replace

	
****************************************************************************end!
	
