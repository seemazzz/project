<p align="center">
  <img src="https://github.com/seemazzz/project/blob/main/letsdoaproject.png" width="400"/>
</p>



#  Project for Stata II (Intermediate)

## SURVIVAL ANALYSIS: (Does self-reported health status predict mortality? )

### *By- Seema Subedi (Created on May 2, 2024)*


### 1. Purpose of the Project:
  We are creating this project so that we can keep working for the next 3 weeks on survival analysis to assess if the self-reported health status
  can predict mortality.
 Other collaborators are welcome to contribute by adding their inputs to `read.me` file in [my PROJECT repository](https://raw.githubusercontent.com/seemazzz/project_hw6/main/)
  and putting a comment while committing changes. 
  
### 2. Description of Data Source:
  We will use the different data from [National Health and Nutrition Examination Survey](https://www.cdc.gov/nchs/nhanes/index.htm) for this project.
  - This is the [NHANES SURVEY DATASET](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DEMO.XPT)
  - This is the link to [NHANES MORTALITY DATASET](https://ftp.cdc.gov/pub/HEALTH_STATISTICS/NCHS/datalinkage/linked_mortality/)
    - Use `NHANES_1999_2000_MORT_2019_PUBLIC.dat`'
  
    
### 3. Description of what was done to use the different datasets and create an ANALYTICAL DATASET
   
  **3.1. Downloaded a do-file, edited and uploaded in my repository:** 
   - First, [a do-file from NHANES website](https://ftp.cdc.gov/pub/HEALTH_STATISTICS/NCHS/datalinkage/linked_mortality/Stata_ReadInProgramAllSurveys.do) was downloaded and 
    edited for the directory path,  and renamed as `followup.do` and posted in my repository so that it can be run directly from the remote repository. 
    You can see what changes were made through clicking `history` in the 
    right corner of [followup.do](https://github.com/seemazzz/project/commits/main/followup.do) file.
        
  **3.2. Then, worked remotely from the repository to create the final dataset that we need:**
  - Ran the `followup.do` file remotely from my github repo, and it created a dataset named `followup.dta`
          
     ```
     global repo "https://raw.githubusercontent.com/seemazzz/project_hw6/main/" 
          do ${repo}followup.do 
          save followup, replace 
    ```


```
Quick look on what the followup.do file executed:
    - Asked to enter our present working directory
    - Then, downloaded the NHANES SURVEY DATASET (NHANES_1999_2000)
    - Cleaned and labelled variables and created a dataset called "NHANES_1999_2000_PUF" in our working directory
```
      
  **3.3. Then, merged the `followup.dta` with another dataset:**
   - We imported the NHANES mortality dataset.
   - We merged this dataset to the `followup.dta` in our directory, using the id variable `seqn`.
   - The imported dataset has 9965 observations and 152 variables
        
        ```
        import sasxport5 "https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/DEMO.XPT", clear
        merge 1:1 seqn using followup
        ```
     
### 4. Be prepared for the next weeks
   - Get familiar with the datasets and variables
       - We can look at the [data documentation and codebook](https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/HUQ.htm) for more information on variables
   - We specially need these variables:
     - Id variable: `seqn`
     - Exit Variable: `permth_int` This is person-month, change it into person-years
     - Outcome Variable: `mortstat` This is the Final Mortality Status-only keep those who are eligible
     - Main Independent Variale: `uq010` This is the self-reported health status
     - Other independent Variables: Need to explore more
   - We will do different anaysis
        - Do survival analysis and make cumulative mortality curves by the main independent variable
        - Do both unadjusted and adjusted cox regressions 
   - We will include results and graphs from the analysis here
    
   
        
        

  
  



