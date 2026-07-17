# Accessors and metadata generics for <dist_spec> objects: extracting
# parameters, PMFs, distribution type and count, and natural-parameter metadata.

#' Get the names of the natural parameters of a distribution
#'
#' @description
#' These are the parameters used in the stan models. All other parameter
#' representations are converted to these using [convert_to_natural()] before
#' being passed to the stan models.
#' @param x A `<dist_spec>`.
#' @return A character vector, the natural parameters.
#' @keywords internal
#' @export
#' @examples
#' natural_params(Gamma(shape = 1, rate = 1))
#' # a distribution type can also be given by name
#' natural_params("gamma")
natural_params <- function(x) UseMethod("natural_params")

#' @exportS3Method
natural_params.default <- function(x) {
  cli::cli_abort(
    "Cannot determine natural parameters for {.val {class(x)[1]}}."
  )
}

#' @exportS3Method
natural_params.character <- function(x) {
  natural_params(structure(list(), class = c(x, "dist_spec")))
}


#' Get the lower bounds of the parameters of a distribution
#'
#' @description
#' This is used to avoid sampling parameter values that have no support.
#' @return A numeric vector, the lower bounds.
#' @inheritParams natural_params
#' @keywords internal
#' @export
#' @examples
#' lower_bounds(LogNormal(meanlog = 0, sdlog = 1))
#' # a distribution type can also be given by name
#' lower_bounds("lognormal")
lower_bounds <- function(x) UseMethod("lower_bounds")

#' @exportS3Method
lower_bounds.default <- function(x) {
  cli::cli_abort(
    "Cannot determine lower bounds for {.val {class(x)[1]}}."
  )
}

#' @exportS3Method
lower_bounds.character <- function(x) {
  lower_bounds(structure(list(), class = c(x, "dist_spec")))
}

##' Extracts an element of a `<dist_spec>`
##'
##' @param x A `<dist_spec>`.
##' @param id Integer; the id of the distribution to use (if x is a composite
##' distribution). If `x` is a single distribution this is ignored and can be
##' left at its default value of `NULL`.
##' @param element The element, i.e. "parameters", "pmf" or "distribution".
##' @importFrom cli cli_abort
##' @return The id to use.
##' @keywords internal
get_element <- function(x, id = NULL, element) {
  if (!is.null(id) && id > ndist(x)) {
    cli_abort(
      c(
        "!" = "{.var id} cannot be greater than the number of distributions
      ({length(x)}).",
        "i" = "{.var id} currently has length {length(id)}."
      )
    )
  }
  if (ndist(x) > 1) {
    if (is.null(id)) {
      cli_abort(
        c(
          "!" = "{.var id} must be specified when {.var x} is a composite
          distribution."
        )
      )
    }
    x[[id]][[element]]
  } else {
    x[[element]]
  }
}

##' Get parameters of a parametric distribution
##'
##' @description
##' Generic function to extract the distribution parameters (e.g. shape and
##' rate for Gamma) from a `dist_spec` object.
##'
##' @param x A `dist_spec` object
##' @param ... Additional arguments passed to methods
##' @return A list of parameters of the distribution.
##' @export
##' @examples
##' dist <- Gamma(shape = 3, rate = 2)
##' get_parameters(dist)
get_parameters <- function(x, ...) {
  UseMethod("get_parameters")
}

##' @rdname get_parameters
##' @inheritParams get_element
##' @importFrom cli cli_abort
##' @method get_parameters dist_spec
##' @export
get_parameters.dist_spec <- function(x, id = NULL, ...) {
  if (get_distribution(x, id) == "nonparametric") {
    cli_abort(
      c(
        "!" = "To get parameters, distribution cannot not be
        \"nonparametric\".",
        "i" = "Distribution must be one of
        {col_blue(\"gamma\")}, {col_blue(\"lognormal\")},
        {col_blue(\"normal\")} or {col_blue(\"fixed\")}."
      )
    )
  }
  get_element(x, id, "parameters")
}

##' Get the probability mass function of a nonparametric distribution
##'
##' @details
##' An estimated (Dirichlet-backed) nonparametric distribution has no concrete
##' PMF, so calling `get_pmf()` on one is an error. Resolve it to a fixed PMF
##' first with [fix_parameters()] (e.g. `strategy = "mean"`).
##'
##' @inheritParams get_element
##' @return The pmf of the distribution
##' @importFrom cli cli_abort
##' @export
##' @examples
##' dist <- discretise(Gamma(shape = 3, rate = 2, max = 10))
##' get_pmf(dist)
get_pmf <- function(x, id = NULL) {
  if (!is(x, "dist_spec")) {
    cli_abort(
      c(
        "!" = "Can only get pmf of a {.cls dist_spec}.",
        "i" = "You have supplied an object of class {.cls {class(x)}}."
      )
    )
  }
  if (get_distribution(x, id) != "nonparametric") {
    cli_abort(
      c(
        "!" = "To get PMF, distribution must be \"nonparametric\"."
      )
    )
  }
  if (has_uncertainty(x, id)) {
    cli_abort(
      c(
        "!" = "An estimated distribution has no fixed probability mass
        function.",
        "i" = "Resolve it first with {.fn fix_parameters}."
      )
    )
  }
  get_element(x, id, "pmf")
}

##' Check whether a `<dist_spec>` is uncertain
##'
##' @description
##' A distribution is uncertain when it carries a prior: a parametric
##' distribution with a `<dist_spec>` (rather than numeric) parameter, or a
##' nonparametric distribution whose PMF is given by a `<dist_spec>` (a
##' [Dirichlet()] prior) rather than a numeric vector.
##'
##' @inheritParams get_element
##' @return `TRUE` if the (component) distribution is uncertain.
##' @keywords internal
##' @export
##' @examples
##' has_uncertainty(Gamma(shape = 1, rate = 1))
##' has_uncertainty(Gamma(shape = Normal(1, 0.5), rate = 1))
has_uncertainty <- function(x, id = NULL) {
  if (is.null(id)) id <- 1L
  single <- extract_single_dist(x, id)
  if (get_distribution(single) == "nonparametric") {
    inherits(single$pmf, "dist_spec")
  } else {
    !all(vapply(single$parameters, is.numeric, logical(1)))
  }
}

##' Get the distribution of a `<dist_spec>`
##'
##' @inheritParams get_element
##' @importFrom cli cli_abort
##' @return A character string naming the distribution (or "nonparametric")
##' @export
##' @examples
##' dist <- Gamma(shape = 3, rate = 2, max = 10)
##' get_distribution(dist)
get_distribution <- function(x, id = NULL) {
  if (!is(x, "dist_spec")) {
    cli_abort(
      c(
        "!" = "To get distribution of x, it must be a {.cls dist_spec}.",
        "i" = "You have supplied an object of class {.cls {class(x)}}."
      )
    )
  }
  get_element(x, id, "distribution")
}

#' Calculate the number of distributions in a `<dist_spec>`
#'
#' @param x A `<dist_spec>` object.
#' @return The number of distributions.
#' @keywords internal
#' @export
#' @examples
#' ndist(Gamma(mean = 5, sd = 1))
#' ndist(Gamma(mean = 5, sd = 1) + Exp(rate = 1))
ndist <- function(x) {
  if (is(x, "multi_dist_spec")) {
    length(x)
  } else {
    1L
  }
}
