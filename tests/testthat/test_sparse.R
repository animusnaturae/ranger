library(ranger)
library(survival)
library(Matrix)
context("ranger_sparse")

## Iris sparse data
iris_sparse <- Matrix(data.matrix(iris), sparse = TRUE)

## 0/1 sparse data
n <- 100
p <- 5
x <- replicate(p, rbinom(n, 1, .1))
y <- rbinom(n, 1, .5)
dat <- data.frame(y = y, x)
dat_matrix <- data.matrix(dat)
dat_sparse <- Matrix(dat_matrix, sparse = TRUE)

test_that("Same result with sparse data for iris classification", {
  set.seed(56)
  rf1 <- ranger(data = iris_sparse, dependent.variable.name = "Species", classification = TRUE, num.trees = 5)
  
  set.seed(56)
  rf2 <- ranger(data = iris, dependent.variable.name = "Species", num.trees = 5)
  
  expect_equal(rf1$prediction.error, rf2$prediction.error)
  
  pred1 <- levels(iris$Species)[rf1$predictions[!is.na(rf1$predictions)]]
  pred2 <- as.character(rf2$predictions[!is.na(rf2$predictions)])
  expect_equal(pred1, pred2)
})

test_that("Same result with sparse data for iris regression", {
  set.seed(56)
  rf1 <- ranger(data = iris_sparse, dependent.variable.name = "Sepal.Length", classification = FALSE, num.trees = 5)
  
  set.seed(56)
  rf2 <- ranger(data = iris, dependent.variable.name = "Sepal.Length", num.trees = 5)
  
  expect_equal(rf1$prediction.error, rf2$prediction.error)
  
  pred1 <- rf1$predictions[!is.na(rf1$predictions)]
  pred2 <- rf2$predictions[!is.na(rf2$predictions)]
  expect_equal(pred1, pred2)
})

test_that("Same result with sparse data for 0/1 classification", {
  set.seed(56)
  rf1 <- ranger(data = dat_sparse, dependent.variable.name = "y", classification = TRUE, num.trees = 5)
  
  set.seed(56)
  rf2 <- ranger(data = dat, dependent.variable.name = "y", classification = TRUE, num.trees = 5)
  
  expect_equal(rf1$prediction.error, rf2$prediction.error)
  
  pred1 <- as.character(rf1$predictions[!is.na(rf1$predictions)])
  pred2 <- as.character(rf2$predictions[!is.na(rf2$predictions)])
  expect_equal(pred1, pred2)
})

test_that("Same result with sparse data for 0/1 regression", {
  set.seed(56)
  rf1 <- ranger(data = dat_sparse, dependent.variable.name = "y", classification = FALSE, num.trees = 5)
  
  set.seed(56)
  rf2 <- ranger(data = dat, dependent.variable.name = "y", num.trees = 5)
  
  expect_equal(rf1$prediction.error, rf2$prediction.error)
  
  pred1 <- rf1$predictions[!is.na(rf1$predictions)]
  pred2 <- rf2$predictions[!is.na(rf2$predictions)]
  expect_equal(pred1, pred2)
})

test_that("Prediction is the same if training or testing data is sparse", {
  idx <- sample(nrow(iris), 2/3*nrow(iris))
  train <- iris[idx, ]
  test <- iris[-idx, ]
  train_sparse <- Matrix(data.matrix(train), sparse = TRUE)
  test_sparse <- Matrix(data.matrix(test), sparse = TRUE)
  
  set.seed(42)
  rf1 <- ranger(data = train, dependent.variable.name = "Species", classification = TRUE, num.trees = 5)
  pred1 <- predict(rf1, test)
  pred1_sparse <- predict(rf1, test_sparse)
  
  set.seed(42)
  rf2 <- ranger(data = train_sparse, dependent.variable.name = "Species", classification = TRUE, num.trees = 5)
  pred2 <- predict(rf2, test)
  pred2_sparse <- predict(rf2, test_sparse)
  
  expect_equal(pred1$predictions, pred1_sparse$predictions)
  expect_equal(as.character(pred1$predictions), levels(iris$Species)[pred2$predictions])
  expect_equal(pred2$predictions, pred2_sparse$predictions)
})


