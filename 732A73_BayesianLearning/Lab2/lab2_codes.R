# Q:1

#1)a

data <- read.csv('temp_linkoping.csv')
library (mvtnorm)

# define inverse chi square function
mu_0 <- c(15, -50, 50)
nu_0<- 1
sig_0_sq <- 2
omega_0 <- diag(3)*0.8
rinvchisq <- function(n, df, scale) {
  df * scale / rchisq(n, df)
}

# sort our time and time^2
data['time^2'] <- data[3]^2
data['time^0'] <- data[3]^0
time <- as.matrix(data[, c(6,3,5)])
temp <- as.matrix(data[, 4])

curve <-  matrix(NA, nrow = 366, ncol = 100)

for  (i in 1: 100) {
  sig_sq_sp<- rinvchisq(1,nu_0, sig_0_sq)
  samp <- rmvnorm(n=1, mean= mu_0, sigma = sig_sq_sp*solve(omega_0))
  pred  <- time %*% as.numeric(samp)
  curve [,i] <- pred
}

plot(time[,2], temp, pch = 16, col = 'gray', xlab = "Time", ylab = "Temperature")
for (i in 2:100) {
  lines(data[,3], curve[,i], col = rgb(0,0,1,alpha=0.2))
}

#1)b
set.seed(123456)
sample_posterior <- function (number ,nu_0, sig_0_sq, omega_0) {
  # The marginal posterior of sigma

  nu_n <- nu_0+366
  omega_n <- t(time) %*%time+omega_0
  mu_n <- solve(omega_n) %*% (omega_0%*%mu_0 +t(time)%*%(temp))
  sig_n_sq <- as.numeric(1/nu_n*(nu_0*sig_0_sq+
                                   t(temp)%*%temp+
                                   t(mu_0)%*%omega_n%*%mu_0-
                                   t(mu_n)%*%omega_n%*%mu_n))

  # sampled results
  # joint posterior of sigma square given data
  sig2_marg<- rinvchisq(number,nu_n, sig_n_sq)

  # joint posterior of beta given sigma square and data
  beta_marg <- matrix(nrow=number, ncol=3)
  colnames(beta_marg) = c('beta0', 'beta1','beta2')

  for (i in 1: number) {
    beta_marg[i,] <- as.vector(rmvnorm(n=1, mean= mu_n, sigma = sig2_marg[i]*solve(omega_n)))
  }
  return(list(sig2_marg = sig2_marg, beta_marg = beta_marg))
}

res <-sample_posterior(number=10000 ,nu_0=nu_0, sig_0_sq=sig_0_sq, omega_0=omega_0)
sig2_marg <- res$sig2_marg
beta_marg <- res$beta_marg

hist(sig2_marg, breaks = 20)
hist(beta_marg[,1], breaks = 20)
hist(beta_marg[,2], breaks = 20)
hist(beta_marg[,1], breaks = 20)


pred_temp <- time%*%t(beta_marg)
pred_temp_meadian <- apply(pred_temp,1, quantile, probs = c(0.05,0.95) )

plot(time[,2], temp, pch = 16, col = 'gray', xlab = "Time", ylab = "Temperature",
     main = "Posterior Median and 90% Prediction Interval")
points(time[,2], pred_temp_meadian[1,], col ='red')
points(time[,2], pred_temp_meadian[2,], col ='blue')

#1)c

xbar <- -beta_marg[,2]/2/beta_marg[,3]
hist(xbar, breaks = 20)

#1)d
mu_0_new <- c(25, -60, 0.01,-1,60,10,0,0,0,0,0)
nu_0<- 1
sig_0_sq <- 2
omega_0_new <- diag(c(rep(1, 6), rep(1000, 5)))

#construct poly terms
x <- data[, 3]
poly_terms <- sapply(0:10, function(p) x^p)
colnames(poly_terms) <- paste0("time^", 0:10)
time_new <- as.matrix(poly_terms)

# sort our time and time^2

curve_new <-  matrix(NA, nrow = 366, ncol = 100)

for  (i in 1: 100) {
  sig_sq_sp<- rinvchisq(1,nu_0, sig_0_sq)
  samp_new <- rmvnorm(n=1, mean= mu_0_new, sigma = sig_sq_sp*solve(omega_0_new))
  pred_new  <- time_new %*% as.numeric(samp_new)
  curve_new [,i] <- pred_new
}

