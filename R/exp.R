# Exponential distribution
#
# Per-type methods for the exponential distribution; see `gamma.R` and #64.

#' @exportS3Method
natural_params.exp <- function(x) "rate"

#' @exportS3Method
lower_bounds.exp <- function(x) {
  c(rate = 0, mean = 0)
}

#' @exportS3Method
dist_cdf.exp <- function(x) pexp

#' @exportS3Method
to_natural.exp <- function(x, ux) {
  list(rate = if ("mean" %in% names(ux)) 1 / ux$mean else ux$rate)
}

#' @method mean exp
#' @export
mean.exp <- function(x, ...) 1 / x$parameters$rate

#' @method sd exp
#' @export
sd.exp <- function(x, ...) 1 / x$parameters$rate

#' @importFrom stats rexp
#' @exportS3Method
sample_dist.exp <- function(x, n, ...) {
  rexp(n, rate = x$parameters$rate)
}
