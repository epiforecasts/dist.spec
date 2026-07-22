test_that("an exponential is specified via its natural rate", {
  rate <- 0.5
  result <- Exponential(rate = rate)
  expect_equal(get_distribution(result), "exp")
  expect_equal(get_parameters(result), list(rate = rate))
  expect_equal(mean(result), 1 / rate)
  expect_equal(sd(result), 1 / rate)
})

test_that("dist_spec discretises an exponential distribution", {
  expect_equal(
    round(get_pmf(discretise(Exponential(rate = 0.5, max = 5))), 2),
    c(0.24, 0.35, 0.21, 0.13, 0.08)
  )
})
