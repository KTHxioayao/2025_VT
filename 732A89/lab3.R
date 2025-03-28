#2)

U<- runif(10000000, 0,1)
A <- runif(10000000,0,1)

x1 <- sqrt(-2 * log (U))* cos(A*pi) * sqrt(0.6)
x2 <- sqrt(-2 * log (U))* sin(A*pi) * sqrt(0.6)


g <- rbinom(1000, size = 1, prob = 0.5)

x1n <- rnorm(1000, 0, sqrt(0.6) )
x2n <- rnorm(1000, 0, sqrt(0.6) )
x3 <- rnorm(1000, 1.5, sqrt(0.5) )
x4 <- rnorm(1000, 1.2, sqrt(0.5) )

ifelse (g==0, x<- x1n, x<- x3)
ifelse (g==0, y<- x2n, x<- x3)

plot(x, y)
