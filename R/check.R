#' Check that PMF tail is not sparse
#'
#' @description Checks if the tail of a PMF vector has more than `span`
#' consecutive values smaller than `tol` and throws a warning if so.
#' @param pmf A probability mass function vector
#' @param span The number of consecutive indices in the tail to check
#' @param tol The value which to consider the tail as sparse
#' @importFrom cli cli_warn col_blue
#' @importFrom utils tail
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

#' Validate the structure of a `<dist_spec>`
#'
#' @description
#' Asserts the structural invariants of a `<dist_spec>` object: its class, the
#' shape of its parameters, and its `max`/`cdf_cutoff` attributes. Every
#' constructor validates the object it builds, so a `<dist_spec>` obtained from
#' the package is always well-formed; this is exposed so that dependent code
#' that constructs or modifies these objects can assert the same invariants.
#'
#' A composite (`multi_dist_spec`) is valid when each of its components is a
#' valid single `<dist_spec>`.
#'
#' @param x A `<dist_spec>` object.
#' @return `x`, invisibly, if it is valid; otherwise an error is raised.
#' @importFrom cli cli_abort
#' @export
#' @examples
#' validate_dist_spec(Gamma(shape = 2, rate = 1))
#' validate_dist_spec(NonParametric(c(0.1, 0.3, 0.6)))
#' validate_dist_spec(Fixed(3) + Gamma(shape = 2, rate = 1))
validate_dist_spec <- function(x) {
  if (!inherits(x, "dist_spec")) {
    cli_abort(
      c(
        "!" = "{.arg x} must be a {.cls dist_spec}.",
        "i" = "You have supplied an object of class {.cls {class(x)}}."
      )
    )
  }

  if (inherits(x, "multi_dist_spec")) {
    validate_multi_dist_spec(x)
  } else {
    validate_single_dist_spec(x)
  }

  invisible(x)
}

# Assert the invariants of a composite `<dist_spec>`: it is a list whose
# components are each a valid single (non-composite) `<dist_spec>`.
validate_multi_dist_spec <- function(x) {
  if (!is.list(x)) {
    cli_abort(
      "A {.cls multi_dist_spec} must be a list of component distributions."
    )
  }
  for (i in seq_along(x)) {
    component <- x[[i]]
    if (inherits(component, "multi_dist_spec")) {
      cli_abort(
        "Component {i} of a {.cls multi_dist_spec} must itself be a single
        {.cls dist_spec}, not a composite."
      )
    }
    if (!inherits(component, "dist_spec")) {
      cli_abort(
        c(
          "!" = "Component {i} of a {.cls multi_dist_spec} must be a
          {.cls dist_spec}.",
          "i" = "It has class {.cls {class(component)}}."
        )
      )
    }
    validate_single_dist_spec(component)
  }
  invisible(x)
}

# Assert the invariants of a single (non-composite) `<dist_spec>`.
validate_single_dist_spec <- function(x) {
  distribution <- x$distribution
  if (!is.character(distribution) || length(distribution) != 1 ||
        is.na(distribution) || !nzchar(distribution)) {
    cli_abort(
      "The {.field distribution} of a {.cls dist_spec} must be a single
      non-empty string."
    )
  }

  ## the object carries a type class (its `$distribution`) followed by the
  ## `"dist_spec"` tail, optionally with markers (such as the uncertainty
  ## marker) prepended. The type class is therefore the one immediately before
  ## `"dist_spec"`, which must equal `$distribution`; this validates the match
  ## without hard-coding any marker name
  obj_classes <- class(x)
  type_class <- obj_classes[match("dist_spec", obj_classes) - 1L]
  if (length(type_class) == 0 || is.na(type_class) ||
        !identical(type_class, distribution)) {
    cli_abort(
      c(
        "!" = "The {.field distribution} of a {.cls dist_spec} must match its
        type class.",
        "i" = "The distribution is {.val {distribution}} but the leading type
        class is {.val {type_class}}."
      )
    )
  }

  ## a nonparametric distribution stores its PMF in `$pmf`; every other type
  ## stores a named parameter list in `$parameters`
  if (!is.null(x$parameters)) {
    if (!is.list(x$parameters) || is.null(names(x$parameters)) ||
          any(!nzchar(names(x$parameters)))) {
      cli_abort(
        "The {.field parameters} of a {.cls dist_spec} must be a named list."
      )
    }
  }

  validate_dist_bounds(x)

  invisible(x)
}

# Assert the `max` and `cdf_cutoff` attributes of a single `<dist_spec>`, if
# present.
validate_dist_bounds <- function(x) {
  max_value <- attr(x, "max")
  if (!is.null(max_value)) {
    if (!is.numeric(max_value) || length(max_value) != 1 || is.na(max_value) ||
          max_value < 0) {
      cli_abort(
        "The {.field max} attribute of a {.cls dist_spec} must be a single
        numeric that is non-negative or {.val {Inf}}."
      )
    }
  }

  cdf_cutoff <- attr(x, "cdf_cutoff")
  if (!is.null(cdf_cutoff)) {
    if (!is.numeric(cdf_cutoff) || length(cdf_cutoff) != 1 ||
          is.na(cdf_cutoff) || cdf_cutoff <= 0 || cdf_cutoff > 1) {
      cli_abort(
        "The {.field cdf_cutoff} attribute of a {.cls dist_spec} must be a
        single numeric in {.code (0, 1]}."
      )
    }
  }

  invisible(x)
}
