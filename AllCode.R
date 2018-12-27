
#############################################
library(lmtest)
library(leaps)
library(MASS)
library(car)
library(ggplot2)
library(gridExtra)

## Read data
diab <- read.table("diabetes.txt", header=T, sep=",")
diab[1:10,]
attach(diab)

scatterp <- function(d, x, y, tit) {
    return(ggplot(d, aes(x=x, y=y))+geom_point(alpha=I(0.1))+
               labs(title=tit))
}

qscatterp <- function(x, y, xlabel, ylabel, tit, alphalevel) {
    return(qplot(x=x, y=y, alpha=I(alphalevel), xlab=xlabel, ylab=ylabel) +
               geom_hline(yintercept=0, linetype="dashed") + labs(title=tit))
}
#############################################

#############################################
## Fit the original data
fit1 <- lm(y~age+sex+bmi+map+tc+ldl+hdl+tch+ltg+glu)
summary(fit1)
anova(fit1)
fitted1 <- fit1$fitted.values
resid1 <- fit1$residuals
#############################################

#############################################
## Scatterplot matrix predictors versus the response (original data)
p1 <- scatterp(diab, age, y, "Age vs y")
p2 <- scatterp(diab, sex, y, "Sex vs y")
p3 <- scatterp(diab, bmi, y, "BMI vs y")
p4 <- scatterp(diab, map, y, "MAP vs y")
p5 <- scatterp(diab, tc,  y, "TC vs y")
p6 <- scatterp(diab, ldl, y, "LDL vs y")
p7 <- scatterp(diab, hdl, y, "HDL vs y")
p8 <- scatterp(diab, tch, y, "TCH vs y")
p9 <- scatterp(diab, ltg, y, "LTG vs y")
p10<- scatterp(diab, glu, y, "Glu vs y")

