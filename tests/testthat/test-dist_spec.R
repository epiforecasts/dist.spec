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

test_that("discretise and collapse work with LogNormal distributions with trailing zeroes", {
  dist1 <- LogNormal(mean = 1.77, sd = 1.08, max = 30)
  dist2 <- LogNormal(mean = 4.4, sd = 0.67, max = 30)
  result <- collapse(discretise(dist1 + dist2))
  expect_true(all(result$pmf >= 0))
})

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

test_that("dist_spec returns correct output for fixed distribution", {
  result <- discretise(
    fix_parameters(LogNormal(meanlog = Normal(5, 3), sdlog = 1, max = 19))
  )
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

test_that("dist_spec returns error when the wrong number of parameters are given", {
  expect_error(LogNormal(sd = 1, max = 20), "must be specified")
  expect_error(Gamma(shape = 1, rate = 2, mean = 3), "must be specified")
})

test_that("each supported distribution is fully wired through dist_spec", {
  supported <- c("lognormal", "gamma", "normal", "exp", "weibull")
  natural_values <- list(
    lognormal = list(meanlog = 1, sdlog = 0.5),
    gamma = list(shape = 2, rate = 1),
    normal = list(mean = 4, sd = 1),
    exp = list(rate = 0.5),
    weibull = list(shape = 2, scale = 5)
  )
  constructors <- list(
    lognormal = LogNormal, gamma = Gamma, normal = Normal,
    exp = Exp, weibull = Weibull
  )
  weibull_m <- 5 * gamma(1 + 1 / 2)
  weibull_s <- sqrt(5^2 * (gamma(1 + 2 / 2) - gamma(1 + 1 / 2)^2))
  nonnatural_cases <- list(
    gamma = list(
      list(input = list(mean = 4, sd = 2),
           expected = list(shape = 4, rate = 1)),
      list(input = list(shape = 2, scale = 4),
           expected = list(rate = 0.25))
    ),
    lognormal = list(
      list(input = list(mean = 4, sd = 1),
           expected = list(meanlog = log(16 / sqrt(17)),
                           sdlog = sqrt(log(1 + 1 / 16))))
    ),
    weibull = list(
      list(input = list(mean = weibull_m, sd = weibull_s),
           expected = list(shape = 2, scale = 5))
    )
  )

  for (d in supported) {
    np <- natural_params(dist_prototype(d))
    expect_type(np, "character")
    expect_gt(length(np), 0)

    lb <- lower_bounds(dist_prototype(d))
    expect_true(
      all(np %in% names(lb)),
      info = paste("lower_bounds missing natural params for", d)
    )

    nat <- natural_values[[d]]
    converted <- convert_to_natural(new_single_dist_spec(list(parameters = nat), d))
    expect_equal(
      converted[np], nat[np],
      info = paste("convert_to_natural does not round-trip for", d)
    )

    for (case in nonnatural_cases[[d]]) {
      converted <- convert_to_natural(
        new_single_dist_spec(list(parameters = case$input), d)
      )
      for (param in names(case$expected)) {
        expect_equal(
          converted[[param]], case$expected[[param]],
          tolerance = 1e-6,
          info = paste(
            "convert_to_natural", d, "non-natural param", param,
            "from", paste(names(case$input), collapse = ",")
          )
        )
      }
    }

    spec <- do.call(constructors[[d]], nat)
    expect_s3_class(spec, "dist_spec")
    expect_equal(get_distribution(spec), d)
    expect_equal(get_parameters(spec)[np], nat[np])
  }
})

test_that("c.dist_spec returns correct output for sum of two distributions", {
  dist1 <- LogNormal(meanlog = 5, sdlog = 1, max = 19)
  dist2 <- Gamma(shape = Normal(3, 0.5), rate = Normal(2, 0.5), max = 20)
  result <- dist1 + dist2
  expect_equal(get_parameters(result, 1)$meanlog, 5)
  expect_equal(get_parameters(result, 1)$sdlog, 1)
  expect_equal(get_parameters(get_parameters(result, 2)$shape)$mean, 3)
  expect_equal(get_parameters(get_parameters(result, 2)$shape)$sd, 0.5)
  expect_equal(get_parameters(get_parameters(result, 2)$rate)$mean, 2)
  expect_equal(get_parameters(get_parameters(result, 2)$rate)$sd, 0.5)
  expect_equal(length(result), 2)
})

test_that("collapse returns correct output for sum of two nonparametric distributions", {
  dist1 <- NonParametric(c(0.1, 0.2, 0.3, 0.4))
  dist2 <- NonParametric(c(0.1, 0.2, 0.3, 0.4))
  result <- collapse(c(dist1, dist2))
  expect_equal(get_distribution(result), "nonparametric")
  expect_equal(max(result), 7)
  expect_equal(ndist(result), 1)
  expect_equal(
    round(get_pmf(result), 2),
    c(0.01, 0.04, 0.10, 0.20, 0.25, 0.24, 0.16)
  )
})

test_that("`bound_dist` function can be applied to a convolution", {
  # Create distributions
  dist1 <- LogNormal(meanlog = 1.6, sdlog = 1, max = 19)
  dist2 <- Gamma(mean = 3, sd = 2, max = 19)

  # Compute combined distribution with default CDF cutoff
  combined <- collapse(discretise(c(dist1, dist2)))

  # Compute combined distribution with larger CDF cutoff
  combined_cdf_cutoff <- bound_dist(combined, cdf_cutoff = 0.001)

  combined_pmf <- get_pmf(combined)
  combined_cdf_cutoff_pmf <- get_pmf(combined_cdf_cutoff)

  # The length of the combined PMF should be greater with default CDF cutoff
  expect_true(length(combined_pmf) > length(combined_cdf_cutoff_pmf))
  # Both should sum to 1
  expect_equal(sum(combined_pmf), 1)
  expect_equal(sum(combined_cdf_cutoff_pmf), 1)
  # The first 5 entries should be within 0.01 of each other
  expect_equal(
    combined_pmf[1:5], combined_cdf_cutoff_pmf[1:5],
    tolerance = 0.01
  )
  expect_equal(mean(combined), mean(combined_cdf_cutoff), tolerance = 0.1)
})

test_that("summary functions return correct output for fixed lognormal distribution", {
  dist <- discretise(LogNormal(mean = 3, sd = 1, max = 19))
  expect_equal(mean(dist), 3.0, tolerance = 0.01)
  expect_equal(sd(dist), 1.08, tolerance = 0.01)
  expect_equal(max(dist), 19L)
})

test_that("summary functions return correct output for uncertain gamma distribution", {
  dist <- Gamma(shape = Normal(3, 0.5), rate = Normal(2, 0.5), max = 19)
  expect_equal(mean(dist, ignore_uncertainty = TRUE), 1.5)
  expect_equal(max(dist), 19L)
})

test_that("mean returns correct output for sum of two distributions", {
  dist1 <- LogNormal(meanlog = 1, sdlog = 1, max = 19)
  dist2 <- Gamma(mean = 3, sd = 2, max = 19)
  dist <- dist1 + dist2
  expect_equal(mean(dist), c(4.48, 3), tolerance = 0.001)
  expect_equal(sd(dist), c(5.87, 2), tolerance = 0.001)
  ## shortened due to tolerance level
  expect_equal(max(dist), c(19L, 19L))
})

test_that("mean returns NA when applied to uncertain distributions", {
  dist <- Gamma(shape = Normal(3, 0.5), rate = Normal(2, 0.5), max = 19)
  expect_true(is.na(mean(dist)))
})

test_that("sd returns NA when applied to uncertain distributions", {
  dist <- Gamma(shape = Normal(3, 0.5), rate = Normal(2, 0.5), max = 19)
  expect_true(is.na(sd(dist)))
})

test_that("print.dist_spec correctly prints the parameters of the fixed lognormal", {
  dist <- discretise(LogNormal(meanlog = 1.5, sdlog = 0.5, max = 19))

  expect_output(print(dist), "- nonparametric distribution\\n  PMF: \\[0\\.00017 0\\.019 0\\.11 0\\.19 0\\.19 0\\.16 0\\.11 0\\.078 0\\.052 0\\.034 0\\.022 0\\.015 0\\.0097 0\\.0065 0\\.0043 0\\.0029 0\\.002 0\\.0014 0\\.00094\\]")
})

test_that("print.dist_spec correctly prints the parameters of the uncertain gamma", {
  gamma <- Gamma(
    shape = Normal(3, 0.5), rate = Normal(2, 0.5), max = 19
  )

  expect_output(print(gamma), "- gamma distribution \\(max: 19\\):\\n  shape:\\n    - normal distribution:\\n      mean:\\n        3\\n      sd:\\n        0\\.5\\n  rate:\\n    - normal distribution:\\n      mean:\\n        2\\n      sd:\\n        0\\.5")
})

test_that("print.dist_spec correctly prints the parameters of the uncertain lognormal", {
  dist <- LogNormal(
    meanlog = Normal(1.5, 0.1), sdlog = Normal(0.5, 0.1), max = 19
  )

  expect_output(print(dist), "- lognormal distribution \\(max: 19\\):\\n  meanlog:\\n    - normal distribution:\\n      mean:\\n        1\\.5\\n      sd:\\n        0\\.1\\n  sdlog:\\n    - normal distribution:\\n      mean:\\n        0\\.5\\n      sd:\\n        0\\.1")
})

test_that("print.dist_spec correctly prints the parameters of a combination of distributions", {
  dist1 <- LogNormal(meanlog = 1.5, sdlog = 0.5, max = 19)
  dist2 <- Gamma(shape = Normal(3, 0.5), rate = Normal(2, 0.5), max = 19)
  combined <- dist1 + dist2
  expect_output(print(combined), "Composite distribution:\\n- lognormal distribution \\(max: 19\\):\\n  meanlog:\\n    1\\.5\\n  sdlog:\\n    0\\.5\\n- gamma distribution \\(max: 19\\):\\n  shape:\\n    - normal distribution:\\n      mean:\\n        3\\n      sd:\\n        0\\.5\\n  rate:\\n    - normal distribution:\\n      mean:\\n        2\\n      sd:\\n        0\\.5")
})

test_that("plot.dist_spec returns a ggplot object", {
  dist <- LogNormal(meanlog = 1.6, sdlog = 0.5, max = 19)
  plot <- plot(dist)
  expect_s3_class(plot, "ggplot")
})

test_that("plot.dist_spec correctly plots a single distribution", {
  dist <- LogNormal(meanlog = 1.6, sdlog = 0.5, max = 19)
  plot <- plot(dist)
  expect_equal(length(plot$layers), 2)
  expect_equal(length(plot$facet$params$facets), 1)
})

test_that("plot.dist_spec correctly plots multiple distributions", {
  dist1 <- LogNormal(meanlog = 1.6, sdlog = 0.5, max = 19)
  dist2 <- Gamma(shape = Normal(3, 5), rate = Normal(1, 2), max = 19)
  combined <- dist1 + dist2
  plot <- plot(combined)
  expect_equal(length(plot$layers), 2)
  expect_equal(length(plot$facet$params$facets), 1)
})

test_that("plot.dist_spec correctly plots a combination of fixed distributions", {
  dist <- LogNormal(meanlog = 1.6, sdlog = 0.5, max = 19)
  combined <- dist + dist
  plot <- plot(combined)
  expect_equal(length(plot$layers), 2)
  expect_equal(length(plot$facet$params$facets), 1)
})

test_that("plot.dist_spec plots an unbounded parametric distribution", {
  expect_s3_class(plot(Gamma(mean = 4, sd = 2)), "ggplot")
  expect_s3_class(plot(LogNormal(meanlog = 1.5, sdlog = 0.5)), "ggplot")
})

test_that("plot.dist_spec plots an unbounded uncertain distribution", {
  dist <- Gamma(shape = Normal(3, 0.5), rate = Normal(2, 0.5))
  expect_s3_class(plot(dist), "ggplot")
})

test_that("fix_parameters works with composite delay distributions", {
  dist1 <- LogNormal(meanlog = Normal(1, 0.1), sdlog = 1, max = 19)
  dist2 <- Gamma(mean = 3, sd = 2, max = 19)
  dist <- dist1 + dist2
  expect_equal(ndist(collapse(discretise(fix_parameters(dist)))), 1L)
})

test_that("composite delay distributions can be disassembled", {
  dist1 <- LogNormal(meanlog = Normal(1, 0.1), sdlog = 1, max = 19)
  dist2 <- Gamma(mean = 3, sd = 2, max = 19)
  dist <- dist1 + dist2
  expect_equal(extract_single_dist(dist, 1), dist1)
  expect_equal(extract_single_dist(dist, 2), dist2)
})

test_that("constrained distributions are correctly identified", {
  expect_false(is_constrained(Gamma(shape = 3, scale = 2)))
  expect_true(is_constrained(Gamma(shape = 3, scale = 2, max = 10)))
  expect_true(is_constrained(Gamma(shape = 3, scale = 2, cdf_cutoff = 0.1)))
  expect_false(is_constrained(
    Gamma(shape = 3, scale = 2) +
      Gamma(shape = 3, scale = 2, max = 10)
  ))
  expect_true(is_constrained(
    Gamma(shape = 3, scale = 2, max = 10) +
      Gamma(shape = 3, scale = 2, max = 10)
  ))
})

test_that("delay distributions can be specified in different ways", {
  expect_equal(
    unname(as.numeric(get_parameters(LogNormal(mean = 4, sd = 1)))),
    c(1.4, 0.25),
    tolerance = 0.1
  )
  expect_equal(
    round(get_pmf(discretise(LogNormal(mean = 4, sd = 1, max = 10))), 2),
    c(0.00, 0.00, 0.05, 0.29, 0.38, 0.20, 0.06, 0.02, 0.00, 0.00)
  )
  expect_equal(
    round(
      get_pmf(discretise(LogNormal(mean = 4, sd = 1, cdf_cutoff = 0.1))), 2
    ),
    c(0.00, 0.00, 0.05, 0.32, 0.41, 0.22)
  )
  expect_equal(
    unname(as.numeric(get_parameters(Gamma(mean = 4, sd = 1)))),
    c(16, 4),
    tolerance = 0.1
  )
  expect_equal(
    round(get_pmf(discretise(Gamma(mean = 4, sd = 1, max = 7))), 2),
    c(0.00, 0.00, 0.06, 0.28, 0.38, 0.22, 0.07)
  )
  expect_equal(
    round(get_pmf(discretise(Gamma(mean = 4, sd = 1, cdf_cutoff = 0.1))), 2),
    c(0.00, 0.00, 0.06, 0.30, 0.40, 0.23)
  )
  expect_equal(
    unname(as.numeric(
      get_parameters(get_parameters(
        c(
          Gamma(
            shape = Normal(12, 3), rate = Normal(3, 0.5)
          ),
          Gamma(
            shape = Normal(16, 2), rate = Normal(4, 1)
          )
        ), 2
      )$shape)
    )),
    c(16, 2)
  )
  expect_equal(
    unname(as.numeric(
      get_parameters(get_parameters(
        Gamma(
          shape = Normal(16, 2), rate = Normal(4, 1)
        )
      )$rate)
    )),
    c(4, 1)
  )
  expect_equal(
    round(get_pmf(discretise(Normal(mean = 4, sd = 1, max = 5))), 2),
    c(0.00, 0.01, 0.10, 0.35, 0.54)
  )
  expect_equal(
    round(get_pmf(discretise(Normal(mean = 4, sd = 1, cdf_cutoff = 0.1))), 2),
    c(0.00, 0.01, 0.07, 0.26, 0.40, 0.26)
  )
  expect_equal(
    round(get_pmf(discretise(Exp(rate = 0.5, max = 5))), 2),
    c(0.24, 0.35, 0.21, 0.13, 0.08)
  )
  expect_equal(
    round(get_pmf(discretise(Weibull(shape = 2, scale = 5, max = 5))), 2),
    c(0.02, 0.14, 0.24, 0.30, 0.30)
  )
  expect_equal(get_pmf(discretise(Fixed(value = 3))), c(0, 0, 0, 1))
  ## fractional fixed values split probability across adjacent intervals
  expect_equal(get_pmf(discretise(Fixed(value = 2.5))), c(0, 0, 0.5, 0.5))
  expect_equal(get_pmf(discretise(Fixed(value = 1.25))), c(0, 0.75, 0.25))
  expect_equal(get_parameters(Fixed(value = 3.5))$value, 3.5)
  expect_equal(
    get_pmf(NonParametric(c(0.1, 0.3, 0.2, 0.4))),
    c(0.1, 0.3, 0.2, 0.4)
  )
  expect_equal(
    round(get_pmf(NonParametric(c(0.1, 0.3, 0.2, 0.1, 0.1))), 2),
    c(0.12, 0.37, 0.25, 0.12, 0.12)
  )
  expect_equal(
    get_distribution(NonParametric(c(0.1, 0.3, 0.2, 0.1, 0.1))),
    "nonparametric"
  )
})

test_that("a fixed distribution accepts a value of zero", {
  zero <- Fixed(value = 0)
  expect_identical(lower_bounds(zero), c(value = 0))
  expect_equal(mean(zero), 0)
  expect_equal(sd(zero), 0)
  expect_equal(get_pmf(discretise(Fixed(value = 0))), 1)
})

test_that("a fixed distribution rejects a value below its lower bound", {
  expect_error(Fixed(value = -1), "lower bound")
  expect_error(Fixed(value = -0.5), "lower bound")
  ## an uncertain value is bound-checked when sampled, not at construction
  expect_no_error(Fixed(value = Normal(0.3, 0.05)))
  ## the same bound is enforced when a zero-sd normal collapses to fixed
  expect_error(Normal(-3, 0), "lower bound")
  expect_no_error(Normal(3, 0))
})

test_that("an uncertain fixed value is not truncated below one when sampled", {
  set.seed(1)
  ## with the old lower bound of 1 the sampled value would be truncated at 1
  sampled <- fix_parameters(
    Fixed(value = Normal(0.3, 0.05)), strategy = "sample"
  )
  expect_lt(get_parameters(sampled)$value, 1)
})

test_that("get functions report errors", {
  expect_error(get_parameters("test"), "no applicable method")
  expect_error(
    get_distribution(Gamma(mean = 4, sd = 1), 2),
    "must be between 1 and 1"
  )
  expect_error(
    get_distribution(Gamma(mean = 4, sd = 1), 2),
    "You supplied .*id.* = 2"
  )
  expect_error(get_pmf(Gamma(mean = 4, sd = 1)), "parametric")
  expect_error(
    get_parameters(NonParametric(c(0.1, 0.3, 0.2, 0.1, 0.1))),
    "nonparametric"
  )
  expect_error(
    get_parameters(NonParametric(c(0.1, 0.3, 0.2, 0.1, 0.1))),
    "get_pmf"
  )
  expect_error(get_parameters(c(
    Gamma(mean = 4, sd = 1), Gamma(mean = 4, sd = 1)
  )), "must be specified")
})

test_that("Dirichlet works with alpha vector", {
  alpha <- c(1, 2, 3)
  result <- Dirichlet(alpha)
  expect_s3_class(result, "dist_spec")
  expect_equal(get_distribution(result), "dirichlet")
  expect_equal(get_parameters(result)$alpha, alpha)
  expect_equal(mean(result), alpha / sum(alpha))
})

test_that("Dirichlet works with prior and concentration", {
  prior <- c(0.1, 0.3, 0.4, 0.2)
  conc <- 10
  result <- Dirichlet(prior = prior, concentration = conc)
  expect_s3_class(result, "dist_spec")
  expect_equal(get_distribution(result), "dirichlet")
  expect_equal(get_parameters(result)$alpha, conc * prior / sum(prior))
  expect_equal(mean(result), prior / sum(prior))
})

test_that("NonParametric works with Dirichlet prior", {
  prior <- c(0.1, 0.3, 0.4, 0.2)
  conc <- 10
  result <- NonParametric(pmf = Dirichlet(prior = prior, concentration = conc))
  expect_s3_class(result, "dist_spec")
  expect_equal(get_distribution(result), "nonparametric")
  ## an estimated distribution stores its Dirichlet prior as the `pmf`, so it
  ## has no concrete (numeric) PMF
  expect_s3_class(result$pmf, "dist_spec")
  expect_equal(get_distribution(result$pmf), "dirichlet")
  expect_equal(get_parameters(result$pmf)$alpha, conc * prior / sum(prior))
  expect_s3_class(result, "uncertain")
})

test_that("an estimated nonparametric distribution has no concrete PMF", {
  prior <- c(0.1, 0.3, 0.4, 0.2)
  result <- NonParametric(pmf = Dirichlet(prior = prior, concentration = 10))
  ## `get_pmf()` and sampling error; the mean is uncertain
  expect_error(get_pmf(result), "no fixed probability mass function")
  expect_error(sample_dist(result, 5), "fixed parameters")
  expect_true(is.na(mean(result)))
  expect_equal(mean(result, ignore_uncertainty = TRUE), sum((0:3) * prior))
  expect_equal(max(result), length(prior))
})

test_that("fix_parameters resolves an estimated nonparametric distribution", {
  prior <- c(0.1, 0.3, 0.4, 0.2)
  result <- NonParametric(pmf = Dirichlet(prior = prior, concentration = 10))
  fixed <- fix_parameters(result, strategy = "mean")
  expect_equal(get_distribution(fixed), "nonparametric")
  expect_equal(get_pmf(fixed), prior / sum(prior))
  expect_false(inherits(fixed, "uncertain"))
})

test_that("bounding an estimated nonparametric distribution errors", {
  ## `max`/`cdf_cutoff` have no effect on an estimated distribution, so they are
  ## rejected rather than silently ignored
  expect_error(
    NonParametric(pmf = Dirichlet(c(0, 2, 4)), cdf_cutoff = 0.1),
    "estimated nonparametric"
  )
  expect_error(
    NonParametric(pmf = Dirichlet(c(0, 2, 4)), max = 2),
    "estimated nonparametric"
  )
  expect_error(
    bound_dist(NonParametric(pmf = Dirichlet(c(0, 2, 4))), max = 2),
    "estimated nonparametric"
  )
  ## an unbounded estimated distribution is fine
  expect_s3_class(NonParametric(pmf = Dirichlet(c(0, 2, 4))), "dist_spec")
})

test_that("bound_dist truncates and renormalises a fixed nonparametric PMF", {
  np <- NonParametric(c(0.1, 0.3, 0.4, 0.2))
  ## `max` smaller than the support keeps bins 0..max and renormalises
  bounded <- bound_dist(np, max = 2)
  expect_equal(get_pmf(bounded), c(0.125, 0.375, 0.5))
  expect_equal(sum(get_pmf(bounded)), 1)
  expect_equal(max(bounded), 3)
})

test_that("bound_dist leaves a fixed nonparametric PMF untouched beyond support", {
  np <- NonParametric(c(0.1, 0.3, 0.4, 0.2))
  ## `max` at or beyond the support is a no-op and introduces no NAs
  expect_equal(get_pmf(bound_dist(np, max = 5)), c(0.1, 0.3, 0.4, 0.2))
  expect_equal(get_pmf(bound_dist(np, max = 3)), c(0.1, 0.3, 0.4, 0.2))
  expect_false(anyNA(get_pmf(bound_dist(np, max = 5))))
})

test_that("NonParametric applies max at construction", {
  ## the same truncation is reachable through the constructor
  expect_equal(
    get_pmf(NonParametric(c(0.1, 0.3, 0.4, 0.2), max = 2)),
    c(0.125, 0.375, 0.5)
  )
})

test_that("bound_dist combines cdf_cutoff and max on a nonparametric PMF", {
  np <- NonParametric(c(0.1, 0.3, 0.4, 0.2))
  ## `cdf_cutoff` is applied to the tail before `max` truncates and renormalises
  bounded <- bound_dist(np, max = 2, cdf_cutoff = 0.05)
  expect_equal(get_pmf(bounded), c(0.125, 0.375, 0.5))
  expect_equal(sum(get_pmf(bounded)), 1)
})

test_that("an estimated nonparametric distribution nests its prior on print", {
  result <- NonParametric(pmf = Dirichlet(c(2, 4, 4)))
  ## printed like any uncertain distribution: the PMF shown as a nested prior,
  ## with no special "estimated" label
  expect_output(print(result), "- nonparametric distribution:")
  expect_output(print(result), "pmf:")
  expect_output(print(result), "- dirichlet distribution:")
  expect_output(print(result), "alpha:")
})

test_that("estimated nonparametric distributions compare by their prior", {
  a <- NonParametric(pmf = Dirichlet(c(2, 4, 4)))
  ## equal to another with the same prior, unequal to a different prior or to
  ## a fixed PMF
  expect_true(a == NonParametric(pmf = Dirichlet(c(2, 4, 4))))
  expect_false(a == NonParametric(pmf = Dirichlet(c(2, 4, 5))))
  expect_false(a == NonParametric(pmf = c(0.2, 0.4, 0.4)))
})

test_that("has_uncertainty distinguishes fixed and uncertain distributions", {
  expect_false(has_uncertainty(Gamma(shape = 1, rate = 1)))
  expect_true(has_uncertainty(Gamma(shape = Normal(1, 0.5), rate = 1)))
  expect_false(has_uncertainty(Fixed(3)))
  expect_false(has_uncertainty(NonParametric(c(0.2, 0.8))))
  expect_true(has_uncertainty(NonParametric(pmf = Dirichlet(c(1, 1, 1)))))
  ## indexes into a composite distribution
  composite <- Gamma(shape = 1, rate = 1) +
    Gamma(shape = Normal(1, 0.5), rate = 1)
  expect_false(has_uncertainty(composite, 1))
  expect_true(has_uncertainty(composite, 2))
})

test_that("Dirichlet works with dist_spec prior", {
  dist <- LogNormal(meanlog = 1, sdlog = 0.5, max = 10)
  result <- Dirichlet(prior = dist, concentration = 5)
  expect_s3_class(result, "dist_spec")
  expect_equal(get_distribution(result), "dirichlet")
  expected_pmf <- get_pmf(discretise(dist))
  expect_equal(mean(result), expected_pmf)
  expect_equal(get_parameters(result)$alpha, 5 * expected_pmf)
})

test_that("beta distribution is specified via natural shape parameters", {
  result <- Beta(shape1 = 2, shape2 = 5)
  expect_equal(get_distribution(result), "beta")
  expect_equal(get_parameters(result), list(shape1 = 2, shape2 = 5))
  expect_equal(mean(result), 2 / 7)
  expect_equal(sd(result), sqrt(2 * 5 / (7^2 * 8)))
})

test_that("beta distribution can be specified via mean and sd", {
  result <- Beta(mean = 0.3, sd = 0.15)
  expect_equal(get_distribution(result), "beta")
  expect_equal(mean(result), 0.3)
  expect_equal(sd(result), 0.15)
})

test_that("beta rejects an infeasible mean/sd and out-of-range shapes", {
  expect_error(Beta(mean = 0.5, sd = 0.6), "variance of a beta")
  expect_error(Beta(mean = 1.2, sd = 0.1), "must be between 0 and 1")
  expect_error(Beta(shape1 = -1, shape2 = 2), "lower bound")
})
