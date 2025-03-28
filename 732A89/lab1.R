x <- seq (0, 4, by = 0.01)

numerator <- function(x) {
  return(log(x + 1))
}
denominator <- function (x) {
  return(x^(3 / 2) + 1)
}
g_fun <- function(x) {
  res <- numerator(x) / denominator(x)
  return(res)
}

y <- g_fun(x)
plot(x, y, type = 'l', col = "blue")


g_fun_prime <- function(x) {
  num <- (1 / (x + 1)) * denominator(x) - numerator(x) * (3 / 2) * x^(1 /
                                                                        2)
  denom <- (denominator(x))^2
  res <- num / denom
  return(res)
}

y_values <- g_fun_prime(x)
plot(x, y_values, type = 'l', col = "red")
abline(h = 0, col = "red")


eps <- 0.000001
bisection <- function (a0, b0) {
  if (g_fun_prime(a0) * g_fun_prime(b0) >= 0)
    stop('input check')
  xold <- 10000
  xnew <- 500
  iter <- 1
  while (abs(xold - xnew) >= eps  && iter < 99) {
    xold <- xnew

    xnew <- (a0 + b0) / 2

    if (g_fun_prime(a0) * g_fun_prime(xnew) <= 0)
      b0 <- xnew

    if (g_fun_prime(b0) * g_fun_prime(xnew) <= 0)
      a0 <- xnew

    iter <- iter + 1
  }
  if (iter == max_iter)
    warning("Maximum iterations reached. Solution may not be accurate.")


  return(xnew)
}

secant <- function (x1, x0) {
  iter <- 0

  while (iter < 99) {
    x_n <- x1 - g_fun_prime(x1) * (x1 - x0) / (g_fun_prime(x1) - g_fun_prime(x0))
    #browser()
    if (abs(x_n - x1) < eps) {
      return (x_n)
    }

    x0 <- x1
    x1 <- x_n
    iter <- iter + 1
  }

  if (iter == 99)
    warning("Maximum iterations reached. Solution may not be accurate.")

  return(x1)
}

res <- secant (0.1, 1)

#sss

# Q2
myvar <- function (vector) {
  N <- length(vector)
  res <- 1 / (N - 1) * ((sum(vector^2)) - 1 / n * sum(vector)^2)
  return(res)
}

x <- rnorm(10000, 1e8, 1)
