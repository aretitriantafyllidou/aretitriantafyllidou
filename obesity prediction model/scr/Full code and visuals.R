# Load Libraries
library(dplyr)
library(ggplot2)
library(e1071)
library(partykit)
library(randomForest)
library(rpart)
library(corrplot)
library(readxl)
library(caret)
library(iml)
library(pdp)
library(patchwork)
library(tidyr)

#set working directory
path = dirname(rstudioapi::getSourceEditorContext()$path) 
setwd(path)
data <- read_excel("Obesity_Dataset.xlsx")
str(data)

# Rename columns for better interpretation
colnames(data) <- c("Gender", "Age", "Height", "FamilyHistory",
                    "FastFood", "VeggieIntake", "MealsPerDay", "Snacking",
                    "Smoking", "WaterIntake", "CalorieMonitor",
                    "PhysicalActivity", "TechTime", "Transport", "Obesity")
str(data) 

# convert to factors with labels
data <- data %>%
  mutate(
    Gender = factor(Gender, levels = c(1, 2), labels = c("Male", "Female")),
    FamilyHistory = factor(FamilyHistory, levels = c(1, 2), labels = c("Yes", "No")),
    FastFood = factor(FastFood, levels = c(1, 2), labels = c("Yes", "No")),
    VeggieIntake = factor(VeggieIntake, levels = c(1, 2, 3), labels = c("Rarely", "Sometimes", "Always")),
    MealsPerDay = factor(MealsPerDay, levels = c(1, 2, 3), labels = c("1-2", "3", "3+")),
    Snacking = factor(Snacking, levels = c(1, 2, 3, 4), labels = c("Rarely", "Sometimes", "Usually", "Always")),
    Smoking = factor(Smoking, levels = c(1, 2), labels = c("Yes", "No")),
    WaterIntake = factor(WaterIntake, levels = c(1, 2, 3), labels = c("Smaller than 1 liter", "1-2 liters", "More than 2 liters")),
    CalorieMonitor = factor(CalorieMonitor, levels = c(1, 2), labels = c("Yes", "No")),
    PhysicalActivity = factor(PhysicalActivity, levels = c(1, 2, 3, 4, 5), labels = c("No", "1-2 days", "3-4 days", "5-6 days", "6+ days")),
    TechTime = factor(TechTime, levels = c(1, 2, 3), labels = c("0-2 hours", "3-5 hours", "Exceeding 5 hours")),
    Transport = factor(Transport, levels = c(1, 2, 3, 4, 5), labels = c("Automobile", "Motorbike", "Bike", "Public transportation", "Walking")),
    Obesity = factor(Obesity, levels = c(1, 2, 3, 4), labels = c("Underweight", "Normal", "Overweight", "Obesity"))
  )

# Remove height column (we do not use it for the analysis)
data <- data[, !names(data) %in% "Height"]

#  Convert Obesity to binary classification
data$Obesity <- ifelse(data$Obesity %in% c("Underweight", "Normal"), "Non-Obese", "Overweight/Obese")
data$Obesity <- factor(data$Obesity, levels = c("Non-Obese", "Overweight/Obese"))

#  Convert transport to active/passive
data$Transport <- ifelse(data$Transport %in% c("Walking", "Bike"), "Active", "Passive")
data$Transport <- as.factor(data$Transport)

# Check missing values
sum(is.na(data))
summary(data)
str(data)

#EDA -OPTIONAL

# Plot distributions
ggplot(data, aes(x = Obesity)) +
  geom_bar(fill = "lightblue") +
  ggtitle("Distribution of Obesity Levels") +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

# Gender vs Obesity
ggplot(data, aes(x = Gender, fill = Obesity)) +
  geom_bar(position = "dodge") +
  ggtitle("Gender vs Obesity")

# Meals per Day vs Obesity
ggplot(data, aes(x = MealsPerDay, fill = Obesity)) +
  geom_bar(position = "dodge") +
  ggtitle("Meals Per Day vs Obesity") +
  theme_minimal()

# Family History vs Obesity
mosaicplot(table(data$FamilyHistory, data$Obesity), main = "Family History vs Obesity", shade = TRUE)

#MODELS

#CIT MODEL FOR BASELINE 

# test and train set
set.seed(123)
trainIndex <- createDataPartition(data$Obesity, p = 0.7, list = FALSE)
train_data <- data[trainIndex, ]
test_data <- data[-trainIndex, ]

# Cross-validation and tuning grid

tune_grid <- expand.grid(mincriterion = seq(0.95, 0.99, by = 0.01))

# train the model
model <- train(
  Obesity ~ .,
  data = train_data,
  method = "ctree",
  trControl = trainControl(method = "cv", number = 5),
  tuneGrid = tune_grid)

