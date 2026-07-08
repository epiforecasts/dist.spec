#' Numerically stable convolution function for two pmf vectors
#'
#' Unlike [stats::convolve()], this function does not use the FFT algorithm,
#' which can generate negative numbers when below machine precision.
#'
#' @param a Numeric vector, the first sequence.
#' @param b Numeric vector, the second sequence.
#' @return A numeric vector representing the convolution of `a` and `b`.
#' @keywords internal
stable_convolve <- function(a, b) {
  n <- length(a)
  m <- length(b)
  result <- numeric(n + m - 1)
  for (i in seq_along(a)) {
    for (j in seq_along(b)) {
      result[i + j - 1] <- result[i + j - 1] + a[i] * b[m - j + 1]
    }
  }
  result
}
