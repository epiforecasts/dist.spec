test_that("dist_spec returns correct output for fixed lognormal distribution", {
  result <- discretise(LogNormal(meanlog = 5, sdlog = 1, max = 19))
  expect_equal(get_distribution(result), "nonparametric")
  expect_equal(max(result), 19)
  expect_equal(
    as.vector(round(get_pmf(result), 2)),
    c(
      0.00, 0.00, 0.00, 0.00, 0.01, 0.01, 0.02, 0.03,
      0.04, 0.05, 0.06, 0.07, 0.08, 0.08, 0.09, 0.10,
      0.11, 0.12, 0.13
    )
  )
})

test_that("dist_spec returns error when mixed natural and unnatural parameters are specified", {
  expect_error(
    LogNormal(meanlog = 5, sd = 1, max = 20),
    "Incompatible combination."
  )
})

test_that("a lognormal can be specified via mean and sd", {
  meanlog <- 1.4
  sdlog <- 0.5
  result <- LogNormal(meanlog = meanlog, sdlog = sdlog)
  expect_equal(get_distribution(result), "lognormal")
  expect_equal(mean(result), exp(meanlog + sdlog^2 / 2))
  expect_equal(
    sd(result),
    sqrt((exp(sdlog^2) - 1) * exp(2 * meanlog + sdlog^2))
  )
})

test_that("summary functions return correct output for fixed lognormal distribution", {
  dist <- discretise(LogNormal(mean = 3, sd = 1, max = 19))
  expect_equal(mean(dist), 3.0, tolerance = 0.01)
  expect_equal(sd(dist), 1.08, tolerance = 0.01)
  expect_equal(max(dist), 19L)
})
