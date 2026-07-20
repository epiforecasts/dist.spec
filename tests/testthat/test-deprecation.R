test_that("Exp() is deprecated in favour of Exponential()", {
  lifecycle::expect_deprecated(Exp(rate = 1))
  expect_equal(
    suppressWarnings(Exp(rate = 1)),
    Exponential(rate = 1)
  )
  expect_s3_class(suppressWarnings(Exp(rate = 1)), "dist_spec")
})

test_that("cdf_cutoff is deprecated in favour of tail_cutoff", {
  lifecycle::expect_deprecated(
    bound_dist(Gamma(mean = 4, sd = 1), cdf_cutoff = 0.01)
  )
  expect_equal(
    suppressWarnings(bound_dist(Gamma(mean = 4, sd = 1), cdf_cutoff = 0.01)),
    bound_dist(Gamma(mean = 4, sd = 1), tail_cutoff = 0.01)
  )

  lifecycle::expect_deprecated(Gamma(mean = 4, sd = 1, cdf_cutoff = 0.01))
  expect_equal(
    suppressWarnings(Gamma(mean = 4, sd = 1, cdf_cutoff = 0.01)),
    Gamma(mean = 4, sd = 1, tail_cutoff = 0.01)
  )
})

test_that("tail_cutoff does not warn", {
  expect_no_warning(bound_dist(Gamma(mean = 4, sd = 1), tail_cutoff = 0.01))
  expect_no_warning(Gamma(mean = 4, sd = 1, tail_cutoff = 0.01))
})
