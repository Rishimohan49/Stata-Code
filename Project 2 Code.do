*clear the workspace
clear all
version 17
cap log close
*change directory and open data set
cd "/Users/rishimohan/Desktop/Econ 50"
capture log using "project2_log", replace text
use third_grade.dta

* Question 1:
* The fundamental problem of causal inference in general is that we can only observe one of the two outcomes for each individual, meaning we only have data on the observed outcomes, not the potential ones. Therefore, causal effects cannot be observed because the two (or more) outcomes that we would want to find differences between do not both happen in real life.

*Question 2:

// The describe command gives me the variable names and what they represent, and the codebook command gives me relevant information such as percentiles, range, unique values, etc. Since we are looking for variables with missing data, we are looking for variables that have a "." in the codebook, and the ones that match this condition (along with their counts of missing values) are below
describe
codebook

* The variables with missing values are boy, ses_index, verb, math, and towncode. The number of missing values in the variable boy are 1037. The number of missing values in the variable ses_index are 318. The number of missing values in the variable verb are 466. The number of missing values in the variable math are 58. The number of missing values in the variable towncode are 318.

*Question 3:

// We first generate variables symbolizing the math and reading scores; but some test scores are missing and they do not have natural units, so we subtract the sample mean and divide by the sample SD to get standardized math and verbal test scores.

sum math
gen std_math = (math - r(mean)) / r(sd)

sum verb
gen std_verb = (verb - r(mean)) / r(sd)

// We combine the standardized test scores into one overall index below, and, to deal with missing data, we set that index equal to the non-missing exam score for any observations that are missing one of the scores.

gen test_score_index = 0.5 * (std_math + std_verb)

replace test_score_index = std_math if verb ==.
replace test_score_index = std_verb if math ==.

*Question 4:

// Here, all we are doing is reporting summary statistics for our variables so that we can make sure that future answers we get semi-align with these/are reasonable compared to these.

sum math
* summary statistics for math:
* mean: 25.30272
* SD:  4.527391
* min: 1
* max: 30
sum verb
* summary statistics for verb:
* mean: 25.97044
* SD: 4.279308
* min: 1
* max: 30
sum test_score_index
* summary statistics for test_score_index
* mean: -.0033251
* SD: .9026839
* min: -5.835159
* max: 1.037524

*Question 5:

// Again, here we just want to get a general idea of what the distributions of our variables look like so that we can check how well our future answers align with the histograms we plot now.

hist math
hist verb
hist test_score_index

* None of the three distributions are uniformly distributed; instead they all have long left tails (have leftward skew). Most of the values in the math and verb histograms seem to lie between 24 and 30 on the test score range. The test_score_index histogram has a similar shape, but most of the scores lie in the index score range between -1 and 1.

*Question 6a:
// Here, we want to get a rough idea of how the Socioeconomic Status Index reported by the Ministry of Education relates to the test score index that we created, and we see a negative relationship.
binscatter test_score_index ses_index, line(lfit)

*Question 6b:
// Here, we want to get a rough idea of how the Socioeconomic Status Index reported by the Ministry of Education relates to class size, and we see a negative relationship.
binscatter class_size ses_index, line(lfit)

*Question 6c:
// Same idea as in the previous two binned scatter plots, but even though we see a positive relationship, ses_index is a confounding variable we have not accounted for that could lead to misleading conclusions.
binscatter test_score_index class_size, line(lfit)

*Question 7:
*We see a positive relationship in part 6c, but we intuitively also know that bigger class size does not cause higher test scores, meaning this binscatter is falsely trying to show us a causal relationship. We want to use a design that captures the causal effect of class size on test scores. We see the relationship in the graph in 6c but cannot make any conclusions about causality because we aren't taking into account/controlling for the confounding variable of ses_index, which externally influences both our dependent and independent variables "behind the scenes." We do not know how the confounding variable (ses_index) is affecting the variables in the third graph, so we cannot conclude any causal effects. If we do, then we might lead to the misleading conclusions that do not take into account how the independent and dependent variables were affected by the confound.

