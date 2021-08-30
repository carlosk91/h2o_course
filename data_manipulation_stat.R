library(h2o)
h2o.init()

url <- "http://h2o-public-test-data.s3.amazonaws.com/smalldata/airlines/allyears2k_headers.zip"
data <- h2o.importFile(url)


summary(data)
mean(data[,'AirTime'], na.rm = T)
h2o.mean(data[,'AirTime'], na.rm = T)

range(data[,'AirTime'], na.rm = T)
h2o.hist(data[,'AirTime'])

mean(data[,c('ArrDelay', 'DepDelay')], na.rm = T)

h2o.any(data[,'ArrDelay'] > 360)
h2o.all(data[,'ArrDelay'] < 480)

h2o.all(h2o.na_omit(data[,'ArrDelay']) < 480)

h2o.cumsum(data[,'ArrDelay'], axis = 0)

h2o.cor(data[,'ArrDelay'], data[,'DepDelay'], na.rm = T)
