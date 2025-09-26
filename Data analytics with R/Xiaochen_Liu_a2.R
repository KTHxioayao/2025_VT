library(tidyverse)
data(iris)

# 1. Correlations
correlations <- iris |>
  select(where(is.numeric)) |>
           cor(use = 'complete.obs')

# Text answer...
# Since Sepal length is negative correlated to sepal width and positive related
# to petal length and width.
# It shows that longer sepal is related to thinner width but longer and wider petal.

# 2. Plot Sepal.Width against Sepal.Length
plot1 <-  ggplot(data = iris, aes(x = Sepal.Width, y = Sepal.Length, color = 'red')) +
  geom_point() +
  labs(
    title = "Sepal.Width against Sepal.Length",
    x = "Sepal width",
    y = "Sepal length"
  ) +
  theme_minimal()
# Text answer...
# Since Sepal length is negative correlated to sepal width,
# short sepal length usually gives wider sepal.

# 3. Fit a linear model using Sepal.Width as predictor and Sepal.Length as response
model1 <- iris |>
  lm(formula = Sepal.Length ~ Sepal.Width)
summary(model1)
# Text answer...
# YES, the model gives a negative estimate coefficient and it matches what have seen before.

# 4. Setosa correlations
setosa_data <- iris[iris$Species=='setosa',]
correlations_setosa <- setosa_data |>
  select(where(is.numeric)) |>
  cor(use = 'complete.obs')
# Text answer...
# All correlations are positive. It shows a positive correlation between sepal length and width.
# A smaller correlation between sepal length and petal length & width.
# Yes, it reveal the setosa specie has a different pattern from the general.

# 5. Plot Sepal.Width against Sepal.Length, color by species
plot2 <- ggplot(data = iris, aes(x = Sepal.Width, y = Sepal.Length, color = Species)) +
  geom_point() +
  labs(
    title = "Sepal.Width against Sepal.Length",
    x = "Sepal width",
    y = "Sepal length"
  ) +
  theme_minimal()
# Text answer...
# YEs, it matches.

# 6. Fit second model using species and Sepal.Width as predictors and Sepal.Length as response
model2 <- iris |>
  lm(formula = Sepal.Length ~ Sepal.Width + Species)

summary(model2)
# Text answer...
# The coeffienets are positive for all species.
# The model gives coefficients for 3 species rather than for the whole data set.
# The interpretation shows that longer sepal width usually relates to larger
# sepal length, regardless of species.

# 7. Predict the sepal length of a setosa with a sepal width of 3.6 cm
prediction <- predict(model2, newdata = data.frame(Sepal.Width = 3.6, Species = "setosa"))
# Text answer...
# The prediction seems to be reasonable, corresponding with the general observation from the dataset.


# Load the data
diabetes_data <- read_csv("a2_diabetes.csv") # Don't change this line!

# Reflect over important variables

# 8. Recode Outcome as a factor
diabetes_data <- diabetes_data %>%
  mutate(
    Outcome = as.factor(Outcome),
  )

# 9. Impute missing values
imputed_data <- diabetes_data %>%
  mutate_at(c('Pregnancies', 'Glucose', 'BloodPressure', 'SkinThickness', 'Insulin',
              'BMI', 'DiabetesPedigreeFunction', 'Age'),
            function(x) replace(x, is.na(x), mean(x, na.rm = TRUE)))


# 10. Find a logistic regression model with significant predictors
logistic_model <- glm(Outcome ~., data = imputed_data, family = "binomial")

summary(logistic_model)

# srot out the predictors have statistically significant relationships with the outcome at a 5%
logistic_model <- glm(Outcome ~ Pregnancies + Glucose + BMI,
                      data = imputed_data,
                      family = "binomial")

summary(logistic_model)

# 11. Compute accuracy of your model
predicted_probs <- predict(logistic_model, newdata = imputed_data, type = "response")
predicted_classes <- ifelse(predicted_probs > 0.5, 1, 0)
actual <- imputed_data$Outcome
accuracy <- mean(predicted_classes == actual)


# Text answer...
