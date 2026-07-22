# Systematic checks applied uniformly to every parametric distribution, against
# independent references rather than hard-coded values: the base-R generators
# for sampling, the analytic moments, and a direct
# `primarycensored::dprimarycensored()` call for discretised PMFs. Behaviour
# that does not generalise (alternative parameterisations, bounds, error cases,
# the fixed/nonparametric/dirichlet families) lives in the per-distribution
# files.

# One row per distribution. `constructor`/`args` build it from its natural
# parameters; `sampler`/`pdist` are the matching base-R generator and CDF (their
# argument names match `args`); `mean`/`sd` are the analytic moments;
# `discretisable` marks the distributions with a CDF-based discretisation.
reference_distributions <- list(
  gamma = list(
    constructor = Gamma, args = list(shape = 2, rate = 1),
    sampler = rgamma, pdist = pgamma,
    mean = 2, sd = sqrt(2), discretisable = TRUE
  ),
  lognormal = list(
    constructor = LogNormal, args = list(meanlog = 1, sdlog = 0.5),
    sampler = rlnorm, pdist = plnorm,
    mean = exp(1 + 0.5^2 / 2),
    sd = sqrt((exp(0.5^2) - 1) * exp(2 * 1 + 0.5^2)),
    discretisable = TRUE
  ),
  normal = list(
    constructor = Normal, args = list(mean = 5, sd = 2),
    sampler = rnorm, pdist = pnorm,
    mean = 5, sd = 2, discretisable = TRUE
  ),
  exp = list(
    constructor = Exponential, args = list(rate = 0.5),
    sampler = rexp, pdist = pexp,
    mean = 2, sd = 2, discretisable = TRUE
  ),
  weibull = list(
    constructor = Weibull, args = list(shape = 2, scale = 3),
    sampler = rweibull, pdist = pweibull,
    mean = 3 * gamma(1 + 1 / 2),
    sd = sqrt(3^2 * (gamma(1 + 2 / 2) - gamma(1 + 1 / 2)^2)),
    discretisable = TRUE
  ),
  beta = list(
    constructor = Beta, args = list(shape1 = 2, shape2 = 3),
    sampler = rbeta, pdist = pbeta,
    mean = 2 / (2 + 3),
    sd = sqrt(2 * 3 / ((2 + 3)^2 * (2 + 3 + 1))),
    discretisable = FALSE
  )
)

test_that("sample_dist matches the base-R generator for every distribution", {
  ## distspec's samplers call the base RNG directly with the same parameters,
  ## so under the same seed the draws are identical.
  n <- 1000
  for (name in names(reference_distributions)) {
    d <- reference_distributions[[name]]
    set.seed(1)
    got <- sample_dist(do.call(d$constructor, d$args), n)
    set.seed(1)
    ref <- do.call(d$sampler, c(list(n), d$args))
    expect_identical(got, ref, info = name)
  }
})

test_that("mean and sd match the analytic values for every distribution", {
  for (name in names(reference_distributions)) {
    d <- reference_distributions[[name]]
    dist <- do.call(d$constructor, d$args)
    expect_equal(mean(dist), d$mean, info = name)
    expect_equal(sd(dist), d$sd, info = name)
  }
})

test_that("discretised PMF matches a direct primarycensored call", {
  ## `discrete_pmf.dist_spec()` calls `dprimarycensored()` with `pwindow` and
  ## `swindow` both equal to the bin width (1) and `D` the maximum, evaluating
  ## at `x = seq(0, max - 1)`. Replicate that call directly.
  max_value <- 20
  for (name in names(reference_distributions)) {
    d <- reference_distributions[[name]]
    if (!d$discretisable) next
    dist <- do.call(d$constructor, c(d$args, list(max = max_value)))
    pmf <- get_pmf(discretise(dist))
    reference <- do.call(
      primarycensored::dprimarycensored,
      c(
        list(
          x = seq(0, max_value - 1), pdist = d$pdist,
          pwindow = 1, swindow = 1, D = max_value
        ),
        d$args
      )
    )
    expect_equal(pmf, reference[seq_along(pmf)], tolerance = 1e-8, info = name)
  }
})
