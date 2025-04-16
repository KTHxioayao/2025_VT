# Question 1
#(a)
nr <- 10000
set.seed(123456)
res <- rbeta(nr,50,42)
me <- numeric(nr)
std <- numeric(nr)

for (i in 1: nr) {
  me[i] <- mean(res[1:i])
  std[i] <- sqrt(var (res [1:i]))

}

plot(me, type = 'l')
abline(h=50/(50+42), ,col ='red')

plot(std, type = 'l')
abline(h=sqrt(50*42/(50+42)^2/(42+50+1)),col ='red')

#(b)
sorted <- res [res>0.5]
# probability from sampling
pr <- length(sorted) / nr

# true probability
tr_pr <- 1- pbeta (0.5, 50, 42)
print(pr)
print(tr_pr)

#(c)
odds <- res / (1-res)
hist(odds, breaks = 30, freq = FALSE,probability = TRUE, main = "Posterior of Odds", xlab = "Odds")
lines(density(odds), col = "blue", lwd = 2)

# Question 2
#(a)
rm(list=ls())

rinvchisq <- function(n, df, scale) {
  df * scale / rchisq(n, df)
}

mu <- 3.65
arg <- c(22, 33, 31, 49, 65, 78, 17, 24)

tau_sq <- sum((log(arg) -3.65)^2)/length(arg)

set.seed(123456)
samp <- rinvchisq(10000, length(arg), tau_sq)

hist(samp, breaks = 40, freq = FALSE, ylim = c(0, 4))
lines(density(samp), col = "blue", lwd = 2)

#(b)
G <- 2* pnorm(sqrt(samp)*sqrt(2))-1
hist(G, breaks = 40, freq = FALSE)
lines(density(G), col = "blue", lwd = 2)

#(c)
ci95 <- quantile(G, probs = c(0.025, 0.975))

ci95

#(d)
library(bayestestR)
hdi(G, ci= 0.95)

# Question 3
#(a)
rm(list= ls())
y <- c(0, 2, 5, 5, 7, 1, 4)
sig <- 5
p <- function(lambda) {

  res <- sqrt(2)/sig /sqrt(pi) * exp(-length(y)* lambda) *
    lambda^(sum(y)) * exp(-lambda^2 / 2/ sig^2)

  return(res)
}

var <- seq (0,10,0.001)

#normalize for results
res <- p(var) / sum(p(var) * 0.001)  # here have to also divide by the steps
plot(var, res, type = "l", col = "blue")

#(b)
opt_lambda <- var[which.max(res)]
print (opt_lambda)
