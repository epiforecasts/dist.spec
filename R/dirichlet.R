# Dirichlet distribution
#
# Everything specific to the Dirichlet distribution lives here, following the
# per-distribution interface introduced for the gamma distribution (see
# `distribution.R`, `gamma.R` and #41). A Dirichlet is a prior over the weights
# of a nonparametric probability mass function; its mean is the vector of
# expected weights (`alpha / sum(alpha)`). It is not discretised (no
# `dist_cdf()`) and has no scalar `sd()`.

#' @exportS3Method
natural_params.dirichlet <- function(distribution) "alpha"

#' @exportS3Method
lower_bounds.dirichlet <- function(distribution) {
  c(alpha = 0)
}

#' @method mean dirichlet
#' @export
mean.dirichlet <- function(x, ...) {
  alpha <- x$params$alpha
  alpha / sum(alpha)
}
