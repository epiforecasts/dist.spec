# Fixed distribution
#
# Per-type methods for the fixed (point-mass) distribution; see `gamma.R` and
# issue #64. It discretises to a point mass via its own discrete_pmf method
# rather than through a CDF, so it has no dist_cdf method.

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
