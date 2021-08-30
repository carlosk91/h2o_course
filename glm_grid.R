library(h2o)
h2o.init()

data <- h2o.importFile("http://h2o-public-test-data.s3.amazonaws.com/smalldata/airlines/allyears2k_headers.zip")

nrow(data)

parts <- h2o.splitFrame(data, c(0.8, 0.1), seed = 69)
train <- parts[[1]]
valid <- parts[[2]]
test <- parts[[3]]

h2o.describe(data)
y <- 'IsArrDelayed'
x_forehead_slap <- setdiff(colnames(data), y)

x_all <- setdiff(colnames(data), 
                c('ArrDelay','DepDelay','CarrierDelay','WeatherDelay',
                  'NASDelay', 'SecurityDelay', 'LateAircraftDelay',
                  'IsDepDelayed', 'IsArrDelayed', 'ActualElapsedTime')
                )

x_likely <- c('Month', 'DayOfWeek', 'UniqueCarrier', 'Origin', 'Dest',
              'Distance', 'Cancelled', 'Diverted')
system.time(
  m_def <- h2o.glm(x_all, y, train, validation_frame = valid, family = 'binomial')
)

h2o.performance(m_def, valid = T)

g <- h2o.grid('glm', 
              search_criteria = 
                list(strategy = 'RandomDiscrete',
                     max_models = 8,
                     max_runtime_secs = 30),
              hyper_params = 
                list(alpha = seq(0, 0.99, 0.01)),
              grid_id = 'random8',
              x = x_all, ## Not grideable
              y = y,
              training_frame = train,
              validation_frame = valid, 
              family = 'binomial',
              lambda_search = T ## Not grideable
              )

g


g2 <- h2o.grid('glm', 
              search_criteria = 
                list(strategy = 'Cartesian'),
              hyper_params = 
                list(alpha = c(0, 0.2, 0.4, 0.5, 0.6, 0.8,0.99)),
              grid_id = 'all7',
              x = x_likely, ## Not grideable
              y = y,
              training_frame = train,
              validation_frame = valid, 
              family = 'binomial',
              lambda_search = T ## Not grideable
)

g2

