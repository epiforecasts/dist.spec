test_that("beta distribution is specified via natural shape parameters", {
  result <- Beta(shape1 = 2, shape2 = 5)
  expect_equal(get_distribution(result), "beta")
  expect_equal(get_parameters(result), list(shape1 = 2, shape2 = 5))
})

test_that("beta distribution can be specified via mean and sd", {
  result <- Beta(mean = 0.3, sd = 0.15)
  expect_equal(get_distribution(result), "beta")
  expect_equal(mean(result), 0.3)
  expect_equal(sd(result), 0.15)
})

test_that("beta rejects an infeasible mean/sd and out-of-range shapes", {
  expect_error(Beta(mean = 0.5, sd = 0.6), "variance of a beta")
  expect_error(Beta(mean = 1.2, sd = 0.1), "must be between 0 and 1")
  expect_error(Beta(shape1 = -1, shape2 = 2), "lower bound")
})