plot(time[,2], temp, pch = 16, col = 'gray', xlab = "Time",
     ylab = "Temperature"#,ylim=range(curve_new)
)
for (i in 2:100) {
  lines(data[,3], curve_new[,i], col = rgb(0,0,1,alpha=0.2))
}

#Q2:
#2)a
library(mvtnorm)

data <- read.csv("Disease.csv")
Nobs <- dim(data)[1] # number of observations
#data <- data.frame(intercept=rep(1,Nobs),disease_data) # add intercept
data[,c("age","duration_of_symptoms","white_blood" )] <-
  scale(data[,c("age","duration_of_symptoms","white_blood" )])

Xnames = colnames(data)[1:6]
LogPostLogistic <- function(beta,y,X,tau){
  lin_pred <- X %*% beta
  p = length(beta)
  log_lik <- sum(y * lin_pred - log1p(exp(lin_pred)))
  #log_prior <- -sum(beta^2) / (2 * tau^2)
  log_prior = dmvnorm(beta, rep(0, p), tau^2 * diag(p), log=TRUE);
  return(log_lik + log_prior)
}
lambda <- 1#
tau=2
Npar = dim(data)[2] - 1
mu <- as.matrix(rep(0,Npar)) #
initVal <- matrix(0,Npar,1)
Sigma <- (1/lambda)*diag(Npar)
y =  as.numeric(data$class_of_diagnosis)

X = as.matrix(data[,1:ncol(data) - 1])# Select which covariates/features to include
OptimRes <- optim(par = rep(0, ncol(X)),
                  fn = LogPostLogistic,
                  X = X, y = y, tau = tau,
                  method = "BFGS",
                  control = list(fnscale = -1, maxit = 1000),
                  hessian = TRUE)
approxPostMode <- matrix(OptimRes$par,1,6)
cat("The posterior mode:",OptimRes$par) # The posterior mode
cov_matrix <- solve(-OptimRes$hessian)  # J^{-1}
approxPostStd <- sqrt(diag(cov_matrix)) # `Computing approximate standard deviations.

Cred_int <- matrix(0,2,6) # Create 95 % approximate credibility intervals for each coefficient
Cred_int[1,] <- approxPostMode - 1.96*approxPostStd
Cred_int[2,] <- approxPostMode + 1.96*approxPostStd

colnames(Cred_int) <- Xnames
rownames(Cred_int) <- c("LCI","UCI") #LCI（Lower Confidence Interval）UCI（Upper Confidence Interval）
print(Cred_int)
# 使用glm验证
glm_data <- data.frame(
  Class_of_diagnosis = data$class_of_diagnosis,
  Gender = data$gender,
  Age_z = data$age,
  Duration_z = data$duration_of_symptoms,
  Dyspnoea = data$dyspnoea,
  White_z = data$white_blood
)

glm_model <- glm(Class_of_diagnosis ~ Gender + Age_z + Duration_z + Dyspnoea + White_z,
                 data = glm_data, family = binomial)
print(summary(glm_model))
cat("\n95% CI for Age coefficient: [", Cred_int[1,2], ", ", Cred_int[2,2], "]\n")
cat("MAP of age coefficient: ", approxPostMode[2], "\n")
cat("Posterior mean of age coefficient: ", OptimRes$par[2], "\n")
cat("glm model coefficient of age: ", coef(glm_model)[2], "\n")
#Report the posterior mean (Estimate) and 95% confidence interval (LCI, UCI),
# Age:  -0.26762 (95% CI: -0.015, -0.51)

#2)b
set.seed(123)
data_b <- read.csv("Disease.csv")

new_age <- (38 - mean(data_b$age)) / sd(data_b$age)
new_duration <- (10 - mean(data_b$duration_of_symptoms)) / sd(data_b$duration_of_symptoms)
new_white <- (11000 - mean(data_b$white_blood)) / sd(data_b$white_blood)
X_new <- c(1, 1, new_age, new_duration, 0, new_white)

samples <- rmvnorm(10000, mean = OptimRes$par, sigma = cov_matrix)
lin_pred <- samples %*% X_new
pr <- exp(lin_pred) / (1 + exp(lin_pred))

hist(pr, breaks = 50, main = "Posterior Predictive Distribution of Pr(y=1|x)",
     xlab = "Probability", col = "skyblue", border = "white")
