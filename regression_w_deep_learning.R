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

y <- 'ArrDelay'
xWithDep <- setdiff(
  colnames(data),
  c(
    'ArrDelay',
    'IsArrDelayed',
    'ActualElapsedTime',
    'ArrTime',
    'TailNum' # High cardinality, (presumed) low information
  )
)

system.time(
  m_DLR_def <- 
    h2o.deeplearning(
      x = xWithDep,
      y = y,
      training_frame = train,
      validation_frame = valid,
      model_id = 'DLR_def',
      variable_importances = T
    )
)

h2o.performance(m_DLR_def, valid = T)
plot(m_DLR_def)

# W 200 epochs

system.time(
  m_DLR_def <- 
    h2o.deeplearning(
      x = xWithDep,
      y = y,
      training_frame = train,
      validation_frame = valid,
      model_id = 'DLR_def',
      variable_importances = T,
      epochs = 200
    )
)

h2o.performance(m_DLR_def, valid = T)
plot(m_DLR_def)

# It appears to have a laplace distribution ()

system.time(
  m_laplace_def <- 
    h2o.deeplearning(
      x = xWithDep,
      y = y,
      training_frame = train,
      validation_frame = valid,
      model_id = 'DLR_def',
      variable_importances = T,
      epochs = 200,
      distribution = 'laplace'
    )
)

h2o.performance(m_laplace_def, valid = T)
plot(m_laplace_def)
