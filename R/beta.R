# Beta distribution
#
# Everything specific to the beta distribution lives here, following the
# per-distribution interface introduced for the gamma distribution (see
# `distribution.R`, `gamma.R` and #41). The beta distribution is not
# discretised, so it provides no `dist_cdf()` method.

#' @exportS3Method
natural_params.beta <- function(distribution) c("shape1", "shape2")

#' @exportS3Method
lower_bounds.beta <- function(distribution) {
  c(shape1 = 0, shape2 = 0, mean = 0, sd = 0)
}

#' @method mean beta
#' @export
mean.beta <- function(x, ...) {
  x$params$shape1 / (x$params$shape1 + x$params$shape2)
}

#' @method sd beta
#' @export
sd.beta <- function(x, ...) {
  a <- x$params$shape1
  b <- x$params$shape2
  sqrt(a * b / ((a + b)^2 * (a + b + 1)))
}
