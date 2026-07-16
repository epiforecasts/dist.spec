# Lognormal distribution
#
# Everything specific to the lognormal distribution lives here, following the
# per-distribution interface introduced for the gamma distribution (see
# `distribution.R`, `gamma.R` and #41).

#' @exportS3Method
natural_params.lognormal <- function(distribution) c("meanlog", "sdlog")

#' @exportS3Method
lower_bounds.lognormal <- function(distribution) {
  c(meanlog = -Inf, sdlog = 0, mean = 0, sd = 0)
}

#' @exportS3Method
dist_cdf.lognormal <- function(distribution) plnorm

#' @method mean lognormal
#' @export
mean.lognormal <- function(x, ...) {
  exp(x$params$meanlog + x$params$sdlog^2 / 2)
}

#' @method sd lognormal
#' @export
sd.lognormal <- function(x, ...) {
  sqrt(exp(x$params$sdlog^2) - 1) *
    exp(x$params$meanlog + 0.5 * x$params$sdlog^2)
}

#' @importFrom stats rlnorm
#' @exportS3Method
sample_dist.lognormal <- function(x, n, ...) {
  rlnorm(n, meanlog = x$params$meanlog, sdlog = x$params$sdlog)
}
