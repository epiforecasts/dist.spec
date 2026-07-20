# Normal distribution
#
# Per-type methods for the normal distribution; see `gamma.R` and #64.

#' @exportS3Method
natural_params.normal <- function(x) c("mean", "sd")

#' @exportS3Method
lower_bounds.normal <- function(x) {
  c(mean = -Inf, sd = 0)
}

#' @exportS3Method
dist_cdf.normal <- function(x) pnorm

#' @exportS3Method
to_natural.normal <- function(x, ux) {
  list(mean = ux$mean, sd = ux$sd)
}

#' @method mean normal
#' @export
mean.normal <- function(x, ...) x$parameters$mean

#' @method sd normal
#' @export
sd.normal <- function(x, ...) x$parameters$sd

#' @importFrom stats rnorm
#' @exportS3Method
sample_dist.normal <- function(x, n, ...) {
  rnorm(n, mean = x$parameters$mean, sd = x$parameters$sd)
}
