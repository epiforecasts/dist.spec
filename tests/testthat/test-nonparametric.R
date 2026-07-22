test_that("a nonparametric distribution normalises its PMF", {
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

test_that("NonParametric works with Dirichlet prior", {
  prior <- c(0.1, 0.3, 0.4, 0.2)
  conc <- 10
  result <- NonParametric(pmf = Dirichlet(prior = prior, concentration = conc))
  expect_s3_class(result, "dist_spec")
  expect_equal(get_distribution(result), "nonparametric")
  ## an uncertain distribution stores its Dirichlet prior as the `pmf`, so it
  ## has no concrete (numeric) PMF
  expect_s3_class(result$pmf, "dist_spec")
  expect_equal(get_distribution(result$pmf), "dirichlet")
  expect_equal(get_parameters(result$pmf)$alpha, conc * prior / sum(prior))
  expect_s3_class(result, "uncertain_dist_spec")
})

test_that("an uncertain nonparametric distribution has no concrete PMF", {
  prior <- c(0.1, 0.3, 0.4, 0.2)
  result <- NonParametric(pmf = Dirichlet(prior = prior, concentration = 10))
  ## `get_pmf()` and sampling error; the mean is uncertain
  expect_error(get_pmf(result), "no fixed probability mass function")
  expect_error(sample_dist(result, 5), "fixed parameters")
  expect_true(is.na(suppressMessages(mean(result))))
  expect_equal(mean(result, ignore_uncertainty = TRUE), sum((0:3) * prior))
  expect_equal(max(result), length(prior))
})

test_that("fix_parameters resolves an uncertain nonparametric distribution", {
  prior <- c(0.1, 0.3, 0.4, 0.2)
  result <- NonParametric(pmf = Dirichlet(prior = prior, concentration = 10))
  fixed <- fix_parameters(result, strategy = "mean")
  expect_equal(get_distribution(fixed), "nonparametric")
  expect_equal(get_pmf(fixed), prior / sum(prior))
  expect_false(inherits(fixed, "uncertain_dist_spec"))
})

test_that("bounding an uncertain nonparametric distribution errors", {
  ## `max`/`cdf_cutoff` have no effect on an uncertain distribution, so they are
  ## rejected rather than silently ignored
  expect_error(
    NonParametric(pmf = Dirichlet(c(0, 2, 4)), cdf_cutoff = 0.9),
    "uncertain nonparametric"
  )
  expect_error(
    NonParametric(pmf = Dirichlet(c(0, 2, 4)), max = 2),
    "uncertain nonparametric"
  )
  expect_error(
    bound_dist(NonParametric(pmf = Dirichlet(c(0, 2, 4))), max = 2),
    "uncertain nonparametric"
  )
  ## an unbounded uncertain distribution is fine
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
  bounded <- bound_dist(np, max = 2, cdf_cutoff = 0.95)
  expect_equal(get_pmf(bounded), c(0.125, 0.375, 0.5))
  expect_equal(sum(get_pmf(bounded)), 1)
})

test_that("an uncertain nonparametric distribution nests its prior on print", {
  result <- NonParametric(pmf = Dirichlet(c(2, 4, 4)))
  ## printed like any uncertain distribution: the PMF shown as a nested prior,
  ## with no extra label in the output beyond the distribution type
  expect_output(print(result), "- nonparametric distribution:")
  expect_output(print(result), "pmf:")
  expect_output(print(result), "- dirichlet distribution:")
  expect_output(print(result), "alpha:")
})

test_that("uncertain nonparametric distributions compare by their prior", {
  a <- NonParametric(pmf = Dirichlet(c(2, 4, 4)))
  ## equal to another with the same prior, unequal to a different prior or to
  ## a fixed PMF
  expect_true(a == NonParametric(pmf = Dirichlet(c(2, 4, 4))))
  expect_false(a == NonParametric(pmf = Dirichlet(c(2, 4, 5))))
  expect_false(a == NonParametric(pmf = c(0.2, 0.4, 0.4)))
})
