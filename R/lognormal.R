# Lognormal distribution
#
# Per-type methods for the lognormal distribution; see `gamma.R` and #64.

#' @exportS3Method
natural_params.lognormal <- function(x) c("meanlog", "sdlog")

#' @exportS3Method
lower_bounds.lognormal <- function(x) {
  c(meanlog = -Inf, sdlog = 0, mean = 0, sd = 0)
}

#' @exportS3Method
dist_cdf.lognormal <- function(x) plnorm

#' @exportS3Method
to_natural.lognormal <- function(x, ux) {
  if (all(c("mean", "sd") %in% names(ux))) {
    list(
      meanlog = log(ux$mean^2 / sqrt(ux$sd^2 + ux$mean^2)),
      sdlog = convert_to_logsd(ux$mean, ux$sd)
    )
  } else {
    list(meanlog = ux$meanlog, sdlog = ux$sdlog)
  }
}

#' @method mean lognormal
#' @export
mean.lognormal <- function(x, ...) {
  exp(x$parameters$meanlog + x$parameters$sdlog^2 / 2)
}

#' @method sd lognormal
#' @export
sd.lognormal <- function(x, ...) {
  sqrt(exp(x$parameters$sdlog^2) - 1) *
    exp(x$parameters$meanlog + 0.5 * x$parameters$sdlog^2)
}

#' @importFrom stats rlnorm
#' @exportS3Method
sample_dist.lognormal <- function(x, n, ...) {
  rlnorm(n, meanlog = x$parameters$meanlog, sdlog = x$parameters$sdlog)
}
