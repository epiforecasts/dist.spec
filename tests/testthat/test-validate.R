test_that("every constructor produces a valid dist_spec", {
  dists <- list(
    LogNormal(meanlog = 1, sdlog = 0.5),
    Gamma(shape = 2, rate = 1),
    Normal(mean = 4, sd = 1),
    Beta(shape1 = 2, shape2 = 5),
    Exponential(rate = 1),
    Weibull(shape = 1, scale = 1),
    Fixed(value = 3),
    NonParametric(c(0.1, 0.3, 0.2, 0.4)),
    NonParametric(pmf = Dirichlet(c(1, 1, 1, 1))),
    Dirichlet(c(1, 1, 1, 1)),
    suppressWarnings(Gamma(shape = Normal(2, 0.5), rate = 1)),
    Gamma(shape = 2, rate = 1, max = 10),
    Gamma(shape = 2, rate = 1, cdf_cutoff = 0.99)
  )
  for (dist in dists) {
    expect_identical(validate_dist_spec(dist), dist)
  }
})

test_that("validate_dist_spec is invisible on success", {
  dist <- Gamma(shape = 2, rate = 1)
  expect_invisible(validate_dist_spec(dist))
})

test_that("composite distributions are valid", {
  dist <- Gamma(shape = 2, rate = 1, max = 10) + Fixed(3)
  expect_identical(validate_dist_spec(dist), dist)

  combined <- c(
    LogNormal(meanlog = 1, sdlog = 0.5),
    NonParametric(c(0.1, 0.3, 0.6))
  )
  expect_identical(validate_dist_spec(combined), combined)
})

test_that("a non-dist_spec object fails validation", {
  expect_error(
    validate_dist_spec(list(distribution = "gamma")),
    "must be a"
  )
})

test_that("a bad cdf_cutoff fails validation", {
  dist <- Gamma(shape = 2, rate = 1)
  attr(dist, "cdf_cutoff") <- 1.5
  expect_error(validate_dist_spec(dist), "cdf_cutoff")
})

test_that("a bad max fails validation", {
  dist <- Gamma(shape = 2, rate = 1)
  attr(dist, "max") <- -1
  expect_error(validate_dist_spec(dist), "max")
})

test_that("parameters that are not a named list fail validation", {
  dist <- Gamma(shape = 2, rate = 1)
  dist$parameters <- list(2, 1)
  expect_error(validate_dist_spec(dist), "named list")
})

test_that("a distribution not matching its type class fails validation", {
  dist <- Gamma(shape = 2, rate = 1)
  dist$distribution <- "lognormal"
  expect_error(validate_dist_spec(dist), "match its\\s+type class")
})

test_that("a corrupted component fails composite validation", {
  dist <- Gamma(shape = 2, rate = 1) + Fixed(3)
  attr(dist[[1]], "max") <- -1
  expect_error(validate_dist_spec(dist), "max")
})
