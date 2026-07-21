test_that("dist_spec returns correct output for uncertain gamma distribution", {
  result <- discretise(
    Gamma(shape = Normal(3, 0.5), rate = Normal(2, 0.5), max = 19),
    strict = FALSE
  )
  expect_equal(get_parameters(result)$shape$parameters$mean, 3)
  expect_equal(get_parameters(result)$shape$parameters$sd, 0.5)
  expect_equal(get_parameters(result)$rate$parameters$mean, 2)
  expect_equal(get_parameters(result)$rate$parameters$sd, 0.5)
  expect_equal(get_distribution(result), "gamma")
  expect_equal(max(result), 19)
})

test_that("dist_spec returns correct output for gamma distribution parameterised with scale", {
  result <- Gamma(shape = 3, scale = 2)
  expect_equal(get_parameters(result)$shape, 3)
  expect_equal(get_parameters(result)$rate, 0.5)
  expect_equal(get_distribution(result), "gamma")
  expect_true(is.infinite(max(result)))
})

test_that("a gamma can be specified via mean and sd", {
  shape <- 3
  rate <- 2
  result <- Gamma(shape = shape, rate = rate)
  expect_equal(get_distribution(result), "gamma")
  expect_equal(mean(result), shape / rate)
  expect_equal(sd(result), sqrt(shape) / rate)
})

test_that("summary functions return correct output for uncertain gamma distribution", {
  dist <- Gamma(shape = Normal(3, 0.5), rate = Normal(2, 0.5), max = 19)
  expect_equal(mean(dist, ignore_uncertainty = TRUE), 1.5)
  expect_equal(max(dist), 19L)
})
