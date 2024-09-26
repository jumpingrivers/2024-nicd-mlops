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

life_expectancy_data = tidyr::drop_na(life_expectancy)


# c) Split the data into train and test sets

life_expectancy_split = rsample::initial_split(life_expectancy_data, prop = 0.8)
train_data = training(life_expectancy_split)
test_data = testing(life_expectancy_split)



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

model = recipe(
  `Life expectancy` ~ `percentage expenditure` + `Total expenditure` +
    Population + BMI + Schooling,
  data = train_data
) |>
  workflow(nearest_neighbor(mode = "regression")) |>
  fit(train_data)


# e) Generate model predictions for the test data by running the code below

model_pred = predict(model, test_data)


# f) Run the code below to compute the root-mean-square error (RMSE).

# Hint: Make a note of the value as you'll need it later!

model_pred |>
  dplyr::bind_cols(test_data) |>
  yardstick::rmse(truth = `Life expectancy`, estimate = .pred)


# g) Set up a Vetiver model using your trained model

v_model = vetiver::vetiver_model(model,
                                 model_name = "k-nn",
                                 description = "life-expectancy")
v_model



# Task 3: Deploying your model

# h) Deploy your model to the localhost as a {plumber} API

plumber::pr() |>
  vetiver::vetiver_api(v_model) |>
  plumber::pr_run()


# i) Check that the API is working in the browser


# j) Predict the life expectancy for the following inputs:
#
#    - `percentage expenditure`: 46
#    - `total expenditure`: 9
#    - `population`: 5000000
#    - BMI: 64
#    - Schooling: 20


# k) In a separate console running in the terminal, run the code below
#    to check that you can run programmatic queries:

# Check the local deployment
base_url = "127.0.0.1:8080/"  # Double-check the 4-digit port number
url = paste0(base_url, "ping")
r = httr::GET(url)
metadata = httr::content(r, as = "text", encoding = "UTF-8")
jsonlite::fromJSON(metadata)



# Task 4: Detecting model drift

# How time flies: it is now 2010!

# l) Run the code below to load the data between 2005 and 2009, and drop
#    missing values

life_expectancy_latest = life_expectancy_full |>
  dplyr::filter(Year %in% c(2005:2009)) |>
  dplyr::select(`Life expectancy`, `percentage expenditure`,
                `Total expenditure`, Population, BMI, Schooling)

life_expectancy_latest = tidyr::drop_na(life_expectancy_latest)


# m) Predict the life expectancy for this data using your pretrained model.

model_pred = predict(model, life_expectancy_latest)


# n) Now compute the RMSE. How does it compare to the value you computed for
#    part (f) above?

model_pred |>
  dplyr::bind_cols(life_expectancy_latest) |>
  yardstick::rmse(truth = `Life expectancy`, estimate = .pred)


# o) Apparently our model is not quite as accurate as it used to be. Retrain
#    it using data from 2005 to 2009, remembering to split the data into train
#    and test sets before you begin.

life_expectancy_split = rsample::initial_split(life_expectancy_latest,
                                               prop = 0.8)
train_data = training(life_expectancy_split)
test_data = testing(life_expectancy_split)

model = recipe(
  `Life expectancy` ~ `percentage expenditure` + `Total expenditure` +
    Population + BMI + Schooling,
  data = train_data
) |>
  workflow(nearest_neighbor(mode = "regression")) |>
  fit(train_data)


# p) Now compute the RMSE score using the unseen test data. Has the score
#    improved?

model_pred = predict(model, test_data)

model_pred |>
  dplyr::bind_cols(test_data) |>
  yardstick::rmse(truth = `Life expectancy`, estimate = .pred)
