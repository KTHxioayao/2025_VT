# Q1
#(a)
library(BayesLogit)
library(mvtnorm)

data = read.csv('Disease.csv')
x <- as.matrix(data [, 1:6])
y <- as.matrix(data [, 7])
# initialize beta
nDraws = 1000
burnin <- 200       # Burn-in period

n <- nrow(x)
p <- ncol(x)

beta <- rep(1, 6) # 5+1 intercept

beta_samples <- matrix(NA, nDraws, p)

set.seed(123)

for (i in 1:nDraws) {
  omega <- rpg(n, 1, x %*% beta)
  k <- y - 1 / 2
  B <- 9 * diag(6)
  b <- rep(0, p)
  # Conditional posterior for beta

  v_omg <- solve(t(x) %*% diag(omega) %*% x + solve(B))
  m_omg <- v_omg %*% (t(x) %*% k + solve(B) %*% b)

  beta <- as.numeric(rmvnorm(1, mean = m_omg, sigma = v_omg))
  beta_samples[i, ] <- beta
}
# Discard burn-in
beta_samples <- beta_samples[(burnin + 1):nDraws, ]
nPost <- nrow(beta_samples)

par(mfrow = c(2, 3))  # 6 pics

for (i in 1:p) {
  plot(
    beta_samples[, i],
    type = 'l',
    main = paste("Trace plot for β", i),
    xlab = "Iteration",
    ylab = paste("β", i)
  )
}


max_lag <- 50  # set the max lag
acfs <- matrix(NA, max_lag, p)

for (i in 1:p) {
  chain <- beta_samples[, i] - mean(beta_samples[, i])
  var_chain <- mean(chain ^ 2)
  for (j in 1:max_lag) {  # j as lag
    # calculate the autocorrelation factor
    acfs[j, i] <- sum(chain[1:(nPost - j)] * chain[(j + 1):nPost]) / nPost / var_chain

  }

}

par(mfrow = c(2, 3))  # 6 pics

for (i in 1:p) {
  plot(
    1:max_lag,
    acfs[, i],
    type = 'h',
    main = paste("ACF for β", i),
    xlab = "Lag",
    ylab = "ACF"
  )
  abline(h = 0, col = "red", lty = 2)
}

# inefficiency factor (IF)
IFs <- numeric(p)

for (i in 1:p) {
  IFs[i] <- 1 + 2 * sum(acfs[, i])
  cat(paste("IF for β", i, "=", round(IFs[i], 2), "\n"))
}

#(b)
m <- c(10, 40, 80)
for (z in 1:3) {
  row_nr <- m[z]
  data = read.csv('Disease.csv')
  x <- as.matrix(data [1:row_nr, 1:6])
  y <- as.matrix(data [1:row_nr, 7])

  # initialize beta
  nDraws = 1000
  burnin <- 200       # Burn-in period

  n <- nrow(x)
  p <- ncol(x)

  beta <- rep(1, 6) # 5+1 intercept

  beta_samples <- matrix(NA, nDraws, p)

  set.seed(123)

  for (i in 1:nDraws) {
    omega <- rpg(n, 1, x %*% beta)
    k <- y - 1 / 2
    B <- 9 * diag(6)
    b <- rep(0, p)
    # Conditional posterior for beta

    v_omg <- solve(t(x) %*% diag(omega) %*% x + solve(B))
    m_omg <- v_omg %*% (t(x) %*% k + solve(B) %*% b)

    beta <- as.numeric(rmvnorm(1, mean = m_omg, sigma = v_omg))
    beta_samples[i, ] <- beta
  }
  # Discard burn-in
  beta_samples <- beta_samples[(burnin + 1):nDraws, ]
  nPost <- nrow(beta_samples)

  par(mfrow = c(2, 3))  # 6 pics

  for (i in 1:p) {
    plot(
      beta_samples[, i],
      type = 'l',
      main = paste("Trace plot for β", i , "with first ", row_nr),
      xlab = "Iteration",
      ylab = paste("β", i)
    )
  }


  max_lag <- 50  # set the max lag
  acfs <- matrix(NA, max_lag, p)

  for (i in 1:p) {
    chain <- beta_samples[, i] - mean(beta_samples[, i])
    var_chain <- mean(chain ^ 2)
    for (j in 1:max_lag) {  # j as lag
      # calculate the autocorrelation factor
      acfs[j, i] <- sum(chain[1:(nPost - j)] * chain[(j + 1):nPost]) / nPost / var_chain

    }

  }

  par(mfrow = c(2, 3))  # 6 pics

  for (i in 1:p) {
    plot(
      1:max_lag,
      acfs[, i],
      type = 'h',
      main = paste("ACF for β", i , "with first ", row_nr),
      xlab = "Lag",
      ylab = "ACF"
    )
    abline(h = 0, col = "red", lty = 2)
  }

  # inefficiency factor (IF)
  IFs <- numeric(p)

  for (i in 1:p) {
    IFs[i] <- 1 + 2 * sum(acfs[, i])
    cat(paste("IF for β", i, "=", round(IFs[i], 2), "with first ", row_nr, "\n"))
  }

}

