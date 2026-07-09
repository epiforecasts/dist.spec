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

# Natural (stan) parameter names. Type-level: ignores parameter values.
dist_natural_params <- function(d) UseMethod("dist_natural_params")

# CDF function, used for discretisation. Optional capability: distributions
# that are never discretised simply do not provide a method.
dist_cdf <- function(d) UseMethod("dist_cdf")

# Analytic mean / standard deviation are the existing `mean` / `sd` generics;
# per-distribution methods live in each distribution's file (e.g. `mean.gamma`).

# Discretisation is an optional capability, not a type: a distribution without
# a CDF cannot be discretised.
#' @exportS3Method
dist_cdf.default <- function(d) {
  cli::cli_abort(
    "{.val {class(d)[1]}} has no CDF and cannot be discretised."
  )
}
