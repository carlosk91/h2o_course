library(h2o)
h2o.init()

url <- "http://h2o-public-test-data.s3.amazonaws.com/smalldata/iris/iris_wheader.csv"
iris <- h2o.importFile(url)

parts <- h2o.splitFrame(iris, 0.8)
train <- parts[[1]]
test <- parts[[2]]

summary(train)

#### Naive Bayes Model ####
nbm <- h2o.naiveBayes(1:4, 5, train)
nbm
pred_test_nbm <- h2o.predict(nbm, test)
h2o.performance(nbm, test)
