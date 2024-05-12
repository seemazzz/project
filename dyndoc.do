<<dd_version: 2>>     
<<dd_include: header.txt>>

# Stata Sytax and Analysis for My Project 

## Survival Analysis: Non-Parametric and Semi-Parametric Analysis

### By- Seema Subedi

**==============================================================================================***	
**<p style="text-align: center;">Thursday May 2, 2024: Assigment 6 for Stata Intermediate Class (Project.do File)</p>**

**<p style="text-align: center;">Saturday May 11 2024: Updated for Assignment 7 </p>**
**=============================================================================================***


*************************************************************************************************
************* Data HouseKeeping******************************************************************
*************************************************************************************************

```
<<dd_do:nooutput>>
** Clear all
    cls
    clear all
    
** Set Working Directory 
    * Present working directory
    pwd
    cd "/Users/seemasubedi/Library/CloudStorage/OneDrive-JohnsHopkins/PHD CLASSES.nosync/4th Term/2. STATA PROGRAMMING/Assignments/HW6_Stata_Intermediate"
    pwd
    
    * Set present working directory as the working directory
        if c(os)=="Windows" { //method for window
            global workdir "`c(pwd)'\"
        }
        else { // method for mac 
            global workdir "`c(pwd)'/"
        }
      
** Get ready with the links to get the datasets   
    ** Creating golbal macro for the repository path
        global repo "https://raw.githubusercontent.com/seemazzz/project_hw6/main/"
        
    ** Creating global macro for the Nhanes website for datasets
        global nhanes "https://wwwn.cdc.gov/Nchs/Nhanes/"

** Get the analytica data ready
    
    ** Running the do file called "followup.do" from the repository indicated in global path. 
        **It uses the survey dataset and cleans and labels it to keep  useful for survival analysis (fup, outcome variables etc)
        do ${repo}followup.do // use braces to avoid issue related to any character like space
        save followup.dta, replace 
        
    ** First, Import the 1999-2000 survey data set from the website and merge with the followup data so that we can have the whole set of variables
        import sasxport5 "${nhanes}1999-2000/DEMO.XPT", clear
        merge 1:1 seqn using followup.dta, nogen // using seqn as the common ID variable
        save survey_followup.dta, replace 
        
    ** Again Import the dataset that has the variable for the self-reported quality of health to use as the main exposure variable in our analysis
        ** And merge wit the main survey_followup.dta
       import sasxport5 "${nhanes}1999-2000/HUQ.XPT", clear
       tab huq010 
       merge 1:1 seqn using survey_followup, nogen keep(matched) // 9965 matched.
    
    ** Delete the  datasets that were created in the middle process, and not needed now
       rm followup.dta
       rm survey_followup.dta
     
    ** Explore some variables
        lookfor follow
        lookfor mortstat permth_int eligstat 
        
        tab eligstat
        codebook eligstat
        //keep if eligstat==1 // onlh keep if eligible (4520 dropped)
        count //5445
<</dd_do>>

