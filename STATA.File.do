* Further Econometrics and Data Analysis - Research Paper Cleaning Dataset Do.File

* Cleaning the Dataset

rename pidp id

tab ghq
* This is the dependent variable, a scale of mental distress from 0 (least distressed) to 36 (most distressed) - need to recode and reverse the distress measurement scale, so that a larger value on the scale corresponds to better wellbeing / mental health
gen ghqrev = 36-ghq
tab ghqrev
* This process leaves the variable measurement more in line with the literature, variable of mental distress is coded so more distress = higher value (0-36), running this process flips this, so more distress = lower value, and a higher value is more happiness. 

tab region
* Student number is 100387171 (final digit 1) - corresponds to regions 'North West' and 'North East'
* Region variable coded 1-9. Regions specific to me are coded 1 and 2, need to eliminate other regions:
replace region=. if region>2
tab region
* North West accounts for about 3/4 of this restricted panel, with North East accounting for the remaining 1/4

tab marryst
recode marryst (2/3=1 "married") (1 4/10=0 "not married"), gen (married)
tab married 
tab married, nolabel 
* Good split of the dataset, 55%/45% favours those who are married 

tab age
* Include c.age##c.age in all estimators, apart from FE with time dummy (multicollinearity)
* Important to include quadratic functional form of age variable to investigate the U-shaped relationship between age and wellbeing
gen age2 = c.age#c.age
tab age2


tab istrtdatd
rename istrtdatd int_day
tab istrtdatm
rename istrtdatm int_month
tab istrtdaty
rename istrtdaty int_year
* For simplicity

gen interview_date = dmy(int_day, int_month, int_year)
format interview_date %td
* Converts numerical value of interview date variable into date format

tab jbstat
recode jbstat (2=1 "paid employment") (1 3/97=0 "other type of employment"), gen (jobstatus)
tab jobstatus
tab jobstatus, nolabel
* Once again, very good split of near enough 50%/50%, clear analysis between employed and other types of labour force status

tab race
recode race (1=1 "white") (2/97=0 "not white"), gen (ethnicity)
tab ethnicity
* As white corresponds to a large group of this panel, can be compared to other less-represented ethnic groups

drop gincome
codebook nincome
gen lincome = log(nincome)
codebook lincome
* Decided to include nincome opposed to gincome as literature discusses the further wellbeing effects on taxed income, but also the wellbeing benefits tax paying contributes to (public infrastructure, services etc).

* Time only includes waves
tab time
generate timea = .
replace timea = time if time >= 1 & time <= 3
tab timea
generate timeb = .
replace timeb = time if time >= 4 & time <= 5
tab timeb
* Two separate variables have now been formed of waves 7 8 9 for the first section, and 10 11 for the second section of the assignment
label define wave_labels 1 "Wave 7" 2 "Wave 8" 3 "Wave 9" 4 "Wave 10" 5 "Wave 11"
label values timea wave_labels
label values timeb wave_labels
tab timea
tab timeb
* Recoded so that each category no longer refers to a "time" period, but now the associated wave (timea is affiliated to part a of the project, and timeb is affiliated with part b of the project)

tab children
* Rename to kids to use label children as recoded:
rename children kids
recode kids (1/8=1 "has children") (0=0 "no children"), gen(children)
tab children
* Splits the children variable into binary, with no children as the absence of the characteristic (base), lots of literature on children influencing positive emotions and happiness during hardship. 

tab educat
replace educat=. if educat==9
recode educat (2=1 "other higher degree") (1=2 "degree") (3=3 "a-level") (4=4 "gcse") (5=5 "other"), gen(education)
tab education
* Can evaluate mental distress across all the categories, but include other and no qualifications in the same category. 
* Must remember to include i(3).education in models to have a-level as the base group (middle ground)


* Further Econometrics and Data Analysis - Research Paper Analysis Do.File Part (a)

* Re-watch the lecture recording of week 12 optional lecture (EC0-6003A - Review Question)

* Pre-analysis setup:

* Need to restrict the sample to the balanced one and create all necessary variables
bysort id: generate T=_N
* bysort id groups the dataset by the individual identifier variable (represents individual panels), T is the name of the new variable generated, and _N is a system variable that represents the number of observations in the current group, defined by id.

