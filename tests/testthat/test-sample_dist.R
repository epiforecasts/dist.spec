test_that("sample_dist returns the requested number of samples", {
  expect_length(sample_dist(Gamma(shape = 2, rate = 1), 10), 10)
  expect_length(sample_dist(Fixed(3), 5), 5)
  expect_length(sample_dist(NonParametric(c(0.1, 0.2, 0.3, 0.4)), 7), 7)
})

test_that("sample_dist draws from the correct parametric family", {
  set.seed(1)
  n <- 1e5
  expect_equal(mean(sample_dist(Gamma(shape = 2, rate = 1), n)), 2,
    tolerance = 0.05
  )
  expect_equal(mean(sample_dist(Exp(rate = 0.5), n)), 2, tolerance = 0.05)
  expect_equal(mean(sample_dist(Normal(mean = 5, sd = 2), n)), 5,
    tolerance = 0.05
  )
  expect_equal(sd(sample_dist(Normal(mean = 5, sd = 2), n)), 2,
    tolerance = 0.05
  )
  expect_equal(mean(sample_dist(LogNormal(meanlog = 0, sdlog = 0.5), n)),
    exp(0.5^2 / 2),
    tolerance = 0.05
  )
  expect_equal(mean(sample_dist(Weibull(shape = 2, scale = 3), n)),
    3 * gamma(1 + 1 / 2),
    tolerance = 0.05
  )
  expect_equal(mean(sample_dist(Beta(shape1 = 2, shape2 = 3), n)), 0.4,
    tolerance = 0.05
  )
})

test_that("sample_dist of a fixed distribution repeats its value", {
  expect_equal(sample_dist(Fixed(3), 5), rep(3, 5))
  expect_equal(sample_dist(Fixed(2.5), 4), rep(2.5, 4))
})

test_that("sample_dist of a nonparametric distribution draws on its support", {
  set.seed(1)
  pmf <- c(0.1, 0.2, 0.3, 0.4)
  samples <- sample_dist(NonParametric(pmf), 1e5)
  expect_true(all(samples %in% 0:3))
  expect_true(all(samples == floor(samples)))
  ## empirical PMF should approximate the specified one
  empirical <- as.vector(table(factor(samples, levels = 0:3))) / length(samples)
  expect_equal(empirical, pmf, tolerance = 0.05)
})

test_that("sample_dist works on a discretised distribution", {
  set.seed(1)
  dist <- discretise(Gamma(shape = 2, rate = 1, max = 20))
  samples <- sample_dist(dist, 1000)
  expect_true(all(samples %in% 0:(length(get_pmf(dist)) - 1)))
  expect_true(all(samples == floor(samples)))
})

test_that("sample_dist errors on distributions with uncertain parameters", {
  uncertain <- LogNormal(meanlog = Normal(3, 0.5), sdlog = 1)
  expect_error(sample_dist(uncertain, 10), "fixed parameters")
})

test_that("sample_dist errors on an estimated nonparametric distribution", {
  estimated <- NonParametric(pmf = Dirichlet(c(1, 1, 1)))
  expect_error(sample_dist(estimated, 10), "fixed parameters")
})

test_that("sample_dist errors on distributions with no sampler", {
  expect_error(sample_dist(Dirichlet(c(1, 2, 3)), 10), "sample from")
})

test_that("sample_dist of a composite sums independent draws from components", {
  set.seed(1)
  n <- 1e5
  composite <- Gamma(shape = 2, rate = 1) + Gamma(shape = 3, rate = 1)
  samples <- sample_dist(composite, n)
  expect_length(samples, n)
  ## convolution mean = sum of component means (2 + 3)
  expect_equal(mean(samples), 5, tolerance = 0.05)
})

test_that("sample_dist of a composite errors if a component is uncertain", {
  composite <- Gamma(shape = 2, rate = 1) +
    LogNormal(meanlog = Normal(3, 0.5), sdlog = 1)
  expect_error(sample_dist(composite, 10), "fixed parameters")
})

test_that("sample_dist validates n", {
  expect_error(sample_dist(Fixed(3), -1), "non-negative")
  expect_error(sample_dist(Fixed(3), c(1, 2)), "single")
  expect_error(sample_dist(Fixed(3), Inf), "integer")
  expect_error(sample_dist(Fixed(3), 2.5), "integer")
  expect_error(sample_dist(Fixed(3), NA), "integer")
})
