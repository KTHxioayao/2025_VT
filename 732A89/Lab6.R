load('bankdata.Rdata')

n<- dim(bankdata)
id <- c(1:n)
set.seed(123)
select <- sample(id, 22)

selectd <- bankdata[select,]

plot(bankdata)
points(selectd, col ='red')




# 计算目标函数：最小化所有点到选定点的最近距离之和
crit <- function(dat, subs){
  s <- length(subs)
  nclients <- dim(dat)[1]
  dist <- matrix(rep(NA, nclients*s), ncol=s)
  for (i in 1:s){
    dist[, i] <- sqrt((dat[,1]-dat[subs[i],1])^2+(dat[,2]-dat[subs[i],2])^2)
  }
  return(sum(apply(dist, 1, min)))
}

# 初始化随机候选解
sample_candidate <- function(data, n_samples) {
  sample_idx <- sample(1:nrow(data), n_samples)
  plot(data[sample_idx, "age"], data[sample_idx, "balance"], main="Selected Candidates")
  return(sample_idx)
}

# 生成邻域解：随机替换一个点
get_neighborhood <- function(data, current_solution) {
  replace_idx <- sample(current_solution, 1)  # 随机选一个点替换
  new_point <- sample(setdiff(1:nrow(data), current_solution), 1)  # 选一个不在解中的点
  return(c(setdiff(current_solution, replace_idx), new_point))  # 替换
}

# 冷却函数
exponential_cooling <- function(temp, step) temp * 0.95^step
linear_cooling <- function(temp, step) max(temp - 0.1 * step, 0.0001)

# 模拟退火优化
simulated_annealing <- function(data, n_clients, beta, temp, func, max_iter,
                                early_stop, cooling_fun) {
  set.seed(123)
  solution <- sample_candidate(data, n_clients)  # 初始化解
  best_solution <- solution
  best_value <- current_value <- func(data, solution)

  stop_count <- 0
  crit_values <- numeric(max_iter)

  for (step in 1:max_iter) {
    for (i in 1:ceiling(beta * step)) {
      new_solution <- get_neighborhood(data, solution)
      new_value <- func(data, new_solution)
      delta <- new_value - current_value

      # 选择接受新解
      if (delta < 0 || runif(1) < exp(-delta / temp)) {
        solution <- new_solution
        current_value <- new_value
        if (new_value < best_value) {
          best_solution <- new_solution
          best_value <- new_value
        }
      }
    }

    crit_values[step] <- best_value
    stop_count <- ifelse(crit_values[max(1, step - 1)] == best_value, stop_count + 1, 0)
    if (stop_count >= early_stop) break

    temp <- cooling_fun(temp, step)  # 更新温度
  }

  return(list(best_solution = best_solution, best_value = best_value,
              iterations = 1:step, crit_values = crit_values[1:step]))
}

# 参数设置
nclients <- 22
better_res <- simulated_annealing(bankdata, nclients, beta=1.05, temp=10,
                                  func=crit, max_iter=100, early_stop=15,
                                  cooling_fun=linear_cooling)
bad_res <- simulated_annealing(bankdata, nclients, beta=1.05, temp=1000,
                               func=crit, max_iter=100, early_stop=30,
                               cooling_fun=exponential_cooling)

# 绘制优化过程对比
plot(better_res$iterations, better_res$crit_values, type="l", col="blue",
     xlab="Iterations", ylab="Criterion Value", main="Cooling Schedule Comparison")
lines(bad_res$iterations, bad_res$crit_values, col="red")
legend("topright", legend=c("Exponential Cooling", "Linear Cooling"), col=c("blue", "red"), lty=1)
