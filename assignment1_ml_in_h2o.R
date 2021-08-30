#### Successful videogame: Assignment 1####
library(tidyverse)
library(h2o)

#### Artificial dataset ####
set.seed(123)
n <- 1000

content_ratings <-
  data.frame(
    content_rating = c('E', 'E10+', 'T', 'M', 'Ao', 'RP'),
    weight = c(0.16, 0.24, 0.22, 0.35, 0.02, 0.01)
  )

df <- tibble(
  content_rating =
    sample(x = content_ratings$content_rating, size = n, 
           replace = T, prob = content_ratings$weight), # Random content ratings
  avg_length = pmax(rnorm(n, mean = 20, sd = 10), 1),  # Random avg hrs length
  in_console = runif(n) > 0.2, # Random PS or XB launch, it could be both
  in_pc = runif(n) > ifelse(in_console, 0.4, 0), # If no console, then pc
  months_to_development = pmax((10 * avg_length > 40) + round(rnorm(n, 18, 6)), 0), # Dev time impacted by game length
  money_spent = months_to_development * pmax(rnorm(n, mean = 1000, 150), 1000), # Monthly money spent times rand salary
  price = round(pmax(pmin(rnorm(n, mean = 30, 5), 60), 10),-1), # Game price, full randomness
  units_sold = 
    round(10000 + rnorm(n, ifelse(avg_length > 30, 3000, 1500), 500) + # more lenght, more $
      (content_rating %in% c('T', 'M', 'Ao')) * rnorm(n, 6000, 1000)  +
      (in_console + in_pc) * rnorm(n, 3000, 300), -2)
)

#### Creating ML Model ####
h2o.init()
y <- 'units_sold'
x <- setdiff(names(df), c('id', y))
h2o_df <- as.h2o(df)

parts <- h2o.splitFrame(h2o_df, 0.8, seed = 123)

train <- parts[[1]]
test <- parts[[2]]

good_gbm <-
  h2o.gbm(x, y, train, model_id = 'good_gbm', seed = 123,
          stopping_rounds = 5, stopping_tolerance = 1e-4, nfolds = 9)

h2o.performance(good_gbm, train = T) # MAE 2545.588
h2o.performance(good_gbm, test) # MAE 2815.818


bad_gbm <-
  h2o.gbm(x, y, train, ntrees = 1000, max_depth = 100, seed = 123,
          model_id = 'bad_gbm', nfolds = 9) # A lot of trees, a lot of depth

h2o.performance(bad_gbm, train = T) # MAE 50.08394
h2o.performance(bad_gbm, test) # MAE 3151.755