#Q2
#(a)
rm(list=ls())

data <-read.table('eBayNumberOfBidderData_2025.dat', header = FALSE, skip = 1)

colnames(data) <- c("nBids", "Const", "PowerSeller", "VerifyID", "Sealed", "MinBlem", "MajBlem", "LargNeg", "LogBook", "MinBidShare")

# Fit Poisson regression model (excluding Const)

model <- glm(nBids ~ . - Const, family = poisson, data = data)
summary(model)
#(b)

y<- matrix(data$nBids, ncol=1)
x<- as.matrix(data[, 2:10])

LogPostPossion <- function(beta,y,X){
  beta <- as.numeric(beta)
  lin_pred <- X %*% beta
  p = length(beta)

  # Poisson log-likelihood
  log_lik <- sum(y * lin_pred - exp(lin_pred))

  # Zellner's g-prior: beta ~ N(0, 100 * (X^T X)^-1)
  log_prior = dmvnorm(beta, rep(0, p), 100*solve(t(X)%*%X), log=TRUE);
  return(log_lik + log_prior)
}

OptimRes <- optim(par = rep(0, ncol(x)),
                  fn = LogPostPossion,
                  X = x, y = y,
                  method = "BFGS",
                  control = list(fnscale = -1, maxit = 1000),
                  hessian = TRUE)
approxPostMode <- matrix(OptimRes$par,1,9)
cov_matrix <- solve(-OptimRes$hessian)# J^{-1}

#(c)
mp_sim <- function(c, LogPostFunc, ndraws, theta_init, sigma) {
  p <- length(theta_init)
  theta_mat <- matrix(NA, ndraws, p)
  theta_mat[1, ] <- theta_init

  for (i in 2:ndraws) {
    theta_new <- rmvnorm(1, theta_mat[i - 1, ], c * sigma)

    log_post_new <- LogPostFunc(theta_new, y = y, X = x)
    log_post_old <- LogPostFunc(theta_mat[i - 1, ], y = y, X = x)

    acc_prob <- min(1, exp(log_post_new - log_post_old))

    if (acc_prob > runif(1)) {
      theta_mat[i, ] <- theta_new
    } else {
      theta_mat[i, ] <- theta_mat[i - 1, ]
    }
  }

  return(theta_mat)
}

set.seed(123)
possion_samp <- mp_sim(1,LogPostFunc = LogPostPossion,
                       ndraws=10000,
                       theta_init=OptimRes$par,
                       sigma=cov_matrix)

par(mfrow = c(3, 3))  # 9 pics
p <- length(OptimRes$par)
burnin <- 2000

for (i in 1:p) {
  plot(
    1:(dim(possion_samp)[1]-burnin),
    possion_samp[(burnin+1):nrow(possion_samp), i],
    type = 'l',
    main = paste("Trajectories for β", i),
    xlab = "Iteration",
    ylab = "value"
  )
  abline(h = 0, col = "red", lty = 2)
}

ndraws <- nrow(possion_samp)
draw_plot <- ndraws-burnin
for (j in 1:9) {
  param_index <- j  # choose the ith param

  mean_vec <- numeric(draw_plot)
  sd_vec <- numeric(draw_plot)

  for (i in 1:draw_plot) {
    samples_so_far <- possion_samp[(burnin+1):(i+burnin),param_index]
    mean_vec[i] <- mean(samples_so_far)
    sd_vec[i] <- sd(samples_so_far)
  }


  par(mfrow=c(2,1))

  plot(1:draw_plot, mean_vec, type='l', col='blue', lwd=2,
       xlab='Iteration', ylab='Mean',
       main=paste('Mean of parameter', param_index, 'vs iteration'))

  plot(1:draw_plot, sd_vec, type='l', col='red', lwd=2,
       xlab='Iteration', ylab='Standard Deviation',
       main=paste('Standard Deviation of parameter', param_index, 'vs iteration'))
}

#(d)
bidden <- c(1,1,0,1,0,1,0,1.3,0.7) # intercept as 1 to include it
lambda <- exp(possion_samp[(burnin+1):ndraws,] %*% bidden)

res <-rep(NA,length(lambda))
set.seed(124)
for (i in 1:length(lambda)) {
  res[i] <- rpois(1, lambda[i])
}

hist(res)
prob_0 <- sum(res ==0)/length(lambda)
print(prob_0)

