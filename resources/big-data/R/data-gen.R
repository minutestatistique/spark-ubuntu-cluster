#!/usr/bin/Rscript

# (big) data simulating
#-------------------------------------------------------------------------------
set.seed(12345)

n_rows <- 6e6
n_cols <- 4
dt <- data.frame(matrix(rnorm(n_rows * n_cols), nrow = n_rows))
names(dt) <- paste("X", 1:n_cols, sep = "")
dt$Y_c <- 5 * dt$X3 - 3 * dt$X4 + 2 * dt$X1 - 2 + rnorm(n_rows)
dt$Y_d <- ifelse(dt$Y_c >= mean(dt$Y_c), "1", "-1")

test_ind <- sample(1:n_rows, 0.01 * n_rows)
test <- dt[test_ind, ]
train <- dt[setdiff(1:n_rows, test_ind), ]

# data outputing
#-------------------------------------------------------------------------------
write.csv(train, file = "../data/train.csv",
          quote = FALSE, row.names = FALSE, fileEncoding = "UTF-8")
write.csv(test, file = "../data/test.csv",
          quote = FALSE, row.names = FALSE, fileEncoding = "UTF-8")