grid.arrange(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10, nrow=3, ncol=4)
remove(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
#############################################

#############################################
## Correlation matrices predictors amongst themselves(original data)
cor1 <- cor(data.frame(y,age,sex,bmi,map,tc,ldl,hdl,tch,ltg,glu))
write.csv(cor1, "Corr_Matrix_Orig_Data.csv")
pairs(data.frame(y,age,sex,bmi,map,tc,ldl,hdl,tch,ltg,glu))
#############################################

#############################################
## Independence of errors (car package)
durbinWatsonTest(fit1) # Ho: autocorrelation=0
#############################################

#############################################
## Normal probability plot (original data)
qqnorm(resid1, main="QQ-Plot (Original Data)")
qqline(resid1)
## Residual histogram
hist(resid1, main="Histogram of the Residuals (Original Data)")

# Residuals and their expected values under normality
shapiro.test(resid1)
#############################################

#############################################
## Resid vs Fitted (original data)
qplot(x=fitted1, y=resid1, alpha=I(0.4), xlab="Fitted Values",
      ylab="Residual") + geom_hline(yintercept=0, linetype="dashed") +
    labs(title="Residuals vs Fitted (Original Data)")

p1 <- qscatterp(age, resid1, "Age", "Residual", "Age", 0.1)
p2 <- qscatterp(sex, resid1, "Sex", "Residual", "Sex", 0.1)
p3 <- qscatterp(bmi, resid1, "BMI", "Residual", "BMI", 0.1)
p4 <- qscatterp(map, resid1, "MAP", "Residual", "MAP", 0.1)
p5 <- qscatterp(tc, resid1, "TC", "Residual", "TC", 0.1)
p6 <- qscatterp(ldl, resid1, "LDL", "Residual", "LDL", 0.1)
p7 <- qscatterp(hdl, resid1, "HDL", "Residual", "HDL", 0.1)
p8 <- qscatterp(tch, resid1, "TCH", "Residual", "TCH", 0.1)
p9 <- qscatterp(ltg, resid1, "LTG", "Residual", "LTG", 0.1)
p10<- qscatterp(glu, resid1, "Glu", "Residual", "Glu", 0.1)

grid.arrange(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,nrow=3, ncol=4,
             top="Residuals vs Predictors")
remove(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)

# BP test for constant error variance (lmtest package)
bptest(fit1,studentize=FALSE)
#############################################

#############################################
## "Best" subset selection (leaps package)
subs<-regsubsets(y=y, x=cbind(age,sex,bmi,map,tc,ldl,hdl,tch,ltg,glu),nbest=5)
summary(subs)

subs1 <- leaps(y=y, x=cbind(age,sex,bmi,map,tc,ldl,hdl,tch,ltg,glu),
               method="Cp", nbest=5)
subs2 <- leaps(y=y, x=cbind(age,sex,bmi,map,tc,ldl,hdl,tch,ltg,glu),
               method="r2", nbest=5)
subs3 <- leaps(y=y, x=cbind(age,sex,bmi,map,tc,ldl,hdl,tch,ltg,glu),
               method="adjr2", nbest=5)
subs1; subs2; subs3

# Get the 5 "best" models according to Cp
best.models1 <- data.frame(subs1$which[order(subs1$Cp)[1:5],])
names(best.models1) <- names(data.frame(cbind(age,sex,bmi,map,tc,ldl,hdl,tch,
                                              ltg,glu)))
best.models1$Cp <- subs1$Cp[order(subs1$Cp)[1:5]]
best.models1

# Get the 5 "best" models according to R^2
best.models2 <- data.frame(subs2$which[order(-subs2$r2)[1:5],])
names(best.models2) <- names(data.frame(cbind(age,sex,bmi,map,tc,ldl,hdl,tch,
                                              ltg,glu)))
best.models2$r2 <- subs2$r2[order(-subs2$r2)[1:5]]
best.models2

# Get the 5 "best" models according to adjR^2
best.models3 <- data.frame(subs3$which[order(-subs3$adjr2)[1:5],])
names(best.models3) <- names(data.frame(cbind(age,sex,bmi,map,tc,ldl,hdl,tch,
                                              ltg,glu)))
best.models3$adjr2 <- subs3$adjr2[order(-subs3$adjr2)[1:5]]
best.models3
#############################################

#############################################
## stepwise selection
full <- lm(y~age+sex+bmi+map+tc+ldl+hdl+tch+ltg+glu)
lower <- formula(~1)
upper <- formula(~age+sex+bmi+map+tc+ldl+hdl+tch+ltg+glu)
step(full, scope=list(lower=lower, upper=upper), direction="both")

# (backward)
step(full, scope=list(lower=lower, upper=upper), direction="backward")
# (forward)
step(lm(y~1), scope=list(lower=lower, upper=upper), direction="forward")
#############################################

################################################################################
################################################################################

#############################################
## Fit the model chosen by several criteria
fit2 <- lm(y~sex+bmi+map+tc+ldl+ltg)
summary(fit2)
anova(fit2)
fitted2 <- fit2$fitted.values
resid2 <- fit2$residuals
#############################################

#############################################
## Correlation plot and matrix (reduced model)
cor2 <- cor(data.frame(y,sex,bmi,map,tc,ldl,ltg))
write.csv(cor2, "Corr_Matrix_subset_Data.csv")
pairs(data.frame(y,sex,bmi,map,tc,ldl,ltg))
#############################################

#############################################
## Independence of errors (reduced model)
durbinWatsonTest(fit2) # Ho: autocorrelation=0
#############################################

#############################################
## Normal probability plot (reduced model)
qqnorm(resid2, main="QQ-Plot (Reduced Model)")
qqline(resid2)
hist(resid2, main="Histogram of the Residuals (Reduced Model)")

# Residuals and their expected values under normality
shapiro.test(resid2)
#############################################


#############################################
## Resid vs Fitted (reduced model)
qplot(x=fitted2, y=resid2, alpha=I(0.4), xlab="Fitted Values",
      ylab="Residual") + geom_hline(yintercept=0, linetype="dashed") +
    labs(title="Residuals vs Fitted (Reduced Model)")

p1 <- qscatterp(sex, resid2, "Sex", "Residual", "Sex", 0.1)
p2 <- qscatterp(bmi, resid2, "BMI", "Residual", "BMI", 0.1)
p3 <- qscatterp(map, resid2, "MAP", "Residual", "MAP", 0.1)
p4 <- qscatterp(tc, resid2, "TC", "Residual", "TC", 0.1)
p5 <- qscatterp(ldl, resid2, "LDL", "Residual", "LDL", 0.1)
p6 <- qscatterp(ltg, resid2, "LTG", "Residual", "LTG", 0.1)

grid.arrange(p1,p2,p3,p4,p5,p6,nrow=3, ncol=2,
             top="Residuals vs Predictors")
remove(p1,p2,p3,p4,p5,p6)

# BP test (reduced model)
bptest(fit2,studentize=FALSE)
#############################################

#############################################
# Box-Cox transformation
boxcox(fit2, main="Box-Cox Transformation")

## Transformations are performed
log.y <- log(y)
sqrt.y <- sqrt(y)
exp.y <- exp(y)
recip.y <- 1/y
sq.y <- y^2
expn.y <- exp(-y)
fit10 <- lm(log.y~sex+bmi+map+tc+ldl+ltg)
fit11 <- lm(sqrt.y~sex+bmi+map+tc+ldl+ltg)
fit12 <- lm(exp.y~sex+bmi+map+tc+ldl+ltg)
fit13 <- lm(recip.y~sex+bmi+map+tc+ldl+ltg)
fit14 <- lm(expn.y~sex+bmi+map+tc+ldl+ltg)

bptest(fit10,studentize=FALSE)
bptest(fit11,studentize=FALSE)
bptest(fit12,studentize=FALSE)
bptest(fit13,studentize=FALSE)
bptest(fit14,studentize=FALSE)

c.tc <- (tc - mean(tc))/sd(tc)
c.ldl <- (ldl - mean(ldl))/sd(ldl)
#############################################

################################################################################
################################################################################

#############################################
## Tentative model
# After some transformations
fit3 <- lm(sqrt.y~sex+bmi+map+tc+ldl+ltg)
fitted3 <- fit3$fitted.values
resid3 <- fit3$residuals
summary(fit3)
anova(fit3)
sum(anova(fit3)$"Mean Sq"[1:6])/anova(fit3)$"Mean Sq"[7] # Overall F-test
qf(0.95,6,length(y)-7)
#############################################

#############################################
## Correlation plot and matrix (tenative model)
(cor3 <- cor(data.frame(sqrt.y,sex,bmi,map,tc,ldl,ltg)))
write.csv(cor3, "Corr_Matrix_Tenative_Model.csv")
pairs(data.frame(sqrt.y,sex,bmi,map,tc,ldl,ltg))
#############################################

#############################################
## Independence of errors (tentative model)
durbinWatsonTest(fit3) # Ho: autocorrelation=0
#############################################

#############################################
## Normal probability plot (tentative model)
qqnorm(resid3, main="QQ-Plot (Tentative Model)")
qqline(resid3)
hist(resid3, main="Histogram of the Residuals (Tentative Model)")

# Residuals and their expected values under normality
shapiro.test(resid3)
#############################################

#############################################
## Resid vs Fitted (reduced model)
qplot(x=fitted3, y=resid3, alpha=I(0.4), xlab="Fitted Values",
      ylab="Residual") + geom_hline(yintercept=0, linetype="dashed") +
    labs(title="Residuals vs Fitted (Tentative Model)")

p1 <- qscatterp(sex, resid3, "Sex", "Residual", "Sex", 0.1)
p2 <- qscatterp(bmi, resid3, "BMI", "Residual", "BMI", 0.1)
p3 <- qscatterp(map, resid3, "MAP", "Residual", "MAP", 0.1)
p4 <- qscatterp(tc, resid3, "TC", "Residual", "TC", 0.1)
p5 <- qscatterp(ldl, resid3, "LDL", "Residual", "LDL", 0.1)
p6 <- qscatterp(ltg, resid3, "LTG", "Residual", "LTG", 0.1)

grid.arrange(p1,p2,p3,p4,p5,p6,nrow=3, ncol=2,
             top="Residuals vs Predictors")
remove(p1,p2,p3,p4,p5,p6)

# BP test (reduced model)
bptest(fit3,studentize=FALSE)
#############################################
# sqrt.y~sex+bmi+map+tc+ldl+ltg
#############################################
## Possible interactions
qscatterp(sex*bmi, resid3, "Sex*BMI", "Residual", "Sex*BMI", 0.3)
qscatterp(sex*map, resid3, "Sex*MAP", "Residual", "Sex*MAP", 0.3)
qscatterp(sex*tc, resid3, "Sex*TC", "Residual", "Sex*TC", 0.3)
qscatterp(sex*ldl, resid3, "Sex*LDL", "Residual", "Sex*LDL", 0.3)
qscatterp(sex*ltg, resid3, "Sex*LTG", "Residual", "Sex*LTG", 0.3)
qscatterp(bmi*map, resid3, "BMI*MAP", "Residual", "BMI*MAP", 0.3)
qscatterp(bmi*tc, resid3, "BMI*TC", "Residual", "BMI*TC", 0.3)
qscatterp(bmi*ldl, resid3, "BMI*LDL", "Residual", "BMI*LDL", 0.3)
qscatterp(bmi*ltg, resid3, "BMI*LTG", "Residual", "BMI*LTG", 0.3)
qscatterp(map*tc, resid3, "MAP*TC", "Residual", "MAP*TC", 0.3)
qscatterp(map*ldl, resid3, "MAP*LDL", "Residual", "MAP*LDL", 0.3)
qscatterp(map*ltg, resid3, "MAP*LTG", "Residual", "MAP*LTG", 0.3)
qscatterp(tc*ldl, resid3, "TC*LDL", "Residual", "TC*LDL", 0.3)
qscatterp(tc*ltg, resid3, "TC*LTG", "Residual", "TC*LTG", 0.3)
qscatterp(ldl*ltg, resid3, "LDL*LTG", "Residual", "LDL*LTG", 0.3)
#############################################

#############################################
## Added-variable plots
avPlots(fit3)
#############################################

#############################################
## Outlying Y observations
boxplot(resid3, main="Boxplot of Residuals (Tentative Model)")
dstu3 <- abs(rstudent(fit3)) # studentized deleted residuals
qt(1-.05/(2*length(y)),length(y)-7-1) # to test rstudent 3.89623
dstu3[order(dstu3, decreasing=T)][1:5] # None exceed 3.89623
outlierTest(fit3) # test of studentized residuals
#############################################

#############################################
## Outlying X observations
attributes(lm.influence(fit3))
lev3 <- lm.influence(fit3)$hat
lev3[order(lev3, decreasing=T)][1:25]
lev3[lev3>(2*7)/length(y)]
write.csv(lev3[lev3>(2*7)/length(y)], "Infl_LEVERAGES.csv")
(2*7)/length(y) # 0.03167421
hatvalues(fit3)
plot(c(1:442),lev3,lty=2)
#############################################

#############################################
## Influential observations
dffits3 <- dffits(fit3)
dffits3[dffits3 > 2*sqrt(7/length(y))]
length(dffits3[dffits3 > 2*sqrt(7/length(y))]) # How many?
2*sqrt(7/length(y)) # Influential dffits are greater than 0.2516911
write.csv(dffits3[dffits3 > 2*sqrt(7/length(y))], "Infl_DFFITS.csv")

cooksd3 <- cooks.distance(fit3)
# the largest Cook's d is the 0.0000154 th percentile of a F(7,435) distribution
pf(cooksd3[order(cooksd3, decreasing=T)][1], 7, length(y)-7)
# so no influential obs are present based on Cook's d

### DFBETAS: Influence of each observation on each regression coefficient.
dfbetas3 <- abs(dfbetas(fit3))
dfbetas_int <-dfbetas3[,"(Intercept)"]
dfbetas_sex <-dfbetas3[,"sex"]
dfbetas_bmi <-dfbetas3[,"bmi"]
dfbetas_map <-dfbetas3[,"map"]
dfbetas_tc <-dfbetas3[,"tc"]
dfbetas_ldl <-dfbetas3[,"ldl"]
dfbetas_ltg <-dfbetas3[,"ltg"]

dfbetas_int[dfbetas_int > 2/sqrt(length(y))]
dfbetas_sex[dfbetas_sex > 2/sqrt(length(y))]
dfbetas_bmi[dfbetas_bmi > 2/sqrt(length(y))]
dfbetas_map[dfbetas_map > 2/sqrt(length(y))]
dfbetas_tc[dfbetas_tc > 2/sqrt(length(y))]
dfbetas_ldl[dfbetas_ldl > 2/sqrt(length(y))]
dfbetas_ltg[dfbetas_ltg > 2/sqrt(length(y))]

write.csv(dfbetas_int[dfbetas_int > 2/sqrt(length(y))], "Inf_DEBETAS_int.csv")
write.csv(dfbetas_sex[dfbetas_sex > 2/sqrt(length(y))], "Inf_DEBETAS_sex.csv")
write.csv(dfbetas_bmi[dfbetas_bmi > 2/sqrt(length(y))], "Inf_DEBETAS_bmi.csv")
write.csv(dfbetas_map[dfbetas_map > 2/sqrt(length(y))], "Inf_DEBETAS_map.csv")
write.csv(dfbetas_tc[dfbetas_tc > 2/sqrt(length(y))], "Inf_DEBETAS_tc.csv")
write.csv(dfbetas_ldl[dfbetas_ldl > 2/sqrt(length(y))], "Inf_DEBETAS_ldl.csv")
write.csv(dfbetas_ltg[dfbetas_ltg > 2/sqrt(length(y))], "Inf_DEBETAS_ltg.csv")

# Influential DFBETAS larger than 0.0951303
dfbetas3[dfbetas3[,1] > 2/sqrt(length(y))]
length(dfbetas3[dfbetas3 > 2/sqrt(length(y))]) # How many?
#############################################

#############################################
# Evaluate Collinearity
vif(fit3) # Variance inflation factors
sum(vif(fit3))/6 # Mean VIF = 3.735823
#############################################