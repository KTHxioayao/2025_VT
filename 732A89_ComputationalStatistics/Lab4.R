
f <- function(x)
{
  return(120 * x ^ 5 * exp(-x))
}


res <- c()
xt <- 1
set.seed(123)

for (i in 1:10000) {

  xcan <- rnorm(1,xt, 0.1)
R <- min(f(xcan)* dnorm(xt,xcan, 0.1)/f(xt)/dnorm(xcan,xt,0.1), 1)

ifelse (R> runif(1) , xn <- xcan, xn<-xt)
res<- c(res, xn)
xt <- xn

}

plot(res, type ='l')

# 设置参数
w <- 1.999
n_samples <- 1000  # 采样数量

# 计算给定 x1 时的 x2 取值范围
ellipse_bounds <- function(x1) {
  inside_sqrt <- 1 - (1 - w^2 / 4) * x1^2
  if (inside_sqrt < 0) {
    return(c(NA, NA))  # 避免 NaN
  }
  lower <- -(w / 2) * x1 - sqrt(inside_sqrt)
  upper <- -(w / 2) * x1 + sqrt(inside_sqrt)
  return(c(lower, upper))
}

# 画出椭圆边界

w  <- 1.999
xv <- seq(-1, 1, by=0.01) * 1/sqrt(1-w^2/4)  # a range of x1-values, where the term below the root is non-negative (compare Lecture 4)
plot(xv, xv, type="n", xlab=expression(x[1]), ylab=expression(x[2]), las=1)
# ellipse
lines(xv, -(w/2)*xv-sqrt(1-(1-w^2/4)*xv^2), lwd=2, col=8)
lines(xv, -(w/2)*xv+sqrt(1-(1-w^2/4)*xv^2), lwd=2, col=8)

# 初始化 Gibbs 采样
set.seed(123)
res <- data.frame(x1 = 0, x2 = 0)  # 随机初始化一个合法点

for (i in 1:n_samples) {
  last_x2 <- tail(res$x2, 1)  # 获取最新的 x2 值
  x1_range <- ellipse_bounds(last_x2)  # 计算 x1 的可行范围

  if (!any(is.na(x1_range))) {
    x1_new <- runif(1, x1_range[1], x1_range[2])  # 在合法范围内采样
  } else {
    x1_new <- NA
  }
browser()
  x2_range <- ellipse_bounds(x1_new)  # 计算新的 x2 取值范围
  if (!any(is.na(x2_range))) {
    x2_new <- runif(1, x2_range[1], x2_range[2])  # 在合法范围内采样
  } else {
    x2_new <- NA
  }

  res_add <- data.frame(x1 = x1_new, x2 = x2_new)
  res <- rbind(res, res_add)  # 追加数据
}

# 绘制 Gibbs 采样点
points(res$x1, res$x2, col = "blue", pch = 20)

