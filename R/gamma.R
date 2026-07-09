# Gamma distribution
#
# Everything specific to the gamma distribution lives here. This is the first
# distribution migrated to the per-distribution interface (see `distribution.R`
# and #41); the remaining distributions follow the same shape.

#' @exportS3Method
dist_natural_params.gamma <- function(d) c("shape", "rate")

#' @exportS3Method
dist_cdf.gamma <- function(d) pgamma

#' @method mean gamma
#' @export
mean.gamma <- function(x, ...) x$params$shape / x$params$rate

#' @method sd gamma
#' @export
sd.gamma <- function(x, ...) sqrt(x$params$shape / x$params$rate^2)
