# Guards the core contract every distribution must satisfy. It enumerates each
# type that registers a `natural_params()` method (that is what makes a type a
# distribution) and asserts that the type also defines the rest of the core
# contract: `lower_bounds()` and `mean()`. Registering `natural_params.<type>()`
# without these fails the test, so a half-added distribution is caught in CI.
#
# The conditional generics (`to_natural`, `sd`, `sample_dist`, `dist_cdf`) are
# deliberately not enforced here: they are defined only when a distribution
# supports the matching capability (see `vignettes/adding-a-distribution.Rmd`).

# The core generics every distribution type must implement.
core_generics <- c("natural_params", "lower_bounds", "mean")

# Types that register a `natural_params()` method, excluding the generic
# fall-throughs and the whole-spec dispatch classes.
registered_types <- function() {
  methods <- as.character(utils::.S3methods("natural_params"))
  types <- sub("^natural_params\\.", "", methods)
  setdiff(types, c("default", "character", "dist_spec", "multi_dist_spec"))
}

test_that("at least the known distribution types are enumerated", {
  expect_true(all(
    c("gamma", "lognormal", "normal", "beta", "exp", "weibull", "fixed",
      "dirichlet") %in%
      registered_types()
  ))
})

test_that("every distribution type implements the core contract", {
  for (type in registered_types()) {
    for (generic in core_generics) {
      method <- utils::getS3method(generic, type, optional = TRUE)
      expect_false(
        is.null(method),
        info = paste0(
          "Distribution type '", type, "' is missing the core method ",
          generic, ".", type, "()."
        )
      )
    }
  }
})
