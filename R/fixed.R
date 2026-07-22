# Fixed distribution
#
# Per-type methods for the fixed (point-mass) distribution; see `gamma.R` and
# issue #64. It discretises to a point mass via its own discrete_pmf method
# rather than through a CDF, so it has no dist_cdf method.

#' Fixed (point-mass) distribution
#'
#' @description
#' A fixed (delta) distribution as a `<dist_spec>`, placing all of its mass on a
#' single `value`.
#'
#' @param value Value of the fixed (delta) distribution.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' Fixed(value = 3)
#' Fixed(value = 3.5)
Fixed <- function(value, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "fixed")
}

# Validate a fixed `value` against its lower bound. An uncertain (non-numeric)
# value is bound-checked when sampled rather than here.
validate_fixed_value <- function(value) {
  lb <- lower_bounds(dist_prototype("fixed"))[["value"]]
  if (is.numeric(value) && any(value < lb)) {
    cli_abort(
      c(
        "!" = "Parameter {.arg value} must be greater than or equal to its
        lower bound {lb}.",
        "i" = "It is currently set to less than the lower bound."
      )
    )
  }
  invisible(value)
}

#' @exportS3Method
natural_params.fixed <- function(x) "value"

#' @exportS3Method
lower_bounds.fixed <- function(x) {
  c(value = 0)
}

#' @method mean fixed
#' @export
mean.fixed <- function(x, ...) x$parameters$value

#' @method sd fixed
#' @export
sd.fixed <- function(x, ...) 0.0

# A fixed distribution is a point mass, so every sample is the same value.
#' @exportS3Method
sample_dist.fixed <- function(x, n, ...) {
  rep(x$parameters$value, n)
}

# A fixed distribution discretises to a point mass rather than through a CDF.
# For fractional values the probability is split proportionally across the two
# adjacent intervals.
#' @exportS3Method
discrete_pmf.fixed <- function(x, max_value, ...) {
  value <- x$parameters$value
  if (missing(max_value) || is.infinite(max_value)) {
    max_value <- ceiling(value) + 1
  }
  max_value <- ceiling(max_value)
  pmf <- rep(0, max_value)
  if (value < max_value) {
    floor_v <- floor(value)
    frac <- value - floor_v
    if (frac == 0) {
      ## integer value: all mass in interval [value, value+1)
      pmf[floor_v + 1] <- 1
    } else {
      ## fractional: split between adjacent intervals
      pmf[floor_v + 1] <- 1 - frac
      if (floor_v + 2 <= max_value) {
        pmf[floor_v + 2] <- frac
      }
    }
  }
  pmf
}
