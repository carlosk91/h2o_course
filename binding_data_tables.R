library(h2o)
h2o.init()

data <- h2o.importFile("http://h2o-public-test-data.s3.amazonaws.com/smalldata/airlines/allyears2k_headers.zip")

parts <- h2o.splitFrame(data, c(0.8, 0.1), seed = 69)
train <- parts[[1]]
valid <- parts[[2]]
test <- parts[[3]]

# Different wat yo extract some rows.
# I.e. Just like you do in normal R

train2 <- data[1:35255,] # First rows, not random

h2o.ls()

train2 <- h2o.assign(train2, "first35255")

# Same for columns

ncol(data)

dates <- data[,1:4]  # First 4 of 31 columns
airports <- data[,c('Origin', 'Dest')]

dim(airports)
dim(dates)

# Use cbind to bind columns
a_and_b <- h2o.cbind(airports, dates)

dim(a_and_b)

# Use rbind to bind rows

restored_data <- h2o.rbind(train, valid, test)
dim(restored_data)
dim(data)

dim(restored_data) == dim(data)

head(restored_data[, 1:4])
head(data[, 1:4])
head(train[, 1:4])
