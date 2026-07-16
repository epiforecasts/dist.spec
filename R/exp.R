# Exponential distribution
#
# Everything specific to the exponential distribution lives here, following the
# per-distribution interface introduced for the gamma distribution (see
# `distribution.R`, `gamma.R` and #41).

#' @exportS3Method
natural_params.exp <- function(distribution) "rate"

#' @exportS3Method
lower_bounds.exp <- function(distribution) {
  c(rate = 0, mean = 0)
}

#' @exportS3Method
dist_cdf.exp <- function(distribution) pexp

#' @method mean exp
#' @export
mean.exp <- function(x, ...) 1 / x$params$rate

#' @method sd exp
#' @export
sd.exp <- function(x, ...) 1 / x$params$rate
