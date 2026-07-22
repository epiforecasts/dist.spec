# Weibull distribution
#
# Per-type methods for the Weibull distribution; see `gamma.R` and #64.

#' Weibull distribution
#'
#' @description
#' A Weibull distribution as a `<dist_spec>`, given either by its
#' `shape`/`scale` or by its `mean`/`sd`.
#'
#' @inheritParams stats::Weibull
#' @param mean,sd Mean and standard deviation of the distribution, as an
#'   alternative to `shape`/`scale`.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' Weibull(shape = 1, scale = 1)
#' Weibull(shape = 1, scale = 1, max = 10)
#' Weibull(mean = 4, sd = 1)
Weibull <- function(shape, scale, mean, sd, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "weibull", ...)
}

#' @exportS3Method
natural_params.weibull <- function(x) c("shape", "scale")

#' @exportS3Method
lower_bounds.weibull <- function(x) {
  c(shape = 0, scale = 0, mean = 0, sd = 0)
}

#' @exportS3Method
dist_cdf.weibull <- function(x) pweibull

#' @importFrom stats uniroot
#' @exportS3Method
to_natural.weibull <- function(x, ux) {
  if (all(c("mean", "sd") %in% names(ux))) {
    log_cv2_p1 <- log1p((ux$sd / ux$mean)^2)
    shape <- uniroot(
      function(k) lgamma(1 + 2 / k) - 2 * lgamma(1 + 1 / k) - log_cv2_p1,
      interval = c(0.01, 200)
    )$root
    list(shape = shape, scale = ux$mean / gamma(1 + 1 / shape))
  } else {
    list(shape = ux$shape, scale = ux$scale)
  }
}

#' @method mean weibull
#' @export
mean.weibull <- function(x, ...) {
  x$parameters$scale * gamma(1 + 1 / x$parameters$shape)
}

#' @method sd weibull
#' @export
sd.weibull <- function(x, ...) {
  shape <- x$parameters$shape
  scale <- x$parameters$scale
  scale * sqrt(gamma(1 + 2 / shape) - gamma(1 + 1 / shape)^2)
}

#' @importFrom stats rweibull
#' @exportS3Method
sample_dist.weibull <- function(x, n, ...) {
  rweibull(n, shape = x$parameters$shape, scale = x$parameters$scale)
}
