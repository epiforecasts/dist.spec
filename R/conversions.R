#' Convert mean and sd to log mean for a log normal distribution
#'
#' @description `r lifecycle::badge("stable")`
#' Convert from mean and standard deviation to the log mean of the
#' lognormal distribution. Useful for defining distributions supported by
#' `estimate_infections()`, `epinow()`, and `regional_epinow()`.
#' @param mean Numeric, mean of a distribution
#' @param sd Numeric, standard deviation of a distribution
#'
#' @return The log mean of a lognormal distribution
#' @export
#'
#' @examples
#'
#' convert_to_logmean(2, 1)
convert_to_logmean <- function(mean, sd) {
  log(mean^2 / sqrt(sd^2 + mean^2))
}

#' Convert mean and sd to log standard deviation for a log normal distribution
#'
#' @description `r lifecycle::badge("stable")`
#' Convert from mean and standard deviation to the log standard deviation of the
#' lognormal distribution. Useful for defining distributions supported by
#' `estimate_infections()`, `epinow()`, and `regional_epinow()`.
#' @param mean Numeric, mean of a distribution
#' @param sd Numeric, standard deviation of a distribution
#'
#' @return The log standard deviation of a lognormal distribution
#' @export
#'
#' @examples
#'
#' convert_to_logsd(2, 1)
convert_to_logsd <- function(mean, sd) {
  sqrt(log(1 + (sd^2 / mean^2)))
}
