# Nonparametric distribution
#
# A nonparametric distribution is defined directly by its probability mass
# function (stored in `x$pmf`) rather than by parameters. Its summary statistics
# are computed from the PMF over the support 0, 1, 2, .... It has no
# `natural_params()`/`lower_bounds()` (it is not an estimated parametric family)
# and no `dist_cdf()` (it is already discretised). See `gamma.R` and #64.

#' Nonparametric distribution
#'
#' @description
#' A nonparametric distribution as a `<dist_spec>`, defined directly by its
#' probability mass function. The PMF can instead be left uncertain by
#' passing a [Dirichlet()] prior.
#'
#' @param pmf Probability mass function, as a zero-indexed numeric vector (the
#'   first entry is the mass at zero) or a `<dist_spec>` (e.g. from
#'   [Dirichlet()]). A numeric vector is normalised to sum to one.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' NonParametric(c(0.1, 0.3, 0.2, 0.4))
#'
#' # With a Dirichlet prior (PMF left uncertain)
#' NonParametric(pmf = Dirichlet(c(1, 1, 1, 1)))
NonParametric <- function(pmf, ...) {
  if (is.numeric(pmf)) {
    check_sparse_pmf_tail(pmf)
    pmf <- pmf / sum(pmf)
  }
  params <- list(pmf = pmf)
  new_dist_spec(params, "nonparametric", ...)
}

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
max.nonparametric <- function(x, ...) {
  ## an uncertain distribution has no PMF; its support size is the length of
  ## the Dirichlet prior it carries
  if (has_uncertainty(x)) {
    length(get_parameters(x$pmf)$alpha)
  } else {
    length(x$pmf)
  }
}

# Sample from the discrete support 0, 1, 2, ... with probabilities given by the
# PMF. `sample.int()` avoids the length-1 pitfall of `sample()`.
#' @exportS3Method
sample_dist.nonparametric <- function(x, n, ...) {
  pmf <- x$pmf
  sample.int(length(pmf), size = n, replace = TRUE, prob = pmf) - 1L
}
