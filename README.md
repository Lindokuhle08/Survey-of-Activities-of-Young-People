
# Estimation of Adolescent Household Hours, School Attendance, and Child Labour in South Africa Using Probability Sampling Methods.

This report uses data from the **Survey of Activities of Young People (SAYP)** to explore how adolescents in South Africa spend their time. The aim is to estimate the **average hours** spent on household responsibilities, the **percentage enrolled in school**, and the **total number involved in child labour**. To achieve this, four probability sampling methods — Simple Random Sampling with and without replacement, Stratified Sampling (by gender), and Cluster Sampling (by province), were applied to produce representative estimates of the population.

## Objectives

The main objectives of this study are:

1. To estimate the average number of hours adolescents, dedicate to household responsibilities.

2. To determine the percentage of adolescents currently enrolled in school.

3. To determine the total number of children engaged in labour activities in South Africa.

4. To compare the estimates obtained from four probability sampling methods and identify the most efficient method.

## Methods

The study used four probability sampling methods to estimate the average household hours, the percentage of enrolled adolescents, and the total number of children involved in labour.
_______________________________________________________________________________________________________________________________________________
| Sampling Method        | Description                                                                   | Key SAS Procedure                   |
|------------------------|------------------------------------------------------------------------------ |-------------------------------------|
| Simple Random Sampling | Each observation had an equal chance of being selected, without replacement.  | method=srs                          |
|   (Without Replacement)|                                                                               |                                     |
-----------------------------------------------------------------------------------------------------------------------------------------------|
| Simple Random Sampling | Random selection with replacement                                             | method=urs                          |
|   (With Replacement)   |                                                                               |                                     |
-----------------------------------------------------------------------------------------------------------------------------------------------|
| Stratified Sampling    | Data divided by Gender proportional allocation                                | Strata Gender /<br>alloc=proportion |
|----------------------------------------------------------------------------------------------------------------------------------------------|
| Cluster Sampling       | Provinces selected as clusters, all children within chosen provinces included | cluster Province                    |
|----------------------------------------------------------------------------------------------------------------------------------------------|

The data used in this analysis was obtained from the Survey of Activities of Young People (SAYP). The original dataset contained **13,336 observations**. After cleaning; by removing observations with missing values for the variable **Hours_Household** (Q72TIME); a total of **9,968 valid observations remained**. From this cleaned dataset, a **sample size of 300** was selected for each of the four probability sampling methods applied in the study.

## Key variables were renamed:

- Q72TIME → Hours_Household

- Q22Attend → School_Attendance

- Child_Labour → ChildLabour

- Q12Gender → Gender

Binary variables were created:

A binary variable (Enrolled) was created from School_Attendance, where a value of **1** indicated that a child was enrolled in school and **0** otherwise. Similarly, ChildLabour was coded such that **1** represented involvement in child labour and **2** indicated not involved.

## Results

The following table summarizes the estimates from all four sampling methods.
_______________________________________________________________________________________________
|                              Variables                                                      |
-----------------------------------------------------------------------------------------------
|                     | Hours_Household        | School_Attendance     | ChildLabour          |
|---------------------|------------------------|-----------------------|----------------------|
| Sampling Methods    | Mean (95% CI)          | Prop (%) (95% CI)     | Total (95% CI)       |
|---------------------|------------------------|-----------------------|----------------------|
| SRS (WR)            | 3.99 (3.24; 4.75)      | 99.34 (98.42; 100)    | 20.00 (11.48; 28.52) |
|---------------------|------------------------|-----------------------|----------------------|
| SRS (WOR)           | 3.27 (2.89; 3.65)      | 99.00 (97.86; 100)    | 332.27 (128.63; 536) |
|---------------------|------------------------|-----------------------|----------------------|
| Stratified Sampling | 4.15 (3.38; 4.92)      | 98.00 (96.40; 99.59)  | 531.59 (276.4; 787)  |
|---------------------|------------------------|-----------------------|----------------------|
| Cluster sampling    | 3.91 (3.25; 4.59)      | 98.78 (98.39 ;99.17)  | 475 (116.30; 833.70) |
-----------------------------------------------------------------------------------------------

## Discussion and Conclusion

The results from the four sampling methods show similar patterns across all variables. Average hours spent on household work ranged from 3.27 to 4.15 hours, with stratified sampling giving the highest mean, suggesting it better captured variation between groups.

School attendance was consistently high across all methods (around 98–99%), indicating most adolescents are enrolled in school regardless of sampling design.

However, the total number of children in labour varied, with stratified and cluster sampling giving higher totals compared to simple random sampling.

Overall, stratified sampling provided the most balanced and reliable estimates, making it the best method for representing the population accurately.


**Group Members:**
- Lindokuhle Machangu
- Sthembelo Meyiwa
- Luyanda Myeza
- Phakamani Majola
