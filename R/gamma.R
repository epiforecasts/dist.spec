# Gamma distribution
#
# Everything specific to the gamma distribution. Per-type S3 methods dispatch on
# the `"gamma"` class of a `dist_spec` and read fixed parameters from
# `x$parameters`. Uncertainty, validation and discretisation are handled by the
# shared `dist_spec`/`uncertain_dist_spec` methods (see `distribution.R`,
# `dist_spec.R` and #64), so these methods are pure.

#' Gamma distribution
#'
#' @description
#' A gamma distribution as a `<dist_spec>`, given either by its natural
#' parameters `shape`/`rate` (or `shape`/`scale`) or by its `mean`/`sd`.
#'
#' @inheritParams stats::GammaDist
#' @param mean,sd Mean and standard deviation of the distribution, as an
#'   alternative to `shape`/`rate`.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' Gamma(mean = 4, sd = 1)
#' Gamma(shape = 16, rate = 4)
#' Gamma(shape = Normal(16, 2), rate = Normal(4, 1))
Gamma <- function(shape, rate, scale, mean, sd, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "gamma", ...)
}

#' @exportS3Method
natural_params.gamma <- function(x) c("shape", "rate")

#' @exportS3Method
lower_bounds.gamma <- function(x) {
  c(shape = 0, rate = 0, scale = 0, mean = 0, sd = 0)
}

#' @exportS3Method
dist_cdf.gamma <- function(x) pgamma

#' @exportS3Method
to_natural.gamma <- function(x, ux) {
  if (all(c("mean", "sd") %in% names(ux))) {
    shape <- ux$mean^2 / ux$sd^2
    list(shape = shape, rate = shape / ux$mean)
  } else {
    list(
      shape = ux$shape,
      rate = if ("scale" %in% names(ux)) 1 / ux$scale else ux$rate
    )
  }
}

#' @method mean gamma
#' @export
mean.gamma <- function(x, ...) x$parameters$shape / x$parameters$rate

#' @method sd gamma
#' @export
sd.gamma <- function(x, ...) sqrt(x$parameters$shape / x$parameters$rate^2)

#' @importFrom stats rgamma
#' @exportS3Method
sample_dist.gamma <- function(x, n, ...) {
  rgamma(n, shape = x$parameters$shape, rate = x$parameters$rate)
}
