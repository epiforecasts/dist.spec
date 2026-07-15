# Normal distribution
#
# Everything specific to the normal distribution lives here, following the
# per-distribution interface introduced for the gamma distribution (see
# `distribution.R`, `gamma.R` and #41).

#' @exportS3Method
natural_params.normal <- function(distribution) c("mean", "sd")

#' @exportS3Method
lower_bounds.normal <- function(distribution) {
  c(mean = -Inf, sd = 0)
}

#' @exportS3Method
dist_cdf.normal <- function(distribution) pnorm

#' @method mean normal
#' @export
mean.normal <- function(x, ...) x$params$mean

#' @method sd normal
#' @export
sd.normal <- function(x, ...) x$params$sd
