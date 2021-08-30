library(h2o)
h2o.init()
# h2o.shutdown(prompt = F)
data <- h2o.importFile("http://coursera.h2o.ai/cacao.882.csv")

parts <- h2o.splitFrame(data, c(0.8, 0.1), seed = 69)
train <- parts[[1]]
valid <- parts[[2]]
test <- parts[[3]]

y <- 'Rating'
x_all <- setdiff(colnames(data), c('Rating'))

h2o.describe(train)

system.time(
  m_DLR_def <- 
    h2o.deeplearning(
      x = x_all,
      y = y,
      training_frame = train,
      validation_frame = valid,
      model_id = 'DLR_def',
      variable_importances = T
    )
) # 3s, MAE Train: 0.2460197, Valid: 0.3408197, Test: 0.3738347


system.time(
  m_DLR_tuned <- 
    h2o.deeplearning(
      x = x_all,
      y = y,
      training_frame = train,
      validation_frame = valid,
      model_id = 'DLR_tuned',
      variable_importances = T,
      hidden = c(400, 400),
      input_dropout_ratio = 0.1,
      hidden_dropout_ratios = c(0.2, 0.2),
      l1 = 3e-6,
      l2 = 1e-5,
      activation = 'RectifierWithDropout',
      epochs = 40
    )
)

system.time(g <- h2o.grid(
  'deeplearning',
  search_criteria = list(
    strategy = 'RandomDiscrete',
    max_models = 20
  ),
  hyper_params = list(
    seed = c(88),
    #placeholder
    l1 = c( 1e-6, 3e-6, 1e-5, 3e-5),
    l2 = c( 1e-6, 3e-6, 1e-5, 3e-5),
    input_dropout_ratio = c(0, 0.1, 0.2),
    hidden_dropout_ratios = list(c(0, 0),
                                 c(0.2, 0.2),
                                 c(0.4, 0.4)),
    
    
  ),
  grid_id = 'dl_grid',
  x = x_all,
  y = y,
  hidden = c(400, 400),
  # epochs = 0.01, #To test it quickly
  epochs = 40,
  training_frame = train,
  validation_frame = valid,
  activation = 'RectifierWithDropout' # If you want hidden dropout ratios 
  # you need to place 'RectifierWithDropout'
)
) #

h2o.feature_impo