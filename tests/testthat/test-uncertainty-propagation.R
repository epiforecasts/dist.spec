# Tests for delta-method propagation of parameter uncertainty from unnatural to
# natural parameters (see convert_to_natural()). Each test draws a large
# Monte-Carlo sample of the unnatural parameters from their priors (truncated at
# the lower bounds), maps every draw to the natural parameters with the same
# closed-form maths used by the constructors, and checks that the delta-method
# standard deviation stored in the constructed dist_spec is close to the
# Monte-Carlo standard deviation. The delta method is first-order, so a generous
# relative tolerance is used.

n_mc <- 2e5
rel_tol <- 0.3

# Draw n truncated-normal samples with the given mean and sd, discarding draws
# at or below the lower bound.
draw_truncnorm <- function(n, mean, sd, lower = 0) {
  x <- rnorm(n, mean, sd)
  x[x > lower]
}

# Compare the delta-method sd stored on a natural parameter with a Monte-Carlo
# reference sd.
expect_close <- function(delta_sd, mc_sd, tol = rel_tol) {
  expect_equal(delta_sd, mc_sd, tolerance = tol)
}

test_that("gamma (mean and sd uncertain) matches Monte Carlo", {
  set.seed(20260720)
  mean_mu <- 4; mean_sd <- 0.5
  sd_mu <- 1; sd_sd <- 0.15
  g <- suppressWarnings(
    Gamma(mean = Normal(mean_mu, mean_sd), sd = Normal(sd_mu, sd_sd))
  )
  m <- draw_truncnorm(n_mc, mean_mu, mean_sd)
  s <- draw_truncnorm(n_mc, sd_mu, sd_sd)
  n <- min(length(m), length(s))
  m <- m[seq_len(n)]; s <- s[seq_len(n)]
  shape <- m^2 / s^2
  rate <- shape / m
  expect_close(sd(get_parameters(g)$shape), sd(shape))
  expect_close(sd(get_parameters(g)$rate), sd(rate))
})

test_that("gamma (mean uncertain, sd fixed) matches Monte Carlo", {
  set.seed(11)
  mean_mu <- 4; mean_sd <- 0.5
  sd_fixed <- 1
  g <- suppressWarnings(Gamma(mean = Normal(mean_mu, mean_sd), sd = sd_fixed))
  m <- draw_truncnorm(n_mc, mean_mu, mean_sd)
  shape <- m^2 / sd_fixed^2
  rate <- shape / m
  expect_close(sd(get_parameters(g)$shape), sd(shape))
  expect_close(sd(get_parameters(g)$rate), sd(rate))
})

test_that("gamma (mean fixed, sd uncertain) matches Monte Carlo", {
  set.seed(12)
  mean_fixed <- 4
  sd_mu <- 1; sd_sd <- 0.15
  g <- suppressWarnings(Gamma(mean = mean_fixed, sd = Normal(sd_mu, sd_sd)))
  s <- draw_truncnorm(n_mc, sd_mu, sd_sd)
  shape <- mean_fixed^2 / s^2
  rate <- shape / mean_fixed
  expect_close(sd(get_parameters(g)$shape), sd(shape))
  ## rate depends only on the fixed mean and the (uncertain) shape via
  ## mean^2/sd^2 / mean = mean/sd^2, so it is uncertain too
  expect_close(sd(get_parameters(g)$rate), sd(rate))
})

test_that("lognormal (mean and sd uncertain) matches Monte Carlo", {
  set.seed(13)
  mean_mu <- 4; mean_sd <- 0.4
  sd_mu <- 1; sd_sd <- 0.15
  d <- suppressWarnings(
    LogNormal(mean = Normal(mean_mu, mean_sd), sd = Normal(sd_mu, sd_sd))
  )
  m <- draw_truncnorm(n_mc, mean_mu, mean_sd)
  s <- draw_truncnorm(n_mc, sd_mu, sd_sd)
  n <- min(length(m), length(s))
  m <- m[seq_len(n)]; s <- s[seq_len(n)]
  meanlog <- log(m^2 / sqrt(s^2 + m^2))
  sdlog <- sqrt(log1p((s / m)^2))
  expect_close(sd(get_parameters(d)$meanlog), sd(meanlog))
  expect_close(sd(get_parameters(d)$sdlog), sd(sdlog))
})

test_that("exp (mean uncertain) matches Monte Carlo", {
  set.seed(14)
  mean_mu <- 4; mean_sd <- 0.5
  d <- suppressWarnings(Exponential(mean = Normal(mean_mu, mean_sd)))
  m <- draw_truncnorm(n_mc, mean_mu, mean_sd)
  rate <- 1 / m
  expect_close(sd(get_parameters(d)$rate), sd(rate))
})

test_that("beta (mean and sd uncertain) matches Monte Carlo", {
  set.seed(15)
  mean_mu <- 0.3; mean_sd <- 0.02
  sd_mu <- 0.1; sd_sd <- 0.01
  d <- suppressWarnings(
    Beta(mean = Normal(mean_mu, mean_sd), sd = Normal(sd_mu, sd_sd))
  )
  m <- draw_truncnorm(n_mc, mean_mu, mean_sd)
  s <- draw_truncnorm(n_mc, sd_mu, sd_sd)
  n <- min(length(m), length(s))
  m <- m[seq_len(n)]; s <- s[seq_len(n)]
  ## keep only valid beta specifications
  ok <- m > 0 & m < 1 & s^2 < m * (1 - m)
  m <- m[ok]; s <- s[ok]
  common <- m * (1 - m) / s^2 - 1
  shape1 <- m * common
  shape2 <- (1 - m) * common
  expect_close(sd(get_parameters(d)$shape1), sd(shape1))
  expect_close(sd(get_parameters(d)$shape2), sd(shape2))
})

test_that("weibull (mean and sd uncertain) matches Monte Carlo", {
  set.seed(16)
  mean_mu <- 4; mean_sd <- 0.3
  sd_mu <- 1; sd_sd <- 0.1
  d <- suppressWarnings(
    Weibull(mean = Normal(mean_mu, mean_sd), sd = Normal(sd_mu, sd_sd))
  )
  m <- draw_truncnorm(5e4, mean_mu, mean_sd)
  s <- draw_truncnorm(5e4, sd_mu, sd_sd)
  n <- min(length(m), length(s))
  m <- m[seq_len(n)]; s <- s[seq_len(n)]
  weibull_shape <- function(mean, sd) {
    log_cv2_p1 <- log1p((sd / mean)^2)
    uniroot(
      function(k) lgamma(1 + 2 / k) - 2 * lgamma(1 + 1 / k) - log_cv2_p1,
      interval = c(0.01, 200)
    )$root
  }
  shape <- mapply(weibull_shape, m, s)
  scale <- m / gamma(1 + 1 / shape)
  expect_close(sd(get_parameters(d)$shape), sd(shape))
  expect_close(sd(get_parameters(d)$scale), sd(scale))
})

test_that("regression: gamma sd(shape) is in the ballpark of the delta value", {
  ## Previously this ad-hoc conversion returned ~0.71; the delta method gives
  ## d(shape)/d(mean) = 2 * mean / sd^2 = 8, times a mean sd of 0.5, i.e. 4.
  shape_sd <- sd(
    get_parameters(suppressWarnings(Gamma(mean = Normal(4, 0.5), sd = 1)))$shape
  )
  expect_gt(shape_sd, 3)
  expect_lt(shape_sd, 5)
  expect_false(isTRUE(all.equal(shape_sd, 0.71, tolerance = 0.05)))
})

test_that("no-uncertainty path keeps natural parameters numeric", {
  g <- Gamma(mean = 4, sd = 1)
  params <- get_parameters(g)
  expect_type(params$shape, "double")
  expect_type(params$rate, "double")
  expect_equal(params$shape, 16)
  expect_equal(params$rate, 4)
  expect_false(has_uncertainty(g))

  ## identical to specifying the natural parameters directly
  direct <- Gamma(shape = 16, rate = 4)
  expect_equal(get_parameters(g), get_parameters(direct))
})

test_that("reworded delta-method warning fires", {
  expect_warning(
    Gamma(mean = Normal(4, 0.5), sd = 1),
    "delta-method"
  )
  expect_warning(
    Gamma(mean = Normal(4, 0.5), sd = 1),
    "shape"
  )
})