#Q3
#(a)
rm(list=ls())
#define the function

ar <- function (mu, phi, sig2, T) {
  res<- c()
  x<- mu
  res<-x
  for (t in 2:T) {
    x_new <- mu + phi*(x-mu)+rnorm(1,0,sqrt(sig2))
    res<- c(res,x_new)
    x<- x_new
  }
  return(res)
}

#simulate
set.seed(123)
p <- seq(-1,1,0.1)
res <- matrix(NA,nrow=300, ncol=length(p))
for (i in 1:length(p)) {
  res[,i] <-ar (mu=5, phi=p[i], sig2=9, T=300)

}

nplot <- seq(3,21,3)
par(mfrow = c(1, 2))  # 6 pics
for (i in nplot) {
  plot(res[,i], type='l', col='blue', lwd=2,
       xlab='Iteration', ylab='x value',
       main=paste('x changes with',p[i], 'as phi'))
}

#(b)
set.seed(123)
ar1 <- ar(mu=5, phi=0.4, sig2=9, T=300)
ar2 <- ar(mu=5, phi=0.98, sig2=9, T=300)

library(rstan)
y=ar1
N=length(y)

StanModel = '
data {
  int<lower=0> N; // Number of observations
  vector[N] y; // Number of flowers
}
parameters {
  real mu;
  real<lower=-1, upper=1> phi;
  real<lower=0> sigma;
}
model {
  mu ~ normal(0, 5);
  phi ~ uniform(-1,1);
  sigma ~ normal(3, 3); // Normal with mean 3, st.dev. 3  It is normal (mean, sd_dev) in stan

  for(i in 2:N){
    y[i]~ normal(mu+ phi*(y[i-1] - mu), sigma);
  }
}'



data <- list(N=N, y=y)
warmup <- 50
niter <- 2000
fit <- stan(model_code=StanModel,data=data, warmup=warmup,iter=niter,chains=4)
# Print the fitted model
#print(fit,digits_summary=3)
# Extract posterior samples
postDraws <- extract(fit)
# Do traceplots of the first chain
par(mfrow = c(1,1))
plot(postDraws$mu[1:(niter-warmup)],type="l",ylab="mu",main="Traceplot")
# Do automatic traceplots of all chains
traceplot(fit)
# Bivariate posterior plots
pairs(fit)

summary_fit <- summary(fit, pars = c("mu", "phi", "sigma"))$summary
# extract the mean, 95% CI and effective posterior sample
posterior_summary <- summary_fit[, c("mean", "2.5%", "97.5%", "n_eff" , "Rhat")]
print(round(posterior_summary, 3))

posterior_samples <- as.data.frame(rstan::extract(fit, pars = c("mu", "phi")))

plot(posterior_samples$mu, posterior_samples$phi,
     xlab = expression(mu), ylab = expression(phi),
     main = "Joint Posterior of μ and φ", pch = 20, col = rgb(0, 0, 1, 0.3))


y=ar2
N=length(y)

StanModel = '
data {
  int<lower=0> N; // Number of observations
  vector[N] y; // Number of flowers
}
parameters {
  real mu;
  real<lower=-1, upper=1> phi;
  real<lower=0> sigma;
}
model {
  mu ~ normal(0, 5);
  phi ~ uniform(-1,1);
  sigma ~ normal(3, 3); // Normal with mean 3, st.dev. 3

  for(i in 2:N){
    y[i]~ normal(mu+ phi*(y[i-1] - mu), sigma);
  }
}'



data <- list(N=N, y=y)
warmup <- 50
niter <- 2000
fit <- stan(model_code=StanModel,data=data, warmup=warmup,iter=niter,chains=4)
# Print the fitted model
#print(fit,digits_summary=3)
# Extract posterior samples
postDraws <- extract(fit)
# Do traceplots of the first chain
par(mfrow = c(1,1))
plot(postDraws$mu[1:(niter-warmup)],type="l",ylab="mu",main="Traceplot")
# Do automatic traceplots of all chains
traceplot(fit)
# Bivariate posterior plots
pairs(fit)

summary_fit <- summary(fit, pars = c("mu", "phi", "sigma"))$summary
# extract the mean, 95% CI and effective posterior sample
posterior_summary <- summary_fit[, c("mean", "2.5%", "97.5%", "n_eff", "Rhat")]
print(round(posterior_summary, 3))

posterior_samples <- as.data.frame(rstan::extract(fit, pars = c("mu", "phi")))

plot(posterior_samples$mu, posterior_samples$phi,
     xlab = expression(mu), ylab = expression(phi),
     main = "Joint Posterior of μ and φ", pch = 20, col = rgb(0, 0, 1, 0.3))