*Question 8a:
// We want to verify that class size changes at the 40/41 cutoff for school enrollment so that we have a baseline to see if there is manipulation of school enrollment for increased funding later on in the project. 
binscatter class_size school_enrollment if school_enrollment <= 80, rd(40.5) line(qfit)

*Question 8b:
// We want to see how the test scores relate to school enrollment, especially on either side of the 40/41 cutoff so that we can compare to later results. 
binscatter test_score_index school_enrollment if school_enrollment <= 80, rd(40.5) line(qfit)

*Question 9a:
// We must check to see if the identification assumption for regression discontinuity design, which is that other determinants of the outcome must evolve smoothly across the threshold, and we are verifying that with these three binned scatter plots.
binscatter born_isr school_enrollment if school_enrollment <= 80, rd(40.5) line(lfit)
binscatter boy school_enrollment if school_enrollment <= 80, rd(40.5) line(lfit)
binscatter ses_index school_enrollment if school_enrollment <= 80, rd(40.5) line(lfit)

*Question 9b:
*For regression discontinuity design, the identification assumption is that other determinants of the outcome must evolve smoothly across the threshold (from Professor Bruich's lecture on 4/25/22). While it may not look like that is true in the first and second plots, we must look at the increments of y-axes and its units. The increments for the first plot are .01, and for the second plot they are .02; due to error in the data, the lines on the left and right sides of the discontinuity barely do not match up, but the difference is so small when we look at the units that we can write that difference off. In the third plot, the lines do evolve smoothly across the threshold. Therefore, these graphs are consistent with the identification assumption for regression discontinuity design.

*Question 10a:
*Again, for regression discontinuity design, the identification assumption is that other determinants of the outcome must evolve smoothly across the threshold (from Professor Bruich's lecture on 4/25/22). If schools manipulate their enrollment, then there will likely be larger differences in funding and resources (and, as a result, test scores) among the schools underneath the threshold and those right above it, meaning there will not be a smooth transition across the cutoff, thus invalidating the identification assumption.

*Question 10b:
// To check whether there was manipulation of school enrollment, we first need to collapse the data by school so that we end up with a data set with 998 observations on total school enrollment, average class size, and the average test_score_index in the school. 
collapse (mean) school_enrollment class_size test_score_index, by(schlcode)

*Question 10c:
// This is a histogram showing the distribution of total school enrollment in the data, and we set the bin width to 1 so that we do not smooth over any possible spikes. From this, we can judge whether or not there seems to be manipulation.
hist school_enrollment, width(1)

*Question 10d:
*There does actually seem to be some manipulation of third-grade enrollment. There are large jumps in enrollment level just to the right side of the cutoffs at 40-41, 80-81, and 120-121, meaning schools likely wanted to fit themselves just right past the threshold to get extra funding, resources, etc.

*Question 11:

// We are generating variables that will be of use in the multivariate regression. We first define a running variable (dist_from_41). The indicator variable above_41 then equals 1 if dist_from_41 >= 0 and 0 otherwise. We then define the interaction variable as below, and then plug into the multivariate regression formula.
gen dist_from_41 = school_enrollment - 41

gen above_41 = 0
replace above_41 = 1 if dist_from_41 >= 0

gen interaction_41 = dist_from_41 * above_41

// We then run multivariate regressions to measure how class size and the test score index change at the 40/41 cutoff, using the observations with school enrollment <= 80, and report estimates of the discontinuities at the threshold.

regress class_size above_41 dist_from_41 interaction_41 if school_enrollment <= 80, r
*I decided that a good estimate of the discontinuity at the threshold for the class size would be the found coefficient for above_41, which I got to be  -16.61007.

regress test_score_index above_41 dist_from_41 interaction_41 if school_enrollment <= 80, r
*I decided that a good estimate of the discontinuity at the threshold for the test scores would be the found coefficient for above_41, which I got to be .0262499.

*Question 12:
*The confidence intervals are taken from the regressions in the previous question.

*The 95% confidence interval for the estimated discontinuity in class size goes from -18.4014 to -14.81875. These results are statistically significantly different from zero because the confidence interval doesn't include 0. 

*The 95% confidence interval for the estimated discontinuity in test scores goes from -.137046 to .1895458. These results are not statistically significantly different from zero because the confidence interval includes 0. 

*Question 13:
// Since there are only a limited number of schools right around the 40/41 student enrollment threshold (which can lead to imprecise estimates of the impacts on test scores), we can pool together/combine the estimates based on the multiples of 40. To do so, we start by generating and refining our running variable dist_from_cut as shown. Basically, we are pooling the thresholds so that we can see the effects at all the thresholds in a simpler manner.
gen dist_from_cut = school_enrollment - 41 if school_enrollment <= 61
replace dist_from_cut = school_enrollment - 81 if school_enrollment > 61 & school_enrollment <= 101
replace dist_from_cut = school_enrollment - 121 if school_enrollment > 101 & school_enrollment <= 141
replace dist_from_cut = school_enrollment - 161 if school_enrollment > 141

sum dist_from_cut

*Question 14a:
// We want to visualize how class size changes when dist_from_cut = 0, so we use a binned scatter plot with a bandwidth of 20 to do so.
binscatter class_size dist_from_cut if inrange(dist_from_cut, -20, 20), rd(0) line(qfit)

*Question 14b:
// We want to visualize how the test score index changes when dist_from_cut = 0, so we use a binned scatter plot with a bandwidth of 20 to do so.
binscatter test_score_index dist_from_cut if inrange(dist_from_cut, -20, 20), rd(0) line(qfit) 

*Question 15:
// We keep the running variable dist_from_cut but use an indicator variable T that equals 1 if dist_from_cut >= 0 and 0 otherwise. We then define the interaction variable as below, and then plug into the multivariate regression formula.
gen T = 0
replace T = 1 if dist_from_cut >= 0

gen interaction = dist_from_cut * T

// We then run multivariate regressions to measure how class size and the test score index change at the combined school enrollment threshold, using the observations with dist_from_cut <= 20 and dist_from_cut <= -20, and report estimates of the discontinuities at the threshold.

regress test_score_index T dist_from_cut interaction if inrange(dist_from_cut, -20, 20), r
*I decided that a good estimate of the discontinuity at the threshold for the test scores would be the found coefficient from for T, which I got to be -.0081411.

regress class_size T dist_from_cut interaction if inrange(dist_from_cut, -20, 20), r
*I decided that a good estimate of the discontinuity at the threshold for the class size would be the found coefficient for T, which I got to be -14.20197.

*Question 16:

*Confidence intervals gotten from regressions from Question 15

*The 95% confidence interval for the estimates for class size goes from -15.60609 to -12.79784 (width of 2.80825), and the 95% confidence interval for the estimates for test scores goes from -.1078001 to .0915179 (width of .199318). The width of these 95% confidence intervals is smaller than the width of the 95% confidence intervals for the regressions that only used data around the 40/41 school enrollment threshold. For example, the width of the previous 95% confidence interval for the regressions that only used data around the 40/41 school enrollment threshold were 3.58265 for class size and .3265918 for test scores. Both of these widths are greater than the ones for the confidence intervals from Question 15. That means combining all the thresholds results in more precise estimates (even if some are still statistically insignificantly different from zero) due to the narrower width of the confidence interval.

*Question 17:

*Is class size a determinant of students' success? Israel regulates that if > 40 students are enrolled in a school, then the cohort must be split. Using regression discontinuity design with data about third graders from Israel's Ministry of Education, after pooling all the cutoffs together to view uniformly, we cannot determine causal effects of class size on test scores because the results are likely imprecisely estimated, but we do see that students in schools with enrollment < 40 have, on average, about 14 fewer students per class than students in schools with enrollment > 40 and that this result is statistically significant. Moreover, due to spikes right after the cutoffs, it seems that there may be manipulation of the running variable.

*Question 18:

*This question basically said that we should comment up the do-file, which I did (and hopefully have done correctly). I started all comments related to this question with a "//" instead of the using the "*" that I have used for organizational purposes throughout the file.

cap log close
