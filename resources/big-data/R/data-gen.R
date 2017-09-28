# utils
#-------------------------------------------------------------------------------
source("big-data/R/utils.R")

# packages loading
#-------------------------------------------------------------------------------
MyRequire(data.table)

# (big) data simulating
#-------------------------------------------------------------------------------
set.seed(12345)

n_rows <- 6e6
n_cols <- 4
dt <- data.table(matrix(rnorm(n_rows * n_cols), nrow = n_rows))
setnames(dt, names(dt), paste0("X", 1:n_cols))
dt[, Y_c := 5 * X3 - 3 * X4 + 2 * X1 - 2 + rnorm(n_rows)]
dt[, Y_d := ifelse(Y_c >= mean(Y_c), "1", "-1")]

test_ind <- sample(1:n_rows, 0.01 * n_rows)
test <- dt[test_ind, ]
train <- dt[!test_ind, ]

# data outputing
#-------------------------------------------------------------------------------
write.csv(train, file = "big-data/data/train.csv",
          quote = FALSE, row.names = FALSE, fileEncoding = "UTF-8")
write.csv(test, file = "big-data/data/test.csv",
          quote = FALSE, row.names = FALSE, fileEncoding = "UTF-8")

# global environment cleaning
#-------------------------------------------------------------------------------
rm(list = c("n_rows", "n_cols", "dt", "train", "test", "test_ind"))
gc()
