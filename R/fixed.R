# Fixed distribution
#
# Everything specific to the fixed (point-mass) distribution lives here,
# following the per-distribution interface introduced for the gamma
# distribution (see `distribution.R`, `gamma.R` and #41). A fixed distribution
# is discretised by a dedicated branch in `discrete_pmf()` rather than through a
# CDF, so it provides no `dist_cdf()` method.

#' @exportS3Method
natural_params.fixed <- function(distribution) "value"

#' @exportS3Method
lower_bounds.fixed <- function(distribution) {
  c(value = 0)
}

#' @method mean fixed
#' @export
mean.fixed <- function(x, ...) x$params$value

#' @method sd fixed
#' @export
sd.fixed <- function(x, ...) 0.0

# A fixed distribution discretises to a point mass rather than through a CDF.
# For fractional values the probability is split proportionally across the two
# adjacent intervals.
#' @exportS3Method
discrete_pmf.fixed <- function(x, max_value, ...) {
  value <- x$params$value
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
