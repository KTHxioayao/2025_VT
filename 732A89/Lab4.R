prop_dis <- function (xt) {
  return(rnorm(1, xt, 0.1))
}

f <- function(x)
{
  return(120 * x ^ 5 * exp(-x))
}

variables<- seq_len(10000)
res <- f(variables)

set.seed(123)
x      <- 1
chain  <- c(x)
# generate first five values (change 5 to higher number for longer chain)
for (i in 1:10000)
{
  # generate first one sample from uniform distribution on circle with specific radius by rejection sampling:
  
  xcand <- prop_dis(x)        # candidate point
  # dnorm as the density of it
  R     <- f(xcand) * dnorm(x, mean = xcand, sd = 0.1) / 
    (f(x) * dnorm(xcand, mean = x, sd = 0.1))  # MH ratio
  
  ap    <- runif(1)
  if (ap < R)
    x <- xcand
  chain <- rbind(chain, x)
}
chain  # each row is one two-dimensional observation

plot(chain, type = "l", main = "Metropolis-Hastings Chain", xlab = "Iteration", ylab = "X")

prop_dis2<- function (x,xt) {
  dchisq(x,df=floor(xt+1))
}

set.seed(123)
x      <- 1
chain2  <- c(x)
for (i in 1:10000)
{
  # generate first one sample from uniform distribution on circle with specific radius by rejection sampling:
  
  xcand <- rchisq(1,floor(x+1))        # candidate point
  # dnorm as the density of it
  R     <- f(xcand) * prop_dis2(x,xcand)/ 
    (f(x) * prop_dis2(xcand,x))  # MH ratio
  
  ap    <- runif(1)
  if (ap < R)
    x <- xcand
  chain2 <- rbind(chain2, x)
}
chain2  # each row is one two-dimensional observation

plot(chain2, type = "l", main = "Metropolis-Hastings Chain", xlab = "Iteration", ylab = "X")

w  <- 1.999
xv <- seq(-1, 1, by=0.01) * 1/sqrt(1-w^2/4)  # a range of x1-values, where the term below the root is non-negative (compare Lecture 4)
plot(xv, xv, type="n", xlab=expression(x[1]), ylab=expression(x[2]), las=1)
# ellipse
lines(xv, -(w/2)*xv-sqrt(1-(1-w^2/4)*xv^2), lwd=2, col=8)
lines(xv, -(w/2)*xv+sqrt(1-(1-w^2/4)*xv^2), lwd=2, col=8)

