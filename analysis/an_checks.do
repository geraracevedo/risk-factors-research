********************************************************************************
*
*	Do-file:		an_checks.do
*
*	Project:		Risk factors for poor outcomes in Covid-19
*
*	Programmed by:	Elizabeth Williamson
*
*	Data used:		egdata.dta
*
*	Data created:	None
*
*	Other output:	Graphs (cumulative events by time in study):
*						output/events_died.png
*						output/events_hosp.png
*						output/events_itu.png
*
*					Log file: output/an_checks
*
********************************************************************************
*
*	Purpose:		This do-file runs a series of checks and creates a log 
*					file to record them:
*						- check variables take expected values/ranges
*						- cross-check logical relationships
*						- explore expected relationships
*						- check stsettings
*  
********************************************************************************



* Open a log file
capture log close
log using "output/an_checks", text replace

* Open Stata dataset
use egdata, clear



******************************************
*  Check variables take expected values  *
******************************************

* Age
datacheck age<., nol
*assert inrange(age, 18, 105)
datacheck inlist(agegroup, 1, 2, 3, 4, 5, 6), nol
datacheck inlist(age70, 0, 1), nol

* Sex
datacheck inlist(male, 0, 1), nol

* BMI 
* assert inrange(bmi, 10, 200) | bmi==.
datacheck inlist(obese40, 0, 1), nol
datacheck inlist(bmicat, 1, 2, 3, 4, 5, 6, .u), nol

* IMD
datacheck inlist(imd, 1, 2, 3, 4, 5, .u), nol

* Ethnicity
datacheck inlist(ethnicity, 1, 2, 3, 4, 5, .u), nol

* Smoking
datacheck inlist(smoke, 1, 2, 3, .u), nol
datacheck inlist(currentsmoke, 0, 1), nol

* Blood pressure
datacheck inlist(bpcat, 1, 2, 3, 4, .u), nol



***************************************
*  Cross-check logical relationships  *
***************************************


* BMI
bysort bmicat: summ bmi
tab bmicat obese40, m

* Age
bysort agegroup: summ age
tab agegroup age70, m

* Smoking
tab smoke currentsmoke, m



*********************
*  Summarise dates  *
*********************

* BMI
summ bmi_date_measured, format

* Dates of comorbidities  
foreach var of varlist 	chronic_respiratory_disease 	///
						chronic_cardiac_disease 		///
						diabetes 						///
						lung_cancer 					///
						haem_cancer						///
						other_cancer 					///
						bone_marrow_transplant 			///
						chemo_radio_therapy 			///
						chronic_liver_disease 			///
						neurological_condition 			///
						chronic_kidney_disease 			///
						organ_transplant 				///	
						dysplenia						///
						sickle_cell 					///
						ra_sle_psoriasis  {

	summ `var'_date, format
	bysort `var': summ `var'_date
}



* Outcome dates
*****??? 




****************************************
*  Cross-check expected relationships  *
****************************************

* everything vs each demographic/lifestyle
* (i.e. vs age, sex, smoke, bmi cat, imd)

/*  Relationships between demographic/lifestyle variables  */

* agegroup, male, smoke, bmicat, imd, ethnicity


/*  Relationships with demographic/lifestyle variables  */

* Relationships with age
foreach var of varlist 	chronic_respiratory_disease 	///
						asthma 							///
						chronic_cardiac_disease 		///
						diabetes 						///
						lung_cancer 					///
						haem_cancer						///
						other_cancer 					///
						bone_marrow_transplant 			///
						chemo_radio_therapy 			///
						chronic_liver_disease 			///
						neurological_condition 			///
						chronic_kidney_disease 			///
						organ_transplant 				///	
						spleen							///
						immunosuppressed 				///
						ra_sle_psoriasis  				{
	tab agegroup `var', r
}


* Relationships with sex
foreach var of varlist 	chronic_respiratory_disease 	///
						asthma							///
						chronic_cardiac_disease 		///
						diabetes 						///
						lung_cancer 					///
						haem_cancer						///
						other_cancer 					///
						bone_marrow_transplant 			///
						chemo_radio_therapy 			///
						chronic_liver_disease 			///
						neurological_condition 			///
						chronic_kidney_disease 			///
						organ_transplant 				///	
						spleen							///
						immunosuppressed 				///
						ra_sle_psoriasis  				{
	tab male `var', r
}


/*  Relationships between conditions  */


* Respiratory
tab chronic_respiratory_disease asthma 

* Cardiac
tab diabetes chronic_cardiac_disease
*tab chronic_cardiac_disease bpcat







********************************************
*  Cross-check logical date relationships  *
********************************************

* Cross check dates of hosp/itu/death??






*****************************
*  Check survival settings  *
*****************************

* Death
stset stime_died, fail(died) enter(enter_date) origin(enter_date) id(patient_id) 
sort _t
gen cum_died = sum(_d)
line cum_died _t, sort(_t)
graph export "output/events_died.eps", replace as(eps)

* Hospitalised for Covid
stset stime_hosp, fail(hosp) enter(enter_date) origin(enter_date) id(patient_id) 
sort _t
gen cum_hosp = sum(_d)
line cum_hosp _t, sort(_t)
graph export "output/events_hosp.eps", replace as(eps)


* ITU admission for Covid
stset stime_itu, fail(itu) enter(enter_date) origin(enter_date) id(patient_id) 
sort _t
gen cum_itu = sum(_d)
line cum_itu _t, sort(_t)
graph export "output/events_itu.eps", replace as(eps)





* Close log file 
log close


