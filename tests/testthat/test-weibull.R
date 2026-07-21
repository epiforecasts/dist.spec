test_that("a weibull is specified via its natural shape and scale", {
  shape <- 2
  scale <- 5
  result <- Weibull(shape = shape, scale = scale)
  expect_equal(get_distribution(result), "weibull")
  expect_equal(get_parameters(result), list(shape = shape, scale = scale))
  expect_equal(mean(result), scale * gamma(1 + 1 / shape))
  expect_equal(
    sd(result),
    sqrt(scale^2 * (gamma(1 + 2 / shape) - gamma(1 + 1 / shape)^2))
  )
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

test_that("dist_spec discretises a weibull distribution", {
  expect_equal(
    round(get_pmf(discretise(Weibull(shape = 2, scale = 5, max = 5))), 2),
    c(0.02, 0.14, 0.24, 0.30, 0.30)
  )
})
