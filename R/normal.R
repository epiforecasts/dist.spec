# Normal distribution
#
# Per-type methods for the normal distribution; see `gamma.R` and #64.

#' Normal distribution
#'
#' @description
#' A normal distribution as a `<dist_spec>`, given by its `mean` and `sd`. Also
#' used to give an uncertain parameter of another distribution.
#'
#' @param mean,sd Mean and standard deviation of the distribution.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' Normal(mean = 4, sd = 1)
#' Normal(mean = 4, sd = 1, max = 10)
Normal <- function(mean, sd, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "normal", ...)
}

#' @exportS3Method
natural_params.normal <- function(x) c("mean", "sd")

#' @exportS3Method
lower_bounds.normal <- function(x) {
  c(mean = -Inf, sd = 0)
}

#' @exportS3Method
dist_cdf.normal <- function(x) pnorm

#' @exportS3Method
to_natural.normal <- function(x, ux) {
  list(mean = ux$mean, sd = ux$sd)
}

#' @method mean normal
#' @export
mean.normal <- function(x, ...) x$parameters$mean

#' @method sd normal
#' @export
sd.normal <- function(x, ...) x$parameters$sd

#' @importFrom stats rnorm
#' @exportS3Method
sample_dist.normal <- function(x, n, ...) {
  rnorm(n, mean = x$parameters$mean, sd = x$parameters$sd)
}
