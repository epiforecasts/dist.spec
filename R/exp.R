# Exponential distribution
#
# Per-type methods for the exponential distribution; see `gamma.R` and #64.

#' Exponential distribution
#'
#' @description
#' An exponential distribution as a `<dist_spec>`, given either by its `rate` or
#' by its `mean`.
#'
#' @inheritParams stats::Exponential
#' @param mean Mean of the distribution, as an alternative to `rate`.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' Exponential(rate = 1)
#' Exponential(mean = 4)
Exponential <- function(rate, mean, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "exp", ...)
}

#' @rdname Exponential
#' @export
Exp <- function(...) {
  lifecycle::deprecate_warn("0.1.0", "Exp()", "Exponential()")
  Exponential(...)
}

#' @exportS3Method
natural_params.exp <- function(x) "rate"

#' @exportS3Method
lower_bounds.exp <- function(x) {
  c(rate = 0, mean = 0)
}

#' @exportS3Method
dist_cdf.exp <- function(x) pexp

#' @exportS3Method
to_natural.exp <- function(x, ux) {
  list(rate = if ("mean" %in% names(ux)) 1 / ux$mean else ux$rate)
}

#' @method mean exp
#' @export
mean.exp <- function(x, ...) 1 / x$parameters$rate

#' @method sd exp
#' @export
sd.exp <- function(x, ...) 1 / x$parameters$rate

#' @importFrom stats rexp
#' @exportS3Method
sample_dist.exp <- function(x, n, ...) {
  rexp(n, rate = x$parameters$rate)
}
