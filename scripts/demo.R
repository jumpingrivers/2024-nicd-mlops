library("ggplot2")
library("palmerpenguins")
library("tidymodels")
library("kknn")

# Visualise the data
ggplot(penguins, aes(flipper_length_mm, body_mass_g)) +
  geom_point(aes(colour = species, shape = island)) +
  theme_minimal() +
  xlab("Flipper Length(mm)") +
  ylab("Body Mass(g)") +
  viridis::scale_colour_viridis(discrete = TRUE)

# Tidy and split the data
penguins_data = tidyr::drop_na(penguins)
penguins_split = rsample::initial_split(penguins_data, prop = 0.8)
train_data = training(penguins_split)
test_data = testing(penguins_split)

# Set up the model recipe
model = recipe(
  species ~ island + flipper_length_mm + body_mass_g,
  data = train_data
) |>
  workflow(nearest_neighbor(mode = "classification")) |>
  fit(train_data)

# Make predictions using the model
model_pred = predict(model, test_data)

# Accuracy for unseen test data
mean(
  model_pred$.pred_class == as.character(
    test_data$species
  )
)

# Create a Vetiver model
v_model = vetiver::vetiver_model(model,
                                 model_name = "k-nn",
                                 description = "penguin-species")
v_model

# Examine Vetiver model
names(v_model)
v_model$description
v_model$metadata

# Deploy model locally and make a note of the port number
plumber::pr() |>
  vetiver::vetiver_api(v_model) |>
  plumber::pr_run()

# Navigate through the Plumber API and try generating predictions for some
# example inputs

# We can also query the API *programmatically*!
# Open a separate R session by opening the terminal and running `R`
# Now run the following commands to query the API:

# Check the local deployment
base_url = "127.0.0.1:8080/"  # Double-check the 4-digit port number
url = paste0(base_url, "ping")
r = httr::GET(url)
metadata = httr::content(r, as = "text", encoding = "UTF-8")
jsonlite::fromJSON(metadata)

# Predict with deployed model
url = paste0(base_url, "predict")
endpoint = vetiver::vetiver_endpoint(url)
pred_data = test_data |>
  dplyr::select(
    "island", "flipper_length_mm", "body_mass_g"
  ) |>
  dplyr::slice_sample(n = 10)
predict(endpoint, pred_data)
