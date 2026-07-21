# Tests that check distspec's output against independent references rather than
# hard-coded fixed values: the base-R random generators for sampling, and a
# direct `primarycensored::dprimarycensored()` call for discretised PMFs.

test_that("sample_dist matches the base-R generators under a fixed seed", {
  ## distspec's samplers call the base RNG directly with the same parameters,
  ## so with the same seed the draws are identical.
  n <- 1000

  set.seed(1)
  ds_gamma <- sample_dist(Gamma(shape = 2, rate = 1), n)
  set.seed(1)
  base_gamma <- rgamma(n, shape = 2, rate = 1)
  expect_identical(ds_gamma, base_gamma)

  set.seed(1)
  ds_exp <- sample_dist(Exponential(rate = 0.5), n)
  set.seed(1)
  base_exp <- rexp(n, rate = 0.5)
  expect_identical(ds_exp, base_exp)

  set.seed(1)
  ds_norm <- sample_dist(Normal(mean = 5, sd = 2), n)
  set.seed(1)
  base_norm <- rnorm(n, mean = 5, sd = 2)
  expect_identical(ds_norm, base_norm)

  set.seed(1)
  ds_lnorm <- sample_dist(LogNormal(meanlog = 0, sdlog = 0.5), n)
  set.seed(1)
  base_lnorm <- rlnorm(n, meanlog = 0, sdlog = 0.5)
  expect_identical(ds_lnorm, base_lnorm)

  set.seed(1)
  ds_weibull <- sample_dist(Weibull(shape = 2, scale = 3), n)
  set.seed(1)
  base_weibull <- rweibull(n, shape = 2, scale = 3)
  expect_identical(ds_weibull, base_weibull)

  set.seed(1)
  ds_beta <- sample_dist(Beta(shape1 = 2, shape2 = 3), n)
  set.seed(1)
  base_beta <- rbeta(n, shape1 = 2, shape2 = 3)
  expect_identical(ds_beta, base_beta)
})

test_that("discretised gamma PMF matches a direct primarycensored call", {
  ## `discrete_pmf.dist_spec()` calls `dprimarycensored()` with `pwindow` and
  ## `swindow` both equal to the bin width (1) and `D` the (ceiling of the)
  ## maximum, evaluating at `x = seq(0, max - 1)`. Replicate that call directly.
  pmf <- get_pmf(discretise(Gamma(shape = 2, rate = 1, max = 20)))
  reference <- primarycensored::dprimarycensored(
    x = 0:19, pdist = pgamma, pwindow = 1, swindow = 1, D = 20,
    shape = 2, rate = 1
  )
  expect_equal(pmf, reference[seq_along(pmf)], tolerance = 1e-8)
})

test_that("discretised lognormal PMF matches a direct primarycensored call", {
  pmf <- get_pmf(discretise(LogNormal(meanlog = 1, sdlog = 0.5, max = 20)))
  reference <- primarycensored::dprimarycensored(
    x = 0:19, pdist = plnorm, pwindow = 1, swindow = 1, D = 20,
    meanlog = 1, sdlog = 0.5
  )
  expect_equal(pmf, reference[seq_along(pmf)], tolerance = 1e-8)
})

test_that("moments of a discretised distribution match the analytic values", {
  ## Discretisation adds a little variance (each integer bin collects mass from
  ## a unit interval), so the sd is allowed a generous tolerance while the mean
  ## should track the analytic value closely.
  gamma_dist <- discretise(Gamma(shape = 2, rate = 1, max = 40))
  expect_equal(mean(gamma_dist), 2, tolerance = 1e-3)
  expect_equal(sd(gamma_dist), sqrt(2), tolerance = 0.1)

  meanlog <- 1
  sdlog <- 0.5
  lnorm_dist <- discretise(LogNormal(meanlog = meanlog, sdlog = sdlog, max = 60))
  analytic_mean <- exp(meanlog + sdlog^2 / 2)
  analytic_sd <- sqrt((exp(sdlog^2) - 1) * exp(2 * meanlog + sdlog^2))
  expect_equal(mean(lnorm_dist), analytic_mean, tolerance = 1e-3)
  expect_equal(sd(lnorm_dist), analytic_sd, tolerance = 0.1)
})
