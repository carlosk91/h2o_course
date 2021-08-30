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

y <- 'IsArrDelayed'
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

x2 <- setdiff(x_all, 'TailNum')

system.time(g <- h2o.grid(
  'deeplearning',
  search_criteria = list(
    strategy = 'RandomDiscrete',
    # max_models = 4 # When testing with epochs = 0.01 
    max_models = 12
    ),
    hyper_params = list(
      seed = c(77),
      #placeholder
      l1 = c(0, 1e-6, 3e-6, 1e-5),
      l2 = c(0, 1e-6, 3e-6, 1e-5),
      input_dropout_ratio = c(0, 0.1, 0.2, 0.3),
      hidden_dropout_ratios = list(c(0, 0),
                                   c(0.2, 0.2),
                                   c(0.4, 0.4),
                                   c(0.6, 0.6))
      
    ),
    grid_id = 'dlB',
  x = x2,
  y = y,
  hidden = c(400, 400),
  # epochs = 0.01, #To test it quickly
  epochs = 40,
  training_frame = train,
  validation_frame = valid,
  activation = 'RectifierWithDropout' # If you want hidden dropout ratios 
  # you need to place 'RectifierWithDropout'
  )
)

g

# H2O Grid Details
# ================
#   
#   Grid ID: dlB 
# Used hyper parameters: 
#   -  hidden_dropout_ratios 
# -  input_dropout_ratio 
# -  l1 
# -  l2 
# -  seed 
# Number of models: 12 
# Number of failed models: 0 
# 
# Hyper-Parameter Search Summary: ordered by increasing logloss
# hidden_dropout_ratios input_dropout_ratio     l1     l2 seed    model_ids             logloss
# 1             [0.4, 0.4]                 0.0 3.0E-6 1.0E-6   77  dlB_model_4  0.3530004938419034
# 2             [0.2, 0.2]                 0.0 1.0E-6    0.0   77  dlB_model_1   0.376202564815174
# 3             [0.0, 0.0]                 0.0    0.0 3.0E-6   77 dlB_model_10 0.38072618559530874
# 4             [0.0, 0.0]                 0.1    0.0 1.0E-6   77  dlB_model_5  0.4255838666458666
# 5             [0.4, 0.4]                 0.1    0.0 1.0E-5   77  dlB_model_7   0.477777724981707
# 6             [0.4, 0.4]                 0.1 1.0E-6 1.0E-6   77  dlB_model_8  0.4799174521550474
# 7             [0.0, 0.0]                 0.2 1.0E-6 1.0E-5   77  dlB_model_2  0.5353773706347958
# 8             [0.4, 0.4]                 0.2 1.0E-6 3.0E-6   77 dlB_model_12  0.5773175686559155
# 9             [0.0, 0.0]                 0.3 3.0E-6 1.0E-6   77  dlB_model_9  0.5790165019503987
# 10            [0.6, 0.6]                 0.2 1.0E-6 1.0E-6   77  dlB_model_6   0.583816186776641
# 11            [0.2, 0.2]                 0.3 1.0E-6 3.0E-6   77  dlB_model_3  0.5880054548526372
# 12            [0.4, 0.4]                 0.3    0.0 3.0E-6   77 dlB_model_11  0.5923819685378078

system.time(g <- h2o.grid(
  'deeplearning',
  search_criteria = list(
    strategy = 'RandomDiscrete',
    max_models = 8
  ),
  hyper_params = list(
    seed = c(88),
    #placeholder
    l1 = c(0, 1e-6, 3e-6, 1e-5),
    l2 = c(0, 1e-6, 3e-6, 1e-5),
    input_dropout_ratio = c(0, 0.1),
    hidden_dropout_ratios = list(c(0, 0),
                                 c(0.2, 0.2),
                                 c(0.4, 0.4))
    
  ),
  grid_id = 'dlB',
  x = x2,
  y = y,
  hidden = c(400, 400),
  # epochs = 0.01, #To test it quickly
  epochs = 40,
  training_frame = train,
  validation_frame = valid,
  activation = 'RectifierWithDropout' # If you want hidden dropout ratios 
  # you need to place 'RectifierWithDropout'
)
)

g

# H2O Grid Details
# ================
#   
#   Grid ID: dlB 
# Used hyper parameters: 
#   -  hidden_dropout_ratios 
# -  input_dropout_ratio 
# -  l1 
# -  l2 
# -  seed 
# Number of models: 20 
# Number of failed models: 0 
# 
# Hyper-Parameter Search Summary: ordered by increasing logloss
# hidden_dropout_ratios input_dropout_ratio     l1     l2 seed    model_ids             logloss
# 1             [0.4, 0.4]                 0.0    0.0    0.0   88 dlB_model_15  0.3529510491313539
# 2             [0.4, 0.4]                 0.0 3.0E-6 1.0E-6   77  dlB_model_4  0.3530004938419034
# 3             [0.4, 0.4]                 0.0    0.0 3.0E-6   88 dlB_model_18 0.35633844409370274
# 4             [0.0, 0.0]                 0.0    0.0 3.0E-6   88 dlB_model_13  0.3696468777502335
# 5             [0.2, 0.2]                 0.0    0.0 3.0E-6   88 dlB_model_19  0.3735153313350203
# 6             [0.2, 0.2]                 0.0 1.0E-6    0.0   77  dlB_model_1   0.376202564815174
# 7             [0.0, 0.0]                 0.0 3.0E-6 1.0E-5   88 dlB_model_20  0.3766847102555308
# 8             [0.0, 0.0]                 0.0    0.0 3.0E-6   77 dlB_model_10 0.38072618559530874
# 9             [0.0, 0.0]                 0.1    0.0 1.0E-6   77  dlB_model_5  0.4255838666458666
# 10            [0.2, 0.2]                 0.1 1.0E-5    0.0   88 dlB_model_16 0.43214271728622256
# 11            [0.4, 0.4]                 0.1    0.0 1.0E-5   77  dlB_model_7   0.477777724981707
# 12            [0.4, 0.4]                 0.1 1.0E-6 1.0E-6   77  dlB_model_8  0.4799174521550474
# 13            [0.4, 0.4]                 0.1 1.0E-5    0.0   88 dlB_model_14 0.49781118796451224
# 14            [0.4, 0.4]                 0.1 1.0E-5 1.0E-6   88 dlB_model_17  0.5035942836760853
# 15            [0.0, 0.0]                 0.2 1.0E-6 1.0E-5   77  dlB_model_2  0.5353773706347958
# 16            [0.4, 0.4]                 0.2 1.0E-6 3.0E-6   77 dlB_model_12  0.5773175686559155
# 17            [0.0, 0.0]                 0.3 3.0E-6 1.0E-6   77  dlB_model_9  0.5790165019503987
# 18            [0.6, 0.6]                 0.2 1.0E-6 1.0E-6   77  dlB_model_6   0.583816186776641
# 19            [0.2, 0.2]                 0.3 1.0E-6 3.0E-6   77  dlB_model_3  0.5880054548526372
# 20            [0.4, 0.4]                 0.3    0.0 3.0E-6   77 dlB_model_11  0.5923819685378078

best_model <- h2o.getModel((g@model_ids[[1]]))
h2o.saveModel(best_model,'/tmp/')

h2o.performance(best_model, valid = T)
h2o.performance(best_model, newdata = test)
