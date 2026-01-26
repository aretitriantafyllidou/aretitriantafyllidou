# UNICEF SOCIAL MEDIA ENGAGEMENT ANALYSIS
# Random forest and linear regression Models for engagement metrics

library(dplyr)
library(lubridate)
library(zoo)
library(caret)
library(randomForest)
library(syuzhet)
library(ggplot2)


data <- read.csv("data/FINAL_DATA_v2.csv", stringsAsFactors = FALSE)

# remove  columns
columns_to_remove <- c(
  "post_id", "...1", "V1", "profile", "linked_content", "link",
  "impressions", "organic_impressions", "paid_impressions",
  "organic_reach", "paid.reach", "potential_reach",
  "engagement_rate_per_impression", "likes", "dislikes",
  "love_reactions", "haha_reactions", "wow_reactions",
  "sad_reactions", "angry_reactions", "saves",
  "post_link_clicks", "sproutlink_clicks", "other_post_clicks",
  "post_clicks_all", "other_engagements"
)
data <- data %>% select(-any_of(columns_to_remove))

# we handle missing values
data <- data %>% filter(!is.na(Luminance))
data$shares[is.na(data$shares)] <- median(data$shares, na.rm = TRUE)

#feauture engineering

# color classification function
classify_color <- function(r, g, b) {
  if (is.na(r) | is.na(g) | is.na(b)) return(NA)
  if (r > g & r > b) return("Warm")
  if (b > r & b > g) return("Cool")
  if (g > r & g > b) return("Cool")
  return("Neutral")
}
data <- data %>% mutate(Color_Category = mapply(classify_color, R, G, B))

# Categorize luminance
data <- data %>%
  mutate(luminance_category = case_when(
    Luminance > 175 ~ "High",
    Luminance >= 100 & Luminance <= 175 ~ "Medium",
    Luminance < 100 ~ "Low"
  ))


# Log transformations
skewed_vars <- c("shares", "comments", "reactions", "engagement_rate")
for (var in skewed_vars) {
  data[[paste0("log_", var)]] <- log1p(data[[var]])
}

# Date formatting 
data$date <- as.Date(data$date, format = "%d/%m/%Y")
data <- data %>% arrange(date)

# Rolling engagement metrics (7-day window)
data <- data %>%
  group_by(network) %>%
  mutate(
    last_week_log_reactions = lag(rollapply(log_reactions, 7, sum, fill = NA, align = "right")),
    last_week_log_comments = lag(rollapply(log_comments, 7, sum, fill = NA, align = "right")),
    last_week_log_shares = lag(rollapply(log_shares, 7, sum, fill = NA, align = "right")),
    last_week_log_engagement_rate = lag(rollapply(log_engagement_rate, 7, mean, fill = NA, align = "right"))
  ) %>%
  ungroup()

# Additional features
data <- data %>%
  mutate(
    day_of_week = weekdays(date),
    is_weekend = factor(ifelse(day_of_week %in% c("Saturday", "Sunday"), 1, 0)),
    is_sponsored = ifelse(post_type == "Ad Post", 1, 0),
    text_length = nchar(post)
  )

data <- na.omit(data)

 #analysis

dependent_vars <- c("log_reactions", "log_engagement_rate", "log_comments", "log_shares")

# Linear regression as baseline
for (dep_var in dependent_vars) {
  model <- lm(as.formula(paste(dep_var, "~ message_tone + luminance_category + post_category")), data = data)
  print(summary(model))
}

# Train-test split
set.seed(123)
train_index <- createDataPartition(data$log_reactions, p = 0.8, list = FALSE)
train_data <- data[train_index, ]
test_data <- data[-train_index, ]

# Random Forest models
for (dep_var in dependent_vars) {
  formula <- as.formula(paste(dep_var, "~ message_tone + luminance_category + post_category + Color_Category +
                               is_weekend + is_sponsored + text_length + network"))
  
  control <- trainControl(method = "cv", number = 5)
  tune_grid <- expand.grid(mtry = c(5, 7))
  
  rf_model <- train(
    formula, data = train_data, method = "rf",
    trControl = control, tuneGrid = tune_grid, ntree = 500, importance = TRUE
  )
  
  predictions <- predict(rf_model, newdata = test_data)
  eval <- postResample(predictions, test_data[[dep_var]])
  cat(paste0("\nModel for ", dep_var, ": RMSE = ", round(eval["RMSE"], 4),
             ", R2 = ", round(eval["Rsquared"], 4), "\n"))
}

# visualizations

dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)

#  engagement metrics
metrics <- c("shares", "comments", "reactions", "engagement_rate")
for (m in metrics) {
  p <- ggplot(data, aes_string(x = m)) +
    geom_histogram(fill = "skyblue", color = "black", alpha = 0.7, bins = 30) +
    labs(title = paste("Distribution of", m), x = m, y = "Count") +
    theme_minimal()
  ggsave(paste0("results/figures/dist_", m, ".png"), p, width = 8, height = 6, dpi = 300)
}

# Engagement by message tone
p_tone <- ggplot(data, aes(x = message_tone, y = reactions, fill = message_tone)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Reactions by Message Tone", x = "Tone", y = "Reactions") +
  theme_minimal()
ggsave("results/figures/reactions_by_tone.png", p_tone, width = 8, height = 6, dpi = 300)

# Platform comparison of average engagement
platform_summary <- data %>%
  group_by(network) %>%
  summarise(avg_reactions = mean(reactions, na.rm = TRUE))
p_platform <- ggplot(platform_summary, aes(x = network, y = avg_reactions, fill = network)) +
  geom_col(alpha = 0.8) +
  labs(title = "Average Reactions by Platform", x = "Platform", y = "Average Reactions") +
  theme_minimal()
ggsave("results/figures/avg_reactions_by_platform.png", p_platform, width = 8, height = 6, dpi = 300)
