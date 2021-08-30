library(tidyverse)
library(h2o)

h2o.init()

#### Importing from client ####
x <- seq(0, 10, 0.01)
y <- jitter(sin(x), 1000)

sine_wave <- data.frame(a = x, b = y)

sine_wave_h2o <- as.h2o(sine_wave)

sine_wave_h2o
tail(sine_wave_h2o)

# Opposite direction
d <- as.data.frame(sine_wave_h2o)
head(d)

#### Artificial datasets ####

set.seed(123)

n <- 1000

blood_types <- data.frame(blood_type = c('A', 'O', 'AB', 'B'),
                          weight = c(0.4, 0.3, 0.2, 0.1))


d <- tibble(
  id = 1:n,
  blood_type = sample(
    x = blood_types$blood_type,
    size = n,
    replace = T,
    prob = blood_types$weight
  ),
  age = runif(n, min = 18, max = 65),
  healthy_eating = pmin(pmax(round(rnorm(
    n, 5, 2
  )), 0), 9),
  active_lifestyle = pmin(pmax((1 * age < 30) + round(rnorm(
    n, 5, 2
  )), 0), 9),
  income = round(
    20000 + ((age * 2) ^ 2) + healthy_eating * 500 +
      active_lifestyle * 300 + runif(n, 0 , 5000),
    -2
  )
)

as.h2o(d, destination_frame = 'people')

people <- h2o.getFrame('people')
summary(people)


#### Train Validation Test sets ####

parts <- h2o.splitFrame(
  people,
  c(0.8, 0.1),
  destination_frames =
    c('people_train', 'people_valid', 'people_test'),
  seed = 123
)

sapply(parts, nrow)

train <- parts[[1]]
valid <- parts[[2]]
test <- parts[[3]]

#### GBM with valid ####
y <- 'income'
x <- setdiff(names(train), c('id', y))

gbm_valid <-
  h2o.gbm(x, y, train, ntrees = 1000, model_id = 'defaults_r', validation_frame = valid)

h2o.performance(gbm_valid, train = T)
h2o.performance(gbm_valid, valid = T)
h2o.performance(gbm_valid, test)


plot(gbm_valid, timestep = "duration", metric = "deviance")
plot(gbm_valid, timestep = "number_of_trees", metric = "deviance")
plot(gbm_valid, timestep = "number_of_trees", metric = "rmse")
plot(gbm_valid, timestep = "number_of_trees", metric = "mae")
best_tree <- which.min((h2o.scoreHistory(gbm_valid)$validation_rmse))

#### Cross-validation ####

parts <- h2o.splitFrame(
  people,
  0.9,
  destination_frames =
    c('people_train', 'people_test'),
  seed = 123
)

sapply(parts, nrow)

train <- parts[[1]]
test <- parts[[2]]

y <- 'income'
x <- setdiff(names(train), c('id', y))

gbm_cross_valid <- h2o.gbm(x, 
                           y, 
                           train, 
                           # validation_frame = valid, #Added it bc of test
                           model_id = 'gbm_cross_valid',
                           nfolds = 9)

h2o.performance(gbm_cross_valid, train = T)
h2o.performance(gbm_cross_valid, xval = T)
# h2o.performance(gbm_cross_valid, valid = T) #Added it bc of test
h2o.performance(gbm_cross_valid, test)

plot(gbm_cross_valid, timestep = "duration", metric = "deviance")
plot(gbm_cross_valid, timestep = "number_of_trees", metric = "deviance")