# best parameters
print(model$bestTune)

# test different maxdepth
maxdepth_values <- 1:10
best_model <- NULL
best_accuracy <- 0
best_maxdepth <- NULL

for (maxdepth in maxdepth_values) {
  cit_tree <- ctree(
    Obesity ~ .,
    data = train_data,
    control = ctree_control(mincriterion = model$bestTune$mincriterion, maxdepth = maxdepth)
  )
  predictions <- predict(cit_tree, newdata = test_data)
  cm <- confusionMatrix(predictions, test_data$Obesity)
  accuracy <- cm$overall["Accuracy"]
  
  if (accuracy > best_accuracy) {
    best_accuracy <- accuracy
    best_model <- cit_tree
    best_maxdepth <- maxdepth
  }
}

print(best_maxdepth)
print(best_accuracy)

# final CIT
cit_model <- ctree(
  Obesity ~ .,
  data = train_data,
  control = ctree_control(mincriterion = model$bestTune$mincriterion, maxdepth = 4))

plot(cit_model, gp = gpar(fontsize = 7))

# predictions on test set
predictions <- predict(cit_model, newdata = test_data)
cm <- confusionMatrix(predictions, test_data$Obesity)
print(cm)

# calculate feauture importance 
importance <- varimp(cit_model)
importance_sorted <- sort(importance, decreasing = TRUE)

importance_df <- data.frame(
  Feature = names(importance_sorted),
  Importance = importance_sorted
)

# plot the variables
ggplot(importance_df, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  coord_flip() +
  labs(title = "Feature Importance for Obesity Prediction", x = "Features", y = "Importance") +
  theme_minimal()


# Random Forest Model
set.seed(123)

# Cross-validation και tuning grid
rf_trainControl <- trainControl(method = "cv", number = 5)
rf_tuneGrid <- expand.grid(mtry = 2:6) # #try 6 differnet mtry

# train Random Forest
rf_model <- train(
  Obesity ~ .,
  data = train_data,
  method = "rf",
  trControl = rf_trainControl,
  tuneGrid = rf_tuneGrid,
  importance = TRUE
)
print(rf_model$bestTune)

# evaluate on test set
rf_predictions <- predict(rf_model, newdata = test_data)
rf_cm <- confusionMatrix(rf_predictions, test_data$Obesity)
print(rf_cm)


# most important feaurures
rf_importance <- varImp(rf_model, scale = FALSE)
print(rf_importance)

# plot
plot(rf_importance, main = "Variable Importance in Random Forest")

importance <- varImp(rf_model, scale = FALSE) # Calculate Permutation Importance 
print(importance)

importance_df <- data.frame(
  Feature = rownames(importance$importance),
  Importance = importance$importance[, 1] ) # Convert importance to a data frame 

importance_df <- importance_df[order(-importance_df$Importance), ] # Sort features by impo 
top_5_features <- importance_df[1:5, ] # Select the top 5 features

# Create a compact plot for the top 5 features
ggplot(top_5_features, aes(x = Importance, y = reorder(Feature, Importance)))+
  geom_bar(stat = "identity", fill = "royalblue", color = "black") +
  labs(title = "Top Feature Importance", x = "Importance", y = "Features") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"), axis.title = element_text(size = 10),
    axis.text = element_text(size = 9))

# calculate Partial Dependence  for "Overweight/Obese"
pdp_age <- partial(
  object = rf_model,
  pred.var = "Age",
  train = train_data,
  prob = TRUE,
  which.class = "Overweight/Obese"
)
pdp_age_df <- as.data.frame(pdp_age)

ggplot(pdp_age_df, aes(x = Age, y = yhat)) +
  geom_line(color = "blue", size = 1) +
  labs(title = "Partial Dependence Plot for Age (Overweight/Obese)",
       x = "Age", y = "Predicted Probability (yhat)") +
  theme_minimal()


#ALE plots

# create Predictor
predictor <- Predictor$new(
  model = rf_model,       # RF Model
  data = train_data[, -ncol(train_data)], 
  y = train_data$Obesity  
)

# ALE for "Age"
ale_age <- FeatureEffect$new(
  predictor = predictor,
  feature = "Age",
  method = "ale"
)
plot(ale_age) + ggtitle("ALE Plot for Age")

# ALE for "VeggieIntake"
ale_veggie <- FeatureEffect$new(
  predictor = predictor,
  feature = "VeggieIntake",
  method = "ale"
)
plot(ale_veggie) + ggtitle("ALE Plot for Veggie Intake")


# ALE for "Snacking"
ale_snacking <- FeatureEffect$new(
  predictor = predictor,
  feature = "Snacking",
  method = "ale"
)
plot(ale_snacking) + ggtitle("ALE Plot for Snacking")

