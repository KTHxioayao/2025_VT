library(tidyverse)
library(FNN)
load('bankdata.Rdata')


crit <- function(dat, subs){
  s <- length(subs)
  nclients <- dim(dat)[1]
  dist <- matrix(rep(NA, nclients*s), ncol=s)
  for (i in 1:s){
    dist[, i] <- sqrt((dat[,1]-dat[subs[i],1])^2+(dat[,2]-dat[subs[i],2])^2)
  }
  return(sum(apply(dist, 1, min)))
}


sample_candidate = function(n_samples) {
  sample_index = sample(1:nrow(bankdata),n_samples)
  sample_bankdata = bankdata[sample_index,]
  plot(sample_bankdata[,"age"] , sample_bankdata[,"balance"])
  return(list(sample_index=sample_index, sample_bankdata=sample_bankdata))
}


# get_neighborhood = function(current_solution_index,knn_res,replace_num) {
#     # get all the knn result for all the clients in the bank data
#     remove_idx <- sample(1:length(current_solution_index), replace_num)
#     removed_client <- current_solution_index[remove_idx]
#     new_sample <- current_solution_index[-remove_idx]
#     neighbors <- knn_res$nn.index[removed_client, ]
#     add_candidate <- sample(neighbors, replace_num)
#     new_sample <- c(new_sample, add_candidate)
#     return(new_sample)
# }

get_neighborhood = function(data,current_solution_index) {
  # get all the knn result for all the clients in the bank data
  remove_idx <- sample(1:length(current_solution_index),1)
  removed_client <- current_solution_index[remove_idx]
  new_sample <- current_solution_index[-remove_idx]
  add_candidate <- sample(setdiff(1:nrow(data), new_sample), 1)
  new_sample <- c(new_sample, add_candidate)
  return(new_sample)
}


exponential_cooling <- function(tau0, j) {
  return (tau0 * 0.95^j)
}

linear_cooling <- function(tau0, j) {
  return (tau0 - 0.1 * j)
}


# target optimize method is crit
simulated_annealing = function(data,n_clients , beta, initial_temp,func,mj_iterations,max_iterations,early_stop,cooling_fun) {
  set.seed(123)
  iterations = c()
  crit_values = c()
  init_sample  = sample_candidate(n_clients)
  init_solution_index = init_sample$sample_index
  current_solution_index = init_solution_index
  current_target_value = func(data, init_solution_index)
  best_target_value = current_target_value
  previous_best_target_value = current_target_value
  best_solution_index = current_solution_index
  temperature = initial_temp
  m_j = mj_iterations
  stop_count = 0
  loop_index = 0
  current_temp = temperature
  while(current_temp > 0.0001){
    if (loop_index > max_iterations) {
      break
    }
    cat(paste0("current temp:", current_temp,"\n"))
    cat(paste0("current m_j:", m_j,"\n"))
    cat(paste0("current best value:", best_target_value,"\n"))
    cat(paste0("previous best target value:", previous_best_target_value,"\n"))
    cat(paste0("current stop_count:", stop_count,"\n"))
    cat(paste0("current loop index:", loop_index,"\n"))
    cat(paste0("=================================================================","\n"))
    previous_best_target_value = best_target_value
    for (i in 1:m_j) {
      #new_soultion_index = get_neighborhood(current_soultion_index,knn_res,5)
      new_solution_index = get_neighborhood(data,current_solution_index)
      new_target_value = func(bankdata, new_solution_index)
      delta = new_target_value - current_target_value
      # get a better dist than previous value
      if (delta < 0){
        current_solution_index = new_solution_index
        current_target_value = new_target_value
        if (new_target_value < best_target_value) {
          best_solution_index = new_solution_index
          best_target_value = new_target_value
        }
      }else{
        # get a worse dist than previous value,calcualte the prob to accept the wrose value
        prob = exp(-delta/temperature)
        if (runif(1) < prob) {
          current_solution_index = new_solution_index
          current_target_value = new_target_value
        }
      }
    }
    loop_index = loop_index + 1
    iterations = append(iterations, loop_index)
    crit_values = append(crit_values, best_target_value)
    stop_count = ifelse(previous_best_target_value == best_target_value,stop_count + 1,0)

    if (stop_count == early_stop ) {
      break
    }

    # according to the ppt  temperature should decrease after each update
    # while m_j should increase
   # temperature = alpha * temperature
    temperature = cooling_fun(temperature, loop_index)
    m_j = ceiling(beta * m_j)
  }
  return(list(best_solution_index = best_solution_index, best_value = best_target_value,iterations=iterations, crit_values=crit_values))
}

#knn_res <- get.knn(bankdata, k = 5)
nclients <- 22


better_res = simulated_annealing(
  data = bankdata,
  n_clients = nclients,
  beta = 1.05,
  initial_temp = 10,
  mj_iterations = 100,
  max_iterations = 100,
  func =crit,
  early_stop = 15,
  cooling_fun = linear_cooling
)
res_clients = bankdata[better_res$best_solution_index,]
cat(paste0("minimum distance is:", better_res$best_value))
cat(paste0("minimum distance index:", better_res$best_solution_index))


bad_res = simulated_annealing(
    data = bankdata,
    n_clients = nclients,
    beta = 1.05,
    initial_temp = 1000,
    mj_iterations = 1000,
    max_iterations = 100,
    func =crit,
    early_stop = 30,
    cooling_fun = exponential_cooling
)
res_clients = bankdata[bad_res$best_solution_index,]
cat(paste0("minimum distance is:", bad_res$best_value))
cat(paste0("minimum distance index:", bad_res$best_solution_index))


plot(better_res$iterations, better_res$crit_values, type="l", col="blue",
     xlab="Iterations", ylab="Criterion Value", main="Cooling Schedule Comparison")
lines(bad_res$iterations, bad_res$crit_values_linear, col="red")
legend("topright", legend=c("Exponential Cooling", "Linear Cooling"), col=c("blue", "red"), lty=1)






