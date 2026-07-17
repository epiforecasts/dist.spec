# CDF interface for discretisation
#
# `dist_cdf()` returns a distribution's cumulative distribution function (a
# base-R `p*` function such as `pgamma`), used to discretise it via
# {primarycensored}. It is an optional per-type capability: a distribution that
# is never discretised (e.g. beta, the Dirichlet prior, the already-discretised
# nonparametric) provides no method and errors informatively via
# `dist_cdf.default()`.

dist_cdf <- function(x) UseMethod("dist_cdf")

#' @exportS3Method
dist_cdf.default <- function(x) {
  cli::cli_abort(
    "{.val {class(x)[1]}} has no CDF and cannot be discretised."
  )
}
