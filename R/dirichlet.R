# Dirichlet distribution
#
# A prior over the weights of a nonparametric PMF, used to specify an estimated
# nonparametric distribution. Its mean is the vector of expected weights,
# alpha / sum(alpha). It is not discretised and has no scalar sd. Per-type
# methods read from x$parameters; see gamma.R and issue #64.

#' @exportS3Method
natural_params.dirichlet <- function(x) "alpha"

#' @exportS3Method
lower_bounds.dirichlet <- function(x) {
  c(alpha = 0)
}

#' @method mean dirichlet
#' @export
mean.dirichlet <- function(x, ...) {
  alpha <- x$parameters$alpha
  alpha / sum(alpha)
}
