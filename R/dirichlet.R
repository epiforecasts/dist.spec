# Dirichlet distribution
#
# Everything specific to the Dirichlet distribution lives here, following the
# per-distribution interface introduced for the gamma distribution (see
# `distribution.R`, `gamma.R` and #41). A Dirichlet is a prior over the weights
# of a nonparametric probability mass function: it is not discretised and has
# no closed-form `mean()`/`sd()`/CDF, so it provides only its parameter
# metadata (`natural_params()` and `lower_bounds()`).

#' @exportS3Method
natural_params.dirichlet <- function(distribution) "alpha"

#' @exportS3Method
lower_bounds.dirichlet <- function(distribution) {
  c(alpha = 0)
}
