# Beta distribution
#
# Per-type methods for the beta distribution; see `gamma.R` and #64. The beta
# distribution is not discretised, so it provides no `dist_cdf()` method.

#' @exportS3Method
natural_params.beta <- function(x) c("shape1", "shape2")

#' @exportS3Method
lower_bounds.beta <- function(x) {
  c(shape1 = 0, shape2 = 0, mean = 0, sd = 0)
}

#' @importFrom cli cli_abort
#' @exportS3Method
to_natural.beta <- function(x, ux) {
  if (!all(c("mean", "sd") %in% names(ux))) {
    return(list(shape1 = ux$shape1, shape2 = ux$shape2))
  }
  if (ux$mean <= 0 || ux$mean >= 1) {
    cli_abort(
      c(
        "!" = "The mean of a beta distribution must be between 0 and 1.",
        "i" = "It is currently {ux$mean}."
      )
    )
  }
  if (ux$sd^2 >= ux$mean * (1 - ux$mean)) {
    cli_abort(
      c(
        "!" = "The variance of a beta distribution must be less than
        mean * (1 - mean).",
        "i" = "Reduce the sd below {sqrt(ux$mean * (1 - ux$mean))}."
      )
    )
  }
  common <- ux$mean * (1 - ux$mean) / ux$sd^2 - 1
  list(shape1 = ux$mean * common, shape2 = (1 - ux$mean) * common)
}

#' @method mean beta
#' @export
mean.beta <- function(x, ...) {
  x$parameters$shape1 / (x$parameters$shape1 + x$parameters$shape2)
}

#' @method sd beta
#' @export
sd.beta <- function(x, ...) {
  a <- x$parameters$shape1
  b <- x$parameters$shape2
  sqrt(a * b / ((a + b)^2 * (a + b + 1)))
}

#' @importFrom stats rbeta
#' @exportS3Method
sample_dist.beta <- function(x, n, ...) {
  rbeta(n, shape1 = x$parameters$shape1, shape2 = x$parameters$shape2)
}
