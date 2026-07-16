# Fixed distribution
#
# Everything specific to the fixed (point-mass) distribution lives here,
# following the per-distribution interface introduced for the gamma
# distribution (see `distribution.R`, `gamma.R` and #41). A fixed distribution
# is discretised by a dedicated branch in `discrete_pmf()` rather than through a
# CDF, so it provides no `dist_cdf()` method.

#' @exportS3Method
natural_params.fixed <- function(distribution) "value"

#' @exportS3Method
lower_bounds.fixed <- function(distribution) {
  c(value = 0)
}

#' @method mean fixed
#' @export
mean.fixed <- function(x, ...) x$params$value

#' @method sd fixed
#' @export
sd.fixed <- function(x, ...) 0.0
