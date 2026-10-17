/*----------------------------------------------------------*/
/*  IMPORTING THE DATA                                      */
/*----------------------------------------------------------*/
/* Before you run in you computer change the path for dataset here */
FILENAME REFFILE "/home/u63531932/STAT395/ASSIGNMENT/SAYP data.xlsx";

PROC IMPORT DATAFILE=REFFILE
    DBMS=XLSX 
    OUT=WORK.IMPORT
    REPLACE;
    SHEET="SURVEY"; 
    GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; 
RUN;

/* View imported table */
%web_open_table(WORK.IMPORT);

/*----------------------------------------------------------*/
/*  SETTING GLOBAL PARAMETERS                               */
/*----------------------------------------------------------*/
%let seed = 202504;            /* Using year and group number for seed for reproducibility */
%let n_sample = 300;		   /* Standard sample size for all methods */

/*----------------------------------------------------------*/
/*  CLEANING AND RENAMING DATA                              */
/*----------------------------------------------------------*/
data work.import_clean;
    set work.import;

    /* Remove rows where Q72TIME is missing or blank */
    if missing(Q72TIME) then delete;
    else if strip(put(Q72TIME, best.)) = '' then delete;

    /* Rename important variables */
    rename
        Q72TIME      = Hours_Household
        Q22Attend    = School_Attendance
        Child_Labour = ChildLabour
        Q12Gender    = Gender;    
run;

	/* Check total number of records after cleaning */
proc sql;
    title "Number of Observations After Data Cleaning";
    select count(*) as N label="N"
    from work.import_clean;
quit;

/*----------------------------------------------------------*/
/*  CREATE BINARY VARIABLES FOR ANALYSIS                    */
/*----------------------------------------------------------*/
/* For categorical variables that we are going to use */
data work.import_clean;
    set work.import_clean;

    /* Binary for school attendance: 1 = enrolled, 0 = not enrolled */
    if School_Attendance = 1 then Enrolled = 1;
    else if School_Attendance = 2 then Enrolled = 0;
    else Enrolled = .;

    /* Binary for child labour: 1 = involved, 0 = not involved */
    if ChildLabour = 1 then Labour_Involved = 1;
    else if ChildLabour = 2 then Labour_Involved = 0;
    else Labour_Involved = .;
    
    /* Assign clear variable labels */
    label
        Hours_Household = "Average Hours of Household Activities"
        Enrolled         = "Adolescents Enrolled in School"
        Labour_Involved  = "Children Engaged in Labour Activities";
run;

/*----------------------------------------------------------*/
/*  SIMPLE RANDOM SAMPLING WITH REPLACEMENT (SRSWR)         */
/*----------------------------------------------------------*/
proc surveyselect data=work.import_clean    /* Using our cleaned data*/
    method=urs                              /* Unrestricted Random sampling(With Replacement) */
    sampsize=&n_sample                      /* Sample size */
    seed=&seed								/* Our seed =202504 */
    outhits									/* Including hit counts for units selected multiple times */
    out=srswr_sample                        /* Output dataset name */
    stats;									/* Including sampling statistics */
    title "Simple Random Sampling with Replacement (SRSWR)";
run;

proc print data=srswr_sample (obs=10);				 /* Output the first 10 observations from the sample */
    title "SRSWR Sample (first 10 observations)";
run;

proc surveymeans data=srswr_sample mean clm sum clsum;   /* Estimating population parameters using Numbershits as sampling weight */ 
    weight NumberHits;                                   /* using NumberHits */
    var Hours_Household Labour_Involved;                 /* Variables to analyse (Avrg hours and Total in Labour) */
    title "SRSWR: Average Hours and Total Children in Labour";
run;

/* Calculate percentage enrolled */
proc surveymeans data=srswr_sample mean clm;     /* Estimating population proportion of children enrolled */
    weight NumberHits;
    var Enrolled;                                /* Variable to estimate it proportion */
    title "SRSWR: Proportion of Adolescents Currently Enrolled in School";
run;

/*----------------------------------------------------------*/ 
/* CLUSTER SAMPLING (BY PROVINCE) */
 /*----------------------------------------------------------*/ 
proc sort data=work.import_clean out=provnc_unique(keep=Province) nodupkey;    /* Using our cleaned data and cluster by Province*/
	by Province; 
run; 
proc surveyselect data=provnc_unique         /* Using province as our cluster */
	method=srs 							     /* Method is simple random sampling  */
	sampsize=5 								 /* Number of clusters to select */
	seed=&seed 								 /* Our seed =202504 */
	out=sel_province; 						 /* Output dataset */
