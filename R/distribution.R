# The distribution interface
#
# A lightweight object used for S3 method dispatch on the distribution *type*.
# It carries the type as its class and, optionally, its parameters, so that
# everything specific to a distribution can live in its own file (see e.g.
# `gamma.R`) rather than in `switch()` statements scattered across the package.
#
# This is the scaffolding for the refactor in #41: as each distribution is
# migrated, the corresponding `switch()` arm delegates to these generics; once
# every type is migrated the switches collapse to a single dispatch call.

# Build a dispatch object from a distribution name (+ optional parameters).
new_dist <- function(name, params = NULL) {
  structure(list(params = params), class = c(name, "distribution"))
}

# --- interface generics -----------------------------------------------------

# `natural_params()` and `lower_bounds()` are existing exported helpers turned
# into generics (see `dist_spec.R`); their per-distribution methods live in each
# distribution's file (e.g. `natural_params.gamma`). Analytic `mean()` / `sd()`
# reuse the base generics the same way.

# CDF function, used for discretisation. Optional capability: distributions
# that are never discretised simply do not provide a method.
pdist <- function(distribution) UseMethod("pdist")

# Discretisation is an optional capability, not a type: a distribution without
# a CDF cannot be discretised.
#' @exportS3Method
pdist.default <- function(distribution) {
  cli::cli_abort(
    "{.val {class(distribution)[1]}} has no CDF and cannot be discretised."
  )
}
