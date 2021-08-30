library(h2o)

h2o.init()

url <- "http://h2o-public-test-data.s3.amazonaws.com/smalldata/iris/iris_wheader.csv"
iris <- h2o.importFile(url)

parts <- h2o.splitFrame(iris, 0.8)
train <- parts[[1]]
test <- parts[[2]]

summary(train)

#### Deep Learning Model ####
dlm <- h2o.deeplearning(1:4, 5, train)
pred_test_dlm <- h2o.predict(dlm, test)
h2o.performance(dlm, test)
h2o.varimp(dlm)

#### Random Forest Model ####
rfm <- h2o.randomForest(1:4, 5, train)
pred_test_rfm <- h2o.predict(rfm, test)
h2o.performance(rfm, test)
h2o.varimp(rfm)

#### Random Forest Model ####
gbm <- h2o.randomForest(1:4, 5, train)
pred_test_gbm <- h2o.predict(gbm, test)
h2o.performance(gbm, test)
h2o.varimp(gbm)
