library(tidyverse)
data(msleep)
?msleep

# 1. Convert into factors
msleep <- msleep %>%
  mutate(
    genus = as.factor(genus),
    vore = as.factor(vore),
    order = as.factor(order),
    conservation = as.factor(conservation)
    )

# 2. Shortest sleep time
shortest_sleep <- min(msleep$sleep_total)
shortest_sleep_mammal <- msleep$name[which.min(msleep$sleep_total)]

# 3. Most missing
missing_index <- as.numeric(which.max(colSums(is.na(msleep)))[1])
most_missing <- colnames(msleep)[missing_index]
missing_values <- max(colSums(is.na(msleep)))

# 4. Correlations
correlations <- msleep |>
  select(where(is.numeric)) |>
  cor(use = "complete.obs") 

# 5. Highest correlation
correlations_copy <- correlations
diag(correlations_copy) <- NA
highest_corr <- max(correlations_copy,na.rm = TRUE)

# 6. Sleep time distribution
data = as.data.frame(msleep$sleep_total)
colnames(data) <- "sleep_total"  # give the column a proper name

sleep_histogram <- ggplot(data = data, aes(x = sleep_total)) +
  geom_histogram(binwidth = 1, fill = "steelblue", color = "black") +
  labs(
    title = "Distribution of Total Sleep Time",
    x = "Total Sleep (hours)",
    y = "Count"
  ) +
  theme_minimal()


# 7. Bar chart for food categories
vore <- as.data.frame(msleep$vore)
colnames(vore) <- "Food"  # give the column a proper name

food_barchart <- ggplot(data = vore, aes(x = Food)) +
  geom_bar(fill = "orange", color = "black") +
  labs(
    title = "Distribution of Animal Diet Types",
    x = "Diet Type (vore)",
    y = "Number of Species"
  ) +
  theme_minimal()

# 8. Grouped box plot for sleep time
vore_sleep <- as.data.frame(msleep[,c(3,6)])
sleep_boxplot <- ggplot(data = vore_sleep, aes(x = vore, y = sleep_total)) +
  geom_boxplot(fill = "lightgreen", color = "black") +
  labs(
    title = "Total Sleep Time by Diet Type",
    x = "Diet Type (vore)",
    y = "Total Sleep (hours)"
  ) +
  theme_minimal()

# 9. Longest average sleep time
highest_average_df <-msleep |>
  group_by(vore) |> 
  summarize(
    avg_sleep = mean(sleep_total, na.rm = TRUE),
  )

highest_average <- highest_average_df |> 
  arrange(desc(avg_sleep)) |> 
  slice(1)
highest_average <- as.numeric(highest_average)[2]

# 10. REM sleep vs. total sleep, colored by order
sleep_scatterplot <- ggplot(data = msleep, aes(x = sleep_total , y = sleep_rem, color = order)) +
  geom_point() +
  labs(
    title = "REM Sleep Time by Total Sleep Time",
    x = "Total Sleep (hours)",
    y = "REM Sleep (hours)"
  ) +
  theme_minimal()

# 11. REM sleep vs. total sleep for the order most common in the data
msleep_order <- msleep %>%
  count(order, sort = TRUE)
msleep_most_common_name <- as.character(msleep_order$order[1])

most_common_m <-  filter(msleep, order==msleep_most_common_name )

sleep_scatterplot2 <- ggplot(data = most_common_m, aes(x = sleep_total , y = sleep_rem)) +
  geom_point() +
  labs(
    title = "REM Sleep Time by Total Sleep Time for Rodentia ",
    x = "Total Sleep (hours)",
    y = "REM Sleep (hours)"
  ) +
  theme_minimal()