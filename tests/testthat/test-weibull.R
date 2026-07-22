test_that("a weibull is specified via its natural shape and scale", {
  shape <- 2
  scale <- 5
  result <- Weibull(shape = shape, scale = scale)
  expect_equal(get_distribution(result), "weibull")
  expect_equal(get_parameters(result), list(shape = shape, scale = scale))
})

test_that("a weibull can be specified via mean and sd", {
  shape <- 2
  scale <- 5
  weibull_mean <- scale * gamma(1 + 1 / shape)
  weibull_sd <- sqrt(scale^2 * (gamma(1 + 2 / shape) - gamma(1 + 1 / shape)^2))
  result <- Weibull(mean = weibull_mean, sd = weibull_sd)
  expect_equal(get_distribution(result), "weibull")
  expect_equal(get_parameters(result)$shape, shape, tolerance = 1e-6)
  expect_equal(get_parameters(result)$scale, scale, tolerance = 1e-6)
})
