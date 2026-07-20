test_that("Exp() is deprecated in favour of Exponential()", {
  lifecycle::expect_deprecated(Exp(rate = 1))
  expect_equal(
    suppressWarnings(Exp(rate = 1)),
    Exponential(rate = 1)
  )
  expect_s3_class(suppressWarnings(Exp(rate = 1)), "dist_spec")
})

test_that("cdf_cutoff below 0.5 is rejected with a helpful error", {
  expect_error(
    bound_dist(Gamma(mean = 4, sd = 1), cdf_cutoff = 0.01),
    "keep less than half"
  )
  expect_error(
    Gamma(mean = 4, sd = 1, cdf_cutoff = 0.01),
    "keep less than half"
  )
  expect_error(
    bound_dist(Gamma(mean = 4, sd = 1), cdf_cutoff = 1.5),
    "must be a single number"
  )
})
