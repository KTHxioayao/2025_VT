f <- function(x, y) {
  sin(x + y) + (x - y)^2 - 1.5 * x + 2.5 * y + 1
}
x_values <- seq(-1.5, 4, length.out = 200)
y_values <- seq(-3, 4, length.out = 200)
z <- expand.grid(x_values,y_values)

res <- apply (z, 1,function(data) f(data[1], data[2]))
res <- matrix(res, nrow= 200)
contour(x_values, y_values, res)


gradient <- function (x, y) {
  return(matrix(c(
    cos(x + y) + 2 * x - 2 * y - 1.5, cos(x + y) + 2 * y - 2 * x + 2.5
  ), nrow = 2))

}

Hessian <- function (x , y) {
  return(matrix(c(
    -sin(x + y) + 2, -sin(x + y) - 2, -sin(x + y) - 2, -sin(x + y) + 2
  ), nrow = 2))
}

convergence_crit<- function(x_new, xo) {
  return(as.vector(t (x_new-xo) %*% (x_new-xo)))
}

newton <- function (x,y) {
  iter <- 1
    x0 <- matrix(c (x,y), nrow =2)

 while (iter < 100)  {
  x_new <- x0- solve(Hessian (x0[1],x0[2])) %*% gradient (x0[1],x0[2])

  if (convergence_crit(x_new, x0) < 0.00001) return(x_new)
  x0 <- x_new
  iter <- iter +1
 }

 if (iter== 100)     warning("Maximum iterations reached. Solution may not be accurate.")
    return(x_new)
}


#Q 2

x <- c(0, 0, 0, 0.1, 0.1, 0.3, 0.3, 0.9, 0.9, 0.9)
y <- c(0, 0, 1, 0, 1, 1, 1, 0, 1, 1)

data <- rbind (x, y)
# define the probability function
#b_0 <- -0.2
#b_1 <- 1
#b <- c(b_0, b_1)
p <- function(x, b) {
  return(1 / (1 + exp(-b[1] - b[2] * x)))
}

g <- function(b) {
  g <- 0
  for (i in 1:dim(data)[2]) {
    mat <- as.matrix(data[, i])
    g_add <- mat[2] * log(p(mat[1], b = b)) + (1 - mat[2]) * log(1-p(mat[1],b))
    g <- g_add + g
  }
  return(g)
}
# define the gradient function
gradient <- function (b) {
  gradient <- matrix(c(0, 0))
  for (i in 1:dim(data)[2]) {
    mat <- as.matrix(data[, i])
    gradient_add <- (mat[2] - p(mat[1],b)) * matrix (c(1, mat[1]))
    gradient <- gradient_add + gradient
  }
  return(gradient)

}
steepest <- function (b) {



}


