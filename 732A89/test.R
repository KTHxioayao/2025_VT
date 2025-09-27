set.seed(42)  # Ensure reproducibility

gibbs_sampler <- function(n, rho) {
  # Mean vector
  mu <- c(0, 0)

  # Covariance matrix
  Sigma <- matrix(c(1, rho, rho, 1), nrow = 2)

  # Compute conditional variances
  sigma_11 <- Sigma[1, 1]
  sigma_22 <- Sigma[2, 2]
  sigma_12 <- Sigma[1, 2]

  # Initialize storage for samples
  samples <- matrix(0, nrow = n, ncol = 2)

  # Initialize X values
  x1 <- 0
  x2 <- 0

  for (i in 1:n) {
    # Sample x1 given x2
    mu_1_given_2 <- mu[1] + (sigma_12 / sigma_22) * (x2 - mu[2])
    sigma_1_given_2 <- sqrt(sigma_11 - (sigma_12^2 / sigma_22))
    x1 <- rnorm(1, mean = mu_1_given_2, sd = sigma_1_given_2)

    # Sample x2 given x1
    mu_2_given_1 <- mu[2] + (sigma_12 / sigma_11) * (x1 - mu[1])
    sigma_2_given_1 <- sqrt(sigma_22 - (sigma_12^2 / sigma_11))
    x2 <- rnorm(1, mean = mu_2_given_1, sd = sigma_2_given_1)

    # Store the sample
    samples[i, ] <- c(x1, x2)
  }

  return(samples)
}

# Generate samples
n_samples <- 1000
samples_rho_0 <- gibbs_sampler(n_samples, rho = 0)
samples_rho_0998 <- gibbs_sampler(n_samples, rho = 0.998)

# Plot the results
par(mfrow = c(1, 2))  # Arrange plots side by side

plot(samples_rho_0, col = rgb(0, 0, 1, 0.5), pch = 16,
     xlab = expression(X[1]), ylab = expression(X[2]),
     main = expression(paste(rho, " = 0")))

plot(samples_rho_0998, col = rgb(1, 0, 0, 0.5), pch = 16,
     xlab = expression(X[1]), ylab = expression(X[2]),
     main = expression(paste(rho, " = 0.998")))
