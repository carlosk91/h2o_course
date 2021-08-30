library(h2o)
h2o.init()
# h2o.shutdown(prompt = F)

data <-
  h2o.importFile(
    "http://h2o-public-test-data.s3.amazonaws.com/smalldata/airlines/allyears2k_headers.zip"
  )

parts <- h2o.splitFrame(data, c(0.8, 0.1), seed = 69)
train <- parts[[1]]
valid <- parts[[2]]
test <- parts[[3]]

dim(train)
dim(valid)
dim(test)

y <- 'IsArrDelayed'

x_forehead_slap <- setdiff(colnames(data), y)
x_all <- setdiff(
  colnames(data),
  c(
    'ArrDelay',
    'DepDelay',
    'CarrierDelay',
    'WeatherDelay',
    'NASDelay',
    'SecurityDelay',
    'LateAircraftDelay',
    'IsDepDelayed',
    'IsArrDelayed',
    'ActualElapsedTime',
    'ArrTime'
  )
)

m_def <- h2o.deeplearning(
  x = x_all,
  y = y,
  training_frame = train,
  validation_frame = valid
)


h2o.performance(m_def, train = T)
h2o.performance(m_def, valid = T)
h2o.performance(m_def, test)
plot(m_def)

# Lets improve it by adding epochs

m_200_epochs <- h2o.deeplearning(
  x = x_all,
  y = y,
  training_frame = train,
  validation_frame = valid,
  epochs = 200,
  stopping_rounds = 5,
  # Default
  stopping_tolerance = 0,
  # Default
  stopping_metric = 'logloss'
)

h2o.performance(m_200_epochs, valid = T)
h2o.performance(m_200_epochs, test)
plot(m_200_epochs)

h2o.scoreHistory(m_200_epochs)


## Adding one layer

m_200x200x200 <- h2o.deeplearning(
  x = x_all,
  y = y,
  training_frame = train,
  validation_frame = valid,
  epochs = 200,
  hidden = c(200, 200, 200)
)

h2o.performance(m_200x200x200, valid = T)
h2o.performance(m_200x200x200, test)
plot(m_200x200x200)

## Didnt improve, let use one less layer but with 400 neurons

m_400x400 <- h2o.deeplearning(
  x = x_all,
  y = y,
  training_frame = train,
  validation_frame = valid,
  epochs = 200,
  hidden = c(400, 400)
)

h2o.performance(m_400x400, valid = T)
h2o.performance(m_400x400, test)
plot(m_400x400)

## It got almost the same results

## Lets see the number of units
models <- c(m_def, m_200_epochs, m_200x200x200, m_400x400)
sapply(models, h2o.auc, valid = T)
m_def@model$model_summary$units

sapply(models, function(m) {
  u = m@model$model_summary$units
  sapply(2:length(u), function(ix) {
    u[ix - 1] * u[ix]
  })
})

sapply(models, function(m) {
  u = m@model$model_summary$units
  sum(sapply(2:length(u), function(ix) {
    u[ix - 1] * u[ix]
  }))
})

## Functions to get the number of weights and biases

h2o.describe(train) # To know how many levels a factor has

# TailNum has a lot of levels. It shouldn't be impactful in the training, lets
# drop it.

x2 <- setdiff(x_all, 'TailNum')

system.time(
  m2_def <- h2o.deeplearning(
    x = x_all,
    y = y,
    training_frame = train,
    validation_frame = valid
  )
)

system.time(
  m2_200_epochs <- h2o.deeplearning(
    x = x_all,
    y = y,
    training_frame = train,
    validation_frame = valid,
    epochs = 200
  )
)

system.time(
  m2_200x200x200 <- h2o.deeplearning(
    x = x_all,
    y = y,
    training_frame = train,
    validation_frame = valid,
    epochs = 200,
    hidden = c(200, 200, 200)
  )
)

system.time(
  m2_400x400 <- h2o.deeplearning(
    x = x_all,
    y = y,
    training_frame = train,
    validation_frame = valid,
    epochs = 200,
    hidden = c(400, 400)
  )
)

