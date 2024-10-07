#' Check that PMF tail is not sparse
#'
#' @description Checks if the tail of a PMF vector has more than `span`
#' consecutive values smaller than `tol` and throws a warning if so.
#' @param pmf A probability mass function vector
#' @param span The number of consecutive indices in the tail to check
#' @param tol The value which to consider the tail as sparse
#' @importFrom cli cli_warn col_blue
#'
#' @return Called for its side effects.
#' @keywords internal
check_sparse_pmf_tail <- function(pmf, span = 5, tol = 1e-6) {
  if (all(tail(pmf, span) < tol)) {
    cli_warn(
      c(
        "!" = "The PMF tail has {col_blue(span)} consecutive value{?s} smaller
        than {col_blue(tol)}.",
        "i" = "This will increase run times with very small increases in
        accuracy. Consider using the `cdf_cutoff` argument when constructing
        the distribution object, or using the `bound_dist()` function."
      ),
      .frequency = "regularly",
      .frequency_id = "sparse_pmf_tail"
    )
  }
}
