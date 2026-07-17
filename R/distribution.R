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
  if (!is.character(name) || length(name) != 1 ||
        is.na(name) || !nzchar(name)) {
    cli::cli_abort("`name` must be a non-empty scalar character string.")
  }
  if (!is.null(params) && !is.list(params)) {
    cli::cli_abort("`params` must be a list or NULL.")
  }
  structure(list(params = params), class = c(name, "distribution"))
}

# --- interface generics -----------------------------------------------------

# `natural_params()` and `lower_bounds()` are existing exported helpers turned
# into generics (see `dist_spec.R`); their per-distribution methods live in each
# distribution's file (e.g. `natural_params.gamma`). Analytic `mean()` / `sd()`
# reuse the base generics the same way.

# CDF function, used for discretisation. Optional capability: distributions
# that are never discretised simply do not provide a method.
dist_cdf <- function(distribution) UseMethod("dist_cdf")

# Discretisation is an optional capability, not a type: a distribution without
# a CDF cannot be discretised.
#' @exportS3Method
dist_cdf.default <- function(distribution) {
  cli::cli_abort(
    "{.val {class(distribution)[1]}} has no CDF and cannot be discretised."
  )
}

# Fallbacks for distribution types that do not provide an analytic `mean()` /
# `sd()`. These back the delegating `mean.dist_spec()` / `sd.dist_spec()` so an
# unsupported type fails with a clear message rather than a base-R default.
#' @method mean distribution
#' @export
mean.distribution <- function(x, ...) {
  cli::cli_abort(
    "Don't know how to calculate mean of {.val {class(x)[1]}} distribution."
  )
}

#' @method sd distribution
#' @export
sd.distribution <- function(x, ...) {
  cli::cli_abort(
    "Don't know how to calculate standard deviation of {.val {class(x)[1]}}
    distribution."
  )
}

# --- sampling ---------------------------------------------------------------

# The `sample_dist()` generic is defined alongside its `dist_spec` method in
# `dist_spec.R` (as `sd()` is). A distribution can only be sampled if it
# provides a per-type sampler; anything else (e.g. the Dirichlet prior) is not
# a sampling distribution for delays.
#' @exportS3Method
sample_dist.distribution <- function(x, n, ...) {
  cli::cli_abort(
    "Don't know how to sample from {.val {class(x)[1]}} distribution."
  )
}