run; 

/* Creating a table for clusters */
proc sql;                               /* Start SQL procedure */
	create table cluster_sample as      
	select i.* 							/* Select all columns from import_clean */
	from work.import_clean i 
	inner join sel_province j 			/* Join with sel_province as j */
		on i.Province = j.Province; 	/* Join condition on Province */
quit;                                   /* End SQL procedure */

proc print data=sel_province;                /* Showing which clusters were selected */
	title "Selected Provinces (Clusters)"; 
run; 

proc print data=cluster_sample (obs=10);           /* Output the first 10 observations from the sample */
	title "Cluster Sample (first 10 observations)"; 
run; 

proc surveymeans data=cluster_sample mean clm sum clsum;   /* Estimating population parameters */
	cluster Province; 									   /* Specifying the cluster used */
	var Hours_Household Labour_Involved;                   /* Variables to analyse (Avrg hours and Total in Labour) */
	title "Cluster Sampling: Mean Hours and Total Children in Labour"; 
run;


/* Calculate percentage enrolled */
proc surveymeans data=cluster_sample mean clm;				/* Estimating population proportion of children enrolled */
    cluster Province;										/* Specifying the cluster used */
    var Enrolled;											/* Variable to estimate it proportion */
    title "Cluster Sampling: Proportion of Adolescents Currently Enrolled in School";
run;

/*----------------------------------------------------------*/
/*  STRATIFIED SAMPLING (BY GENDER)                         */
/*----------------------------------------------------------*/
proc sort data=work.import_clean out=data_sorted;
    by Gender;										/* Define the cluster variable */
run;

/* Showing clusters */
proc freq data=data_sorted;							
    tables Gender;
    title "Stratum Sizes by Gender";
run;

proc surveyselect data=data_sorted
    method=srs            					/* Simple random sampling with each stratum */               
    sampsize=&n_sample                  	/* Same sample size as other methods */  
    seed=&seed
    out=strat_sample;						/* Output dataset */
    strata Gender / alloc=proportional; 	/* Stratify by Type with proportional allocation */
    title "Stratified Random Sampling by Gender";
run;

/* Display sample allocation by stratum */
proc freq data=strat_sample;
    tables Gender;
    title "Sample Allocation by Gender";
run;

/* Output the first 10 observations from the sample */
proc print data=strat_sample (obs=10);
    title "Stratified Sample (first 10 observations)";
run;

proc surveymeans data=strat_sample mean clm sum clsum;				/* Estimating population parameters */
    strata Gender;													/* Specify stratification variable */
    weight SamplingWeight;											/* Use sampling weights */
    var Hours_Household Labour_Involved;                            /* Variables to analyse (Avrg hours and Total in Labour) */
    title "Stratified Sampling: Population Parameter Estimates (Hours and Labour)";
run;

/* Calculate percentage enrolled */
proc surveymeans data=strat_sample mean clm;
    strata Gender;												   /* Specify stratification variable */
    weight SamplingWeight;										   /* Use sampling weights */
    var Enrolled;                                                  /* Variable to estimate it proportion */
    title "Stratified Sampling: Proportion of Adolescents Currently Enrolled in School";
run;

/*----------------------------------------------------------*/
/*  SIMPLE RANDOM SAMPLING WITHOUT REPLACEMENT (SRSWOR)     */
/*----------------------------------------------------------*/
proc surveyselect data=work.import_clean
    method=srs                             /* Simple Random Sampling (without replacement) */
    sampsize=&n_sample					   /* Sample size */
    seed=&seed
    out=srswor_sample                      /* Output dataset name */
    stats;                                 /* Including sampling statistics */
    title "Simple Random Sampling Without Replacement (SRSWOR)";
run;

/* Output the first 10 observations from the sample */
proc print data=srswor_sample (obs=10);
    title "SRSWOR Sample (First 10 Observations)";
run;

proc surveymeans data=srswor_sample mean clm sum clsum;            /* Estimating population parameters */
    weight SamplingWeight;                                         /* Use sampling weights */
    var Hours_Household Labour_Involved;                           /* Variables to analyse (Avrg hours and Total in Labour) */
    title "SRSWOR: Mean Hours and Total Children in Labour";
run;

/* Calculate percentage enrolled */
proc surveymeans data=srswor_sample mean clm;
    weight SamplingWeight;                                        /* Use sampling weights */
    var Enrolled;											      /* Variable to estimate it proportion */
    title "SRSWOR: Proportion of Adolescents Currently Enrolled in School";
run;






