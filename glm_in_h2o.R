library(h2o)
h2o.init()

url <- 'https://data.princeton.edu/wws509/datasets/smoking.dat'
data <- h2o.importFile(url, skipped_columns = 1)

data
summary(data)
h2o.sum(data[,3])

x <- 1:2
y <- 4

m <- h2o.glm(x, y, data, family = 'poisson', model_id = 'smoking_p'
             # nfolds = 12,
             # fold_assignment = 'Modulo'
             )

m

m2 <- h2o.glm(2, y, data, family = 'poisson', model_id = 'smoking_2'
             # nfolds = 12,
             # fold_assignment = 'Modulo'
)

m2
