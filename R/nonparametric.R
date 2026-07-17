# Nonparametric distribution
#
# A nonparametric distribution is defined directly by its probability mass
# function (stored in `x$pmf`) rather than by parameters. Its summary statistics
# are computed from the PMF over the support 0, 1, 2, .... It has no
# `natural_params()`/`lower_bounds()` (it is not an estimated parametric family)
# and no `dist_cdf()` (it is already discretised). See `gamma.R` and #64.

#' @method mean nonparametric
#' @export
mean.nonparametric <- function(x, ...) {
  pmf <- x$pmf
  sum((seq_along(pmf) - 1) * pmf)
}

#' @method sd nonparametric
#' @export
sd.nonparametric <- function(x, ...) {
  pmf <- x$pmf
  mean_pmf <- sum((seq_along(pmf) - 1) * pmf)
  variance <- sum((seq_along(pmf) - 1)^2 * pmf) - mean_pmf^2
  sqrt(max(variance, 0))
}

#' @method max nonparametric
#' @export
max.nonparametric <- function(x, ...) length(x$pmf)

# Sample from the discrete support 0, 1, 2, ... with probabilities given by the
# PMF. `sample.int()` avoids the length-1 pitfall of `sample()`.
#' @exportS3Method
sample_dist.nonparametric <- function(x, n, ...) {
  pmf <- x$pmf
  sample.int(length(pmf), size = n, replace = TRUE, prob = pmf) - 1L
}
