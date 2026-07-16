# Gamma distribution
#
# Everything specific to the gamma distribution lives here. This is the first
# distribution migrated to the per-distribution interface (see `distribution.R`
# and #41); the remaining distributions follow the same shape.

#' @exportS3Method
natural_params.gamma <- function(distribution) c("shape", "rate")

#' @exportS3Method
lower_bounds.gamma <- function(distribution) {
  c(shape = 0, rate = 0, scale = 0, mean = 0, sd = 0)
}

#' @exportS3Method
dist_cdf.gamma <- function(distribution) pgamma

#' @method mean gamma
#' @export
mean.gamma <- function(x, ...) x$params$shape / x$params$rate

#' @method sd gamma
#' @export
sd.gamma <- function(x, ...) sqrt(x$params$shape / x$params$rate^2)

#' @importFrom stats rgamma
#' @exportS3Method
sample_dist.gamma <- function(x, n, ...) {
  rgamma(n, shape = x$params$shape, rate = x$params$rate)
}