keep if T==5
* As T is the individual identifier in each wave, eliminating the observations that dont appear once across all 5 periods, essentially balancing the panel.

xtset id timea
* Informs STATA the data analysis is to be done through Panel Data - where pidp is the individual identifier, and wave is the time periods (for the waves associated with part a of the assignment)


// Pooled Ordinary Least Squares Estimator:

reg ghqrev lincome ib(3).education jobstatus c.age##c.age married children male ethnicity timea
estimates store POLS

reg ghqrev lincome ib(3).education jobstatus c.age##c.age married children male ethnicity timea, vce(cluster id)
estimates store POLS_cluster

esttab POLS POLS_cluster using POLS.rtf, replace se r2 star(* 0.1 ** 0.05 *** 0.01) title ("POLS vs POLS_cluster") obslast mtitles compress

// Random Effects Estimator:

xtreg ghqrev lincome ib(3).education jobstatus c.age##c.age married children male ethnicity timea, theta
estimates store RE

xtreg ghqrev lincome ib(3).education jobstatus c.age##c.age married children male ethnicity timea, vce(cluster id) theta
estimates store RE_cluster

esttab POLS_cluster RE RE_cluster using RE.rtf, replace se r2 star(* 0.1 ** 0.05 *** 0.01) title ("POLS vs RE") obslast mtitles compress			


// Fixed Effects Estimator:

* Without time index:

xtreg ghqrev lincome ib(3).education jobstatus c.age##c.age married children male ethnicity, fe vce(cluster id)
estimates store FE_notime

* With time index but removing linear functional form of age:
xtreg ghqrev lincome  ib(3).education jobstatus c.age#c.age married children male ethnicity timea, fe vce(cluster id)
estimates store FE_noage

* With time index dummies:
xtreg ghqrev lincome  ib(3).education c.age#c.age jobstatus married children male ethnicity i.timea, fe vce(cluster id)
estimates store FE_timedummy

esttab RE_cluster FE_notime FE_noage FE_timedummy using RE_FE.rtf, replace se r2 star(* 0.1 ** 0.05 *** 0.01) title ("RE vs FE") obslast mtitles compress

xttrans education
xttab education


// Correlated Random Effects Estimator:

* First need to generate the individual specific means for the time variant variables:

tab education, gen(educ)

bysort id: egen mlincome=mean(lincome)
bysort id: egen mage=mean(age)
bysort id: egen mage2=mean(age2)
bysort id: egen meduc1=mean(educ1)
bysort id: egen meduc2=mean(educ2)
bysort id: egen meduc3=mean(educ3)
bysort id: egen meduc4=mean(educ4)
bysort id: egen meduc5=mean(educ5)
bysort id: egen mjobstatus=mean(jobstatus)
bysort id: egen mmarried=mean(married)
bysort id: egen mchildren=mean(children)

* Running the CRE, Mundlak Approach:

xtreg ghqrev lincome  ib(3).education jobstatus age2 married children male ethnicity mlincome mage mage2 meduc1 meduc2 meduc4 meduc5 mjobstatus mmarried mchildren timea, re vce(cluster id)

estimates store CRE

esttab CRE FE_noage using CRE_FE.rtf, replace se r2 star(* 0.1 ** 0.05 *** 0.01) title ("CRE vs FE with variable age excluded") obslast mtitles compress

* The above CRE should give the same results as the following FE model:
xtreg ghqrev lincome  ib(3).education jobstatus c.age#c.age married children male ethnicity timea, fe vce(cluster id)

* Regression based Hausman Test:

* without heteroskedasticity and serial correlation robust SEs

xtreg ghqrev lincome  ib(3).education jobstatus c.age#c.age married children male ethnicity mlincome mage mage2 meduc1 meduc2 meduc4 meduc5 mjobstatus mmarried mchildren timea, re 

test mlincome mage mage2 meduc1 meduc2 meduc4 meduc5 mjobstatus mmarried mchildren

* chi2( 10) =  177.64
* Prob > chi2 =    0.0000 

* with heteroskedasticity and serial correlation robust SEs

xtreg ghqrev lincome  ib(3).education jobstatus c.age#c.age married children male ethnicity mlincome mage mage2 meduc1 meduc2 meduc4 meduc5 mjobstatus mmarried mchildren timea, re vce(cluster id)

