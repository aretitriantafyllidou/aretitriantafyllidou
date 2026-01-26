# Predicting obesity levels using machine learning methods


In this project, I used machine learning project to analyze health and lifestyle data to predict obesity levels using supervised learning algorithms such as Random Forest, Support Vector Machines, and Conditional Inference Trees.

It addresses the research question:
*How effectively can machine learning models predict obesity using lifestyle data, and which factors have the greatest impact on classification?*

## Key Findings

- Random Forest achieved the highest accuracy (89.83%) with balanced sensitivity (89.50%) and specificity (90.11%)
- Age emerged as the most significant predictor across all models
- Dietary habits (vegetable intake, fast food consumption) consistently ranked as critical factors
- Gender differences were observed, with females showing lower obesity risk at younger ages

##  Dataset
The data used in this project is available on Kaggle:
[Obesity Dataset](https://www.kaggle.com/datasets/suleymansulak/obesity-dataset)

### Methodology
- Data Preprocessing and cleaning
- Engineered features 
- Train-test split: 70% training, 30% testing

### Machine Learning Models
- *Conditional Inference Tree (CIT)* used as a baseline model for interpretability with accuracy 84.44%
- *Random Forest (RF)* used to enhance accuracy through ensemble learning achieving accuracy 89.83%. Hyperparameters: mtry = 6 (optimized via 5-fold CV)
- *Support Vector Machine (SVM)* used to capture non-linear relationships with accuracy 86.93%. Kernel: Radial Basis Function (RBF) and Hyperparameters: C = 10, σ = 0.01 (optimized via 10-fold CV)
- for *Model Interpretability* were used  interpretability techniques to understand model behavior such as
- Feature Importance Analysis
- Partial Dependence Plots (PDPs)
- Accumulated Local Effects (ALE)

### Results Summary

Top 5 Most Important Features (Random Forest)

- Age (Importance: 81.71)
- Vegetable Intake (Always)
- Gender (Female)
- Fast Food Consumption (No)
- Meals Per Day (3+)

### Technologies Used

Language: R. Key Libraries:
- caret (Model training and evaluation)
- randomForest ( Random Forest implementation)
- e1071  (SVM implementation)
- partykit (Conditional Inference Trees)
- iml (Model interpretability)
- pdp (Partial Dependence Plots)
- ggplot2 ( Data visualization)
- dplyr - (Data manipulation)
