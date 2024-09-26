library("ggplot2")
library("readr")
library("tidymodels")
library("kknn")


# Task 1: Data loading and tidying

# Context: It is 2005. The World Health Organisation (WHO) has just released
# the latest data on life expectancy stratified by country and year.

# a) Load and filter the life expectancy data by running the code below

life_expectancy_full = readr::read_csv("./life_expectancy.csv")
life_expectancy = life_expectancy_full |>
  dplyr::filter(Year < 2005) |>
  dplyr::select(`Life expectancy`, `percentage expenditure`,
                `Total expenditure`, Population, BMI, Schooling)


# b) Drop missing values from the data

# Your code here


# c) Split the data into train and test sets

# Your code here



# Task 2: Modelling

# d) Set up a model recipe. Remember we are predicting `Life expectancy` using
#    the following features:
#
#    - `percentage expenditure`
#    - `Total expenditure`
#    - Population
#    - BMI
#    - Schooling

# Hint: try a K-nearest-neighbour model, but remember this is now a
# "regression" task as opposed to a "classification" task!

# Your code here


# e) Generate model predictions for the test data by running the code below

model_pred = predict(model, test_data)


# f) Run the code below to compute the root-mean-square error (RMSE).

# Hint: Make a note of the value as you'll need it later!

model_pred |>
  dplyr::bind_cols(test_data) |>
  yardstick::rmse(truth = `Life expectancy`, estimate = .pred)


# g) Set up a Vetiver model using your trained model

# Your code here



# Task 3: Deploying your model

# h) Deploy your model to the localhost as a {plumber} API

# Your code here


# i) Check that the API is working in the browser


# j) Predict the life expectancy for the following inputs:
#
#    - `percentage expenditure`: 46
#    - `total expenditure`: 9
#    - `population`: 5000000
#    - BMI: 64
#    - Schooling: 20



# Task 4: Detecting model drift

# How time flies: it is now 2010!

# k) Run the code below to load the data between 2005 and 2009, and drop
#    missing values

life_expectancy_latest = life_expectancy_full |>
  dplyr::filter(Year %in% c(2005:2009)) |>
  dplyr::select(`Life expectancy`, `percentage expenditure`,
                `Total expenditure`, Population, BMI, Schooling)

life_expectancy_latest = tidyr::drop_na(life_expectancy_latest)


# l) Predict the life expectancy for this data using your pretrained model.

# Your code here


# m) Now compute the RMSE for this data. How does it compare to the value you
#    computed for part (f) above?

# Your code here


# n) Apparently our model is not quite as accurate as it used to be. Retrain
#    it using data from 2005 to 2009, remembering to split the data into train
#    and test sets before you begin.

# Your code here


# o) Now compute the RMSE score using the unseen test data. Has the score
#    improved?

# Your code here