test mlincome mage mage2 meduc1 meduc2 meduc4 meduc5 mjobstatus mmarried mchildren

* chi2( 10) =  147.55
* Prob > chi2 =    0.0000

* Breusch Pagan Lagrangian Multiplier:

reg ghqrev lincome ib(3).education jobstatus c.age##c.age married children male ethnicity timea, vce(cluster id)

xtreg ghqrev lincome ib(3).education jobstatus c.age##c.age married children male ethnicity timea, vce(cluster id) theta

xttest0


* Further Econometrics and Data Analysis - Research Paper Analysis Do.File Part (b)

tab married
* So, 18196 respondents were not married out of 27948
* Treatment group - those who are married (34.89%)
* Control group - those who are not married (65.11%)


ttest ghqrev, by(married) unequal
* Estimates suggests that married respondents report 1.022006 more utility points on average than not married respondents during waves 10 and 11 across the NW and NE of the UK, with statistical significance at the 99% CL. Unequal allows us to control for possible unequal  variance of student performance between treatment and control groups (heteroskedasticity). This difference is statistically different from zero. 

reg ghqrev married, vce(robust)
* We see that this command provides the same results as the t-test. The vce(robust) ontains heteroskedasticity consistent SEs. 


* Most probably, the estimated effect above does not provide an unbiased estimate of the true ATT (that is, it does not represent the causal effect of marriage on the GHQ scores). This is because selection into treatment (married) is not random. People who are married may be quite different in terms of both observed and unobserved characteristics from those who are not married. 
  
* To see this, we can summarise the means of our observed characteristics for both married and not married respondents:

sum male ethnicity age education jobstatus if married==1
sum male ethnicity age education jobstatus if married==0

* Or run a probit regression to evaluate probabilities across controls:
probit married male ethnicity age education jobstatus

* Larger means for the gender dummy, ethnicity, and age suggests observable characteristics differ significantly between married and unmarried respondents. Suggests that on average, married individuals tend to be older, white background, and predominantly male. Being older and male increases the likelihood of being married. Alternatively, those who have higher education status and paid employment are less likley to be married. All regressors are statistically significant, suggesting these observable factors strongly predict marrital status, reinforcing the likelihood of selection bias in the treatment group. 

* Thus, selection into the treatment group is not random, and difference in GHQ reported scores of the treatment and control groups could be driven by these observable characteristics, rather than the causal effects of marriage itself. 

* So, we have a problem of endogenous treatment that biases our estimate of the ATT. 

regress ghqrev married male ethnicity age education jobstatus, vce(robust)

* So, controlling for explanatory variables associated with marital status, the marriage effect drops to 0.7027409 from 1.022006. So, our previous estimated ATT was upward bias.

* Does this now represent an estimate of the true ATT / ATE? 

* Although this estimate is expected to be less biased, we cannot be certain that this is an unbiased estimate. Apart from the differences in observed characteristics, those who are married may still be different from those who are not married, with regard to other unobserved characteristics, such as personality traits and emotional support. So, there may still be some selection bias.

drop if time==1
drop if time==2
drop if time==3
tab time
replace time=1 if time==4
replace time=2 if time==5

* Balancing the observations for the treatment and control group, for pre and post-lockdown dates:

bysort id (interview_date): replace married = interview_date>td(23/03/2020) if _n==2
bysort id (interview_date): replace married = married[2] if _n==1
tab married time

* Difference in Differences (DiD) Estimator Models:

* Equation:
mean ghqrev if married==1, over(time)
mean ghqrev if married==0, over(time)

display (24.1571 - 25.024)
display 24.77193 - 24.98406 
display (-0.8669 - -0.21213)

* DiD coefficient = -0.65477

* Restricted POLS:
regress ghqrev i.married##i.time, vce(cluster id)

* Unrestricted POLS:
regress ghqrev i.married##i.time c.age##c.age ib(3).education jobstatus lincome children male ethnicity, vce(cluster id)

* Restricted FE:
xtreg ghqrev i.married##i.time, fe vce(cluster id)

* Unrestricted FE:
xtreg ghqrev i.married##i.time c.age##c.age ib(3).education jobstatus lincome children male ethnicity, fe vce(cluster id)