# ALE for Gender
ale_gender <- FeatureEffect$new(
  predictor = predictor,
  feature = "Gender",
  method = "ale"
)
plot(ale_gender) + ggtitle("ALE Plot for Gender")


# Partial dependence plot for  2 characteristics

library(patchwork)

pdp_gender_age <- FeatureEffect$new(
  predictor,
  feature = c("Gender", "Age"),
  method = "pdp"
)

plot_gender_age <- plot(pdp_gender_age) +
  ggtitle("Gender and Age") +
  theme(
    plot.title = element_text(size = 11, hjust = 0.5), 
    axis.title = element_text(size = 8), 
    axis.text = element_text(size = 7) )

pdp_diet <- FeatureEffect$new(
  predictor,
  feature = c("VeggieIntake", "FastFood"),
  method = "pdp"
)
plot_diet <- plot(pdp_diet) +
  ggtitle(" Eating Habits") +
  theme(
    plot.title = element_text(size = 11,  hjust = 0.5), 
    axis.title = element_text(size = 8),  
    axis.text = element_text(size = 7)   )

plot_gender_age + plot_diet

#support vector machines
#train the model 
tuneGrid <- expand.grid(.C = c(0.1, 1, 10), .sigma = c(0.01, 0.1, 1))
svm_model <- train(
  Obesity ~ ., data = train_data,
  method = "svmRadial",
  tuneGrid = tuneGrid,
  preProcess = c("center", "scale"),  #scaling
  trControl = trainControl(method = "cv", number = 10)
)

print(svm_model$bestTune)


# SVM Predictions and Evaluation
svm_predictions <- predict(svm_model, newdata = test_data)
conf_matrix <- confusionMatrix(svm_predictions, test_data$Obesity)
print(conf_matrix)

conf_table <- as.table(conf_matrix$table)
conf_df <- as.data.frame(conf_table)
colnames(conf_df) <- c("True", "Predicted", "Count")

#  heatmap

ggplot(conf_df, aes(x = Predicted, y = True, fill = Count)) +
  geom_tile(color = "white") +
  geom_text(aes(label = Count), color = "black", size = 5) +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(title = "Heatmap of SVM Classification Results",
       x = "Predicted Class",
       y = "True Class") +
  theme_minimal()


# create Predictor for SVM
predictor_svm <- Predictor$new(
  model = svm_model,
  data = train_data[, -ncol(train_data)],  
  y = train_data$Obesity
)

# calculate Feature Importance
feature_importance <- FeatureImp$new(predictor_svm, loss = "ce")  # Cross-entropy loss
plot(feature_importance) + ggtitle("Feature Importance for SVM")

feature_importance_plot <- plot(feature_importance) +
  ggtitle("Feature Importance for SVM") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 8, hjust = 0.5), 
    axis.title = element_text(size = 6),
    axis.text = element_text(size = 5),
    legend.title = element_text(size = 5),
    legend.text = element_text(size = 4)   
  )


# Feature importance for SVM
heatmap <- ggplot(conf_df, aes(x = Predicted, y = True, fill = Count)) +
  geom_tile(color = "white") +
  geom_text(aes(label = Count), color = "black", size = 5) +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(title = "Heatmap of SVM Classification Results",
       x = "Predicted Class",
       y = "True Class") +
  theme_minimal()



combined_plot <- heatmap + feature_importance_plot + plot_layout(widths = c(1.5, 1))
print(combined_plot)

# create model comparison
model_comparison <- data.frame(
  Model = c("CIT", "Random Forest", "SVM"),
  Accuracy = c(84.44, 89.83, 86.93),
  Sensitivity = c(85.84, 89.50, 84.02),
  Specificity = c(83.27, 90.11, 89.35),
  Kappa = c(68.77, 79.52, 73.57)
)

library(tidyr)
model_comparison_long <- pivot_longer(
  model_comparison,
  cols = Accuracy:Kappa,
  names_to = "Metric",
  values_to = "Percentage"
)

ggplot(model_comparison_long, aes(x = Metric, y = Model, fill = Percentage)) +
  geom_tile(color = "white") +
  geom_text(aes(label = sprintf("%.2f%%", Percentage)), color = "black", size = 3) + 
  scale_fill_gradient(low = "lightpink", high = "darkred", name = "Percentage") + 
  labs(
    title = "Model Performance Comparison",
    x = "Metric",
    y = "Model"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"), 
    axis.title = element_text(size = 12), 
    axis.text = element_text(size = 10), 
    legend.title = element_text(size = 12), 
    legend.text = element_text(size = 10)  
  )

