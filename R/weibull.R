# Weibull distribution
#
# Everything specific to the Weibull distribution lives here, following the
# per-distribution interface introduced for the gamma distribution (see
# `distribution.R`, `gamma.R` and #41).

#' @exportS3Method
natural_params.weibull <- function(distribution) c("shape", "scale")

#' @exportS3Method
lower_bounds.weibull <- function(distribution) {
  c(shape = 0, scale = 0, mean = 0, sd = 0)
}

#' @exportS3Method
dist_cdf.weibull <- function(distribution) pweibull

#' @method mean weibull
#' @export
mean.weibull <- function(x, ...) {
  x$params$scale * gamma(1 + 1 / x$params$shape)
}

#' @method sd weibull
#' @export
sd.weibull <- function(x, ...) {
  shape <- x$params$shape
  scale <- x$params$scale
  scale * sqrt(gamma(1 + 2 / shape) - gamma(1 + 1 / shape)^2)
}

#' @importFrom stats rweibull
#' @exportS3Method
sample_dist.weibull <- function(x, n, ...) {
  rweibull(n, shape = x$params$shape, scale = x$params$scale)
}
