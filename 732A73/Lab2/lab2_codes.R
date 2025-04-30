data <- read.csv('temp_linkoping.csv')
library (mvtnorm)

mu0 <- c(0,100,-100)

# define inverse chisquare function
rinvchisq <- function(n, df, scale) {
  df * scale / rchisq(n, df)
}

