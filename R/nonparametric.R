# Nonparametric distribution
#
# A nonparametric distribution is defined directly by its probability mass
# function rather than by parameters, following the per-distribution interface
# introduced for the gamma distribution (see `distribution.R`, `gamma.R` and
# #41). Its summary statistics are computed from the PMF over the support
# 0, 1, 2, .... It has no `natural_params()`/`lower_bounds()` (it is not an
# estimated parametric family) and no `dist_cdf()` (it is already discretised).

#' @method mean nonparametric
#' @export
mean.nonparametric <- function(x, ...) {
  pmf <- x$params$pmf
  sum((seq_along(pmf) - 1) * pmf)
}

#' @method sd nonparametric
#' @export
sd.nonparametric <- function(x, ...) {
  pmf <- x$params$pmf
  mean_pmf <- sum((seq_along(pmf) - 1) * pmf)
  variance <- sum((seq_along(pmf) - 1)^2 * pmf) - mean_pmf^2
  sqrt(max(variance, 0))
}

#' @method max nonparametric
#' @export
max.nonparametric <- function(x, ...) length(x$params$pmf)

# Sample from the discrete support 0, 1, 2, ... with probabilities given by the
# PMF. `sample.int()` avoids the length-1 pitfall of `sample()`.
#' @exportS3Method
sample_dist.nonparametric <- function(x, n, ...) {
  pmf <- x$params$pmf
  sample.int(length(pmf), size = n, replace = TRUE, prob = pmf) - 1L
}