```
**********************************************************************************************************
*************Prepare Variables and Set Up  for Survival Analysis *****************************************
**********************************************************************************************************	

```
<<dd_do:nooutput>>
** Prepare Variables for survival analysis: stset (followup time) fail(outcome=1) id(id)
    * Id variable (Respondent's sequence number)
        codebook seqn
        capture drop id
        clonevar id= seqn
        codebook id
    
    * Entry
       capture drop enter
       gen enter=0
       
    * Exit 
       * Follow-Up Time variable (Person-month follow-up from NHANES Interview Date)
        codebook permth_int
        tab permth_int
        
        *Change the FUP time to person-years
        capture gen years=permth_int/12
        label var years "Person-Year FUP from NHANES interview date "
        sum years // 0 to 20.83 PY
        
        *Important Step- Those who have PY=0 will be discarded from survival analysis. So, lets make them 0.5 so that we can retain them in the data
        replace years=0.5 if years==0
   
    * Outcome variable (Final Mortality Status)
        codebook mortstat
        tab mortstat, mi // 69% alive and 31% dead
        
    * Main Independent Variable (Self-reported Health Condition)
        tab huq010, mi //General health condition
            // only 5 observations in 9. SO, lets make them missing
        replace huq010=. if huq010==9
            
        capture label drop huq010
        labe define huq010 1"Excellent" 2"Very Good" 3"Good" 4"Fair" 5"Poor"  //7"Refused" 9"Don't Know"
        label value huq010 huq010
        tab huq010, mi 
        
        * Save levels of the variables in the local macro, so that it is easy for labelling and legend in the figure late
        levelsof huq010, local(numlevels)  // Get unique levels of the variable huq010 and save them in local macro numlevels
        local i = 1  // Initialize a local macro i to 1

        foreach l of numlist `numlevels' {  // Loop over each level (l) in the list of numlevels
            local vallab: value label huq010  // Get the value label associated with variable huq010 and store it in local macro vallab
            local catlab: lab `vallab' `l'  // Get the label associated with the value `l` of variable huq010 and store it in local macro catlab
            global legend`i' = "`catlab'"  // Create a global macro legend`i' containing the label catlab
            local i = `i' + 1  // Increment the value of local macro i by 1 for the next iteration
        }

       
** Set up data for survival analysis
    stset years, fail(mortstat=1) entry(enter) id(seqn) 
    tab _st // No exclusions
    br id enter permth_int years mortstat  
    order id enter permth_int years mortstat  
  
    save week7.dta, replace 
   
   
       
 <</dd_do>>

```
**********************************************************************************************************
*************Do the analysis: Non-Parametric and Semi-Parametric *****************************************
**********************************************************************************************************	

****NON-PARAMETRIC ANALYSIS (KAPLAN MEIER ANALYSIS)****

```
<<dd_do:nooutput>>
    * Graph by heath condition 
  
    clear all
    use week7.dta, clear
            
       sts graph , fail by(huq010) ci ///
        title (Figure:Cumulative Mortality  by Self-Reported Health Status, size())   ///
        legend(size(*0.65) order( 9 "Poor" 7 "Fair" 5 "Good" 3 "Very Good" 1 "Excellent"  ) ///
        cols(1) rows(5) position(0) bplacement(nwest) symxsize(*0.3) symys(*0.3) rowgap(*0.3) region(c(*0.05))) ///
        plotregion(margin(medium)) ///
        plot1opts(lwidth(*0.5) lcolor(red) lpattern(solid)) ///
        plot2opts(lwidth(*0.5) lcolor (blue) lpattern(solid)) ///
        plot3opts(lwidth(*0.5) lcolor(maroon) lpattern(solid)) ///
        plot4opts(lwidth(*0.3) lcolor (green) lpattern(solid)) ///
        plot5opts(lwidth(*0.5) lcolor(orange) lpattern(solid)) ///
        ci1opts(lwidth(none) lcolor(red) fcolor(red) fintensity(5) lpattern(solid)) ///
        ci2opts(lwidth(none) lcolor (blue) fcolor(blue) fintensity(5) lpattern(solid)) ///
        ci3opts(lwidth(none) lcolor(maroon) fcolor(maroon) fintensity(5) lpattern(solid)) ///
        ci4opts(lwidth(none) lcolor (green) fcolor(green) fintensity(5) lpattern(solid)) ///
        ci5opts(lwidth(none) lcolor(orange) fcolor(orange) fintensity(5) lpattern(solid)) ///
        ylabel(, format(%9.2f) labsize(small) nogrid glwidth(small)) ///
        xlabel(0(2)20, labsize(small)) ///
        xtitle("Person Years from Interview", size())  ///
        ytitle("Proportion of mortality (95%CI)", size())

        graph save nonpara.gph, replace
       
<</dd_do>>

``` 

<<dd_graph>>  


****SEMI PARAMETRIC ANALYSIS (COX REGRESSION)****
    
**Semi Parametric:Unadjusted Cox Regression Model (Not adjusted for confounders)**

```
<<dd_do:nooutput>>
        capture drop s0
        stcox i.huq010, basesurv(s0)
        return list
      
        matrix define mat = r(table) // creating a stata matrix "mat" and populating it with the results
        matrix list mat  // listing to show what is in the table
        matrix mat = mat' // transposing the table for easier analysis
        svmat mat // convert to stata dataset
        
        preserve 
        keep mat* //keeping only the variables formed by the process ( beta, SE, 95% CI etc)
        drop if missing(mat1)
        rename (mat1 mat2 mat3 mat4 mat5 mat6 mat7 mat8 mat9)(b se z p ll ul df crit eform)
        capture drop x // Jus to give an ID to each row/observation, so that later we can choose the first 5 rows that has the coefficeints for the main exposure variable (perceived health)
        g x=_n
        replace b=log(b)
        replace ll=log(ll)
        replace ul=log(ul)
        twoway (scatter b x) || ///
               (rcap ll ul x, ///
                   yline(0, lcol(lime)) ///
                   ylab( ///
                       -2.08 "0.125" ///
                       -1.39 "0.25" ///
                       -.69 "0.5" ///
                         0 "1"  ///
                       .69 "2" ///
                       1.39 "4" ///
                       2.08 "8" ///
                       2.78 "16") ///
                   legend(off)  ///
                   title(" ") ///
                   ytitle(" ") ///
                xlab( ///
                   1 "$legend1" ///
                   2 "$legend2" ///
                   3 "$legend3" ///
                   4 "$legend4" ///
                   5 "$legend5") ///
               xti("Self-Reported Health") ///
                   ) 
        graph save semipara_unadj.gph, replace 
        restore 

<</dd_do>>

``` 

**Figure:Unadjusted Hazard Ratio by Self-Reported Health**

<<dd_graph>> 


   
  
 **Semi Parametric:Adjusted Cox Regression Model (Adjusted for confouders as: age, sex, ethnicity/race and number of times of receiving health care over past year  )**
 
```
<<dd_do:nooutput>>    
    
    * Variables to adjust for 
        *Age
            codebook ridageyr // No missing
            hist ridageyr 
            graph export nonpara.png, replace
            //replace ridageyr=ridageyr/10
            
        *Gender
            tab riagendr, mi // No missing
        
        *Ethnicity/Race ( USE THIS)
            tab ridreth1, mi // No missing
           
        *Pregnancy Status at Exam- Recode
            tab ridexprg, mi // 8003 missing (might be non-pregnant)
            
        * Times of receiving health care over past year (USE THIS)
            tab huq050, mi 
            replace huq050=. if huq050==99 // 13 replaced, total 18 missing
        
        * Routine Place to go for health care
            tab huq030, mi
            
        * Type pace most often go for health care
            tab huq040
        
        * Seen Mental Health Professional in the past year
            tab huq090 , mi // 1190 missing
            
        * Annual Household Income
          tab indhhinc, mi // 1518 missing
          
        * Education
          tab dmdeduc, mi // 1559 missing
          

        capture drop s0 
        stcox i.huq010 ridageyr riagendr ridreth1 huq050  , basesurv(s0)
        return list
        matrix define mat_adj=r(table)
        matrix define mat_adj=mat_adj'
        matrix list mat_adj
        svmat mat_adj
        
        preserve
        keep mat_adj*
        drop if missing(mat_adj1)
        rename (mat_adj1 mat_adj2 mat_adj3 mat_adj4 mat_adj5 mat_adj6 mat_adj7 mat_adj8 mat_adj9)(b se z p ll ul df crit eform)
        g x=_n
        replace b=log(b)
        replace ll=log(ll)
        replace ul=log(ul)
        twoway (scatter b x if inrange(x,1,5)) || ///
               (rcap ll ul x if inrange(x,1,5), ///
                   yline(0, lcol(lime)) ///
                   ylab( ///
                       -2.08 "0.125" ///
                       -1.39 "0.25" ///
                       -.69 "0.5" ///
                         0 "1"  ///
                       .69 "2" ///
                       1.39 "4" ///
                       2.08 "8" ///
                       2.78 "16") ///
                   legend(off)  ///
                   title(" ") ///
                    note("Note:Adjusted for age, sex, ethnicity/race and times of receiving health care over past year", size(*0.9)) ///
                   ytitle(" ") ///
                xlab( ///
                   1 "$legend1" ///
                   2 "$legend2" ///
                   3 "$legend3" ///
                   4 "$legend4" ///
                   5 "$legend5") ///
               xti("Self-Reported Health") ///
                   ) 
        graph save semipara_adj.gph, replace 
        restore

<</dd_do>>

``` 

**Figure:Adjusted Hazard Ratio by Self-Reported Health**

<<dd_graph>>  

****Comparision of Adjusted and Unadjusted Effects ( Hazard Ratio)****

 ```
<<dd_do:nooutput>>  
    
    graph combine semipara_unadj.gph semipara_adj.gph, ///
	rows(1) ///
    xcommon ti("Figure:Unadjusted vs Adjusted Hazard Ratio (95%CI)")
    graph save unadj_adj.gph, replace  
    
    
    
<</dd_do>>

``` 
<<dd_graph>> 


**Comment on the Adjusted Versus Unadjusted Hazard Ratio (HR)**

Self-reported health has significant association with mortality.
Lower the self-reported health status, higher the risk or mortality.
In the unadjusted model,the effects size(HR) were higher. But, after adjusting for the confounders,
the effect size decreased.
Example: In the unadjusted model, those who self-reported poor health had 7.5 times higher risk of mortality
as compared to those who self-reported excellent health , 
but the effect size decreased to 3.6 (HR=3.6) in the adjusted model. 
So, it is important to adjust for the relevant counfounders in such analysis.
 


**Specific Scenario: A 40-year male who self-reported being in "Good Health" (huq010=3)**
 
 ```
<<dd_do:nooutput>>  
//     
    cls
    clear all
    use week7, clear
    replace riagendr=riagendr-1
    stcox i.huq010 ridageyr riagendr, basesurv(s0)
    keep s0 _t _t0 _st _d 
    save s0, replace 
    ereturn list 
    matrix beta = e(b)
    matrix vcov = e(V)
    matrix SV = ( ///
        0, ///
        1, ///
        0, ///
        0, ///
        0, ///
        40, ///
        1 ///
    )
    matrix SV_ref = ( ///
        0, ///
        1, ///
        0, ///
        0, ///
        0, ///
        60, ///
        1 ///
    )
    //absolute risk
    matrix risk_score = SV * beta'
    matrix list risk_score
    di exp(risk_score[1,1])
    matrix var_prediction = SV * vcov * vcov'
    matrix se_prediction = sqrt(var_prediction[1,1])

    matrix risk_score_ref = SV_ref * beta'
    matrix list risk_score_ref
    di exp(risk_score_ref[1,1])
    matrix var_prediction_ref = SV_ref * vcov * vcov'
    matrix se_prediction_ref = sqrt(var_prediction_ref[1,1])

    local hr = exp(risk_score_ref[1,1])/exp(risk_score[1,1])
    di `hr'

    //di "We conclude that `exp(risk_score[1,1])'"

    //
    g f0 = (1 - s0) * 100 
    g f1_ = f0 * exp(risk_score[1,1])
   
   line f1 _t , ///  
        sort connect(step step) ///
        legend(ring(0)) ///
        ylab(0(5)20) xlab(0(5)20) ///
        yti("") ///
        ti("Figure:Risk of mortaltity(%) in a 40-year male who reported Good Health", size(*0.85)pos()) ///
        xti("Person Years from Interview") ///
        note(" "  ,size()  ///
                     )
    graph save scenario.jpg, replace 
    
    
<</dd_do>>

``` 

<<dd_graph>>

