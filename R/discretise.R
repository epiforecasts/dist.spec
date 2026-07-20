# Discretisation of distributions: computing discretised PMFs from a
# <dist_spec> and setting the bounds (max / cdf_cutoff) that constrain them.

#' Discretised probability mass function
#'
#' @description
#' This function returns the probability mass function of a discretised and
#' truncated distribution defined by distribution type, maximum value and model
#' parameters.
#'
#' # Methodological details
#'
#' The probability mass function is computed using the `{primarycensored}`
#' package, which provides double censored PMF calculations. This correctly
#' represents the probability mass function of a double censored distribution
#' arising from the difference of two censored events.
#'
#' The probability mass function of the discretised probability distribution is
#'   a vector where the first entry corresponds to the integral over the (0,1]
#'   interval of the corresponding continuous distribution (probability of
#'   integer 0), the second entry corresponds to the (0,2] interval (probability
#'   mass of integer 1), the third entry corresponds to the (1, 3] interval
#'   (probability mass of integer 2), etc.
#'
#' The maximum value truncates the distribution: mass beyond it is dropped and
#' the remaining PMF is renormalised to sum to one. A non-zero CDF cutoff
#' additionally trims the tail, removing the part of the distribution beyond its
#' `1 - cdf_cutoff` quantile.
#'
#' ## Fixed distributions
#'
#' A `Fixed()` (point-mass) distribution is not discretised through a CDF but by
#' its own method: an integer value places all of the mass on that integer,
#' while a fractional value splits the mass proportionally across the two
#' adjacent integers. For example `Fixed(2.25)` places 0.75 on 2 and 0.25 on 3.
#'
#' @references
#' Charniga, K., et al. “Best practices for estimating and reporting
#'   epidemiological delay distributions of infectious diseases using public
#'   health surveillance and healthcare data”, *arXiv e-prints*, 2024.
#'   \doi{10.48550/arXiv.2405.08841}
#' Park,  S. W.,  et al.,  "Estimating epidemiological delay distributions for
#'   infectious diseases", *medRxiv*, 2024.
#'   \doi{https://doi.org/10.1101/2024.01.12.24301247}
#' Abbott S., et al., "primarycensored: Primary Event Censored Distributions",
#'   2025. \doi{10.5281/zenodo.13632839}
#'
#' @importFrom primarycensored dprimarycensored
#'
#' @param x A `<dist_spec>`. Discretisation dispatches on the distribution type:
#'   any type with a `dist_cdf()` method uses the default `.dist_spec` method,
#'   while `"fixed"` is handled as a point mass by its own method.
#'
#' @param ... Additional arguments passed to methods. The default method takes
#'   `max_value` (the maximum value to allow), `cdf_cutoff` and `width` (the
#'   width of each discrete bin).
#'
#' @return A vector representing a probability distribution.
#' @keywords internal
#' @importFrom stats pexp pgamma plnorm pnorm pweibull
#' @importFrom primarycensored qprimarycensored
discrete_pmf <- function(x, ...) {
  UseMethod("discrete_pmf")
}

#' @exportS3Method
discrete_pmf.dist_spec <- function(x, max_value, cdf_cutoff, width, ...) {
  params <- get_parameters(x)

  ## CDF function for the distribution type (a type without a `dist_cdf()`
  ## method errors via `dist_cdf.default`; the point-mass `fixed` overrides this
  ## method entirely)
  cdf <- dist_cdf(x)

  ## apply CDF cutoff if given
  if (!missing(cdf_cutoff) && cdf_cutoff > 0) {
    ## max from CDF cutoff using primarycensored quantile function
    cdf_cutoff_max <- do.call(
      primarycensored::qprimarycensored,
      c(
        list(
          p = 1 - cdf_cutoff,
          pdist = cdf,
          pwindow = width
        ),
        params
      )
    )
    if (!is.na(cdf_cutoff_max) &&
          (missing(max_value) || cdf_cutoff_max < max_value)) {
      max_value <- cdf_cutoff_max
    }
  }

  ## determine pmf using primarycensored
  max_value <- ceiling(max_value)

  ## compute double censored PMF using primarycensored
  pmf <- do.call(
    primarycensored::dprimarycensored,
    c(
      list(
        x = seq(0, max_value - width, by = width),
        pdist = cdf,
        pwindow = width,
        swindow = width,
        D = max_value
      ),
      params
    )
  )

  pmf
}

#' @export
discretise <- function(x, ...) {
  UseMethod("discretise")
}
#' Discretise a <dist_spec>
#'
#' @name discretise
#' @inherit discrete_pmf sections references
#' @param x A `<dist_spec>`
#' @param strict Logical; If `TRUE` (default) an error will be thrown if a
#' distribution cannot be discretised (e.g., because no finite maximum has been
#' specified or parameters are uncertain). If `FALSE` then any distribution
#' that cannot be discretised will be returned as is.
#' @param remove_trailing_zeros Logical; If `TRUE` (default), trailing zeroes
#'   in the resulting PMF will be removed. If `FALSE`, trailing zeroes will be
#'   retained.
#' @param ... ignored
#' @importFrom cli cli_abort
#' @return A `<dist_spec>` where all distributions with constant parameters are
#'   nonparametric.
#' @seealso [collapse()] to convolve the discretised components of a composite
#'   distribution into a single PMF, and [sample_dist()] to draw random samples.
#' @export
#' @method discretise dist_spec
#' @examples
#' # A fixed gamma distribution with mean 5 and sd 1, discretised to a PMF.
#' dist1 <- Gamma(mean = 5, sd = 1, max = 20)
#' get_pmf(discretise(dist1))
#'
#' # An uncertain lognormal distribution cannot be discretised, so with
#' # `strict = FALSE` it is returned unchanged.
#' dist2 <- LogNormal(
#'   meanlog = Normal(3, 0.5),
#'   sdlog = Normal(2, 0.5),
#'   max = 20
#' )
#' discretise(dist2, strict = FALSE)
#'
#' # A fractional fixed value splits its mass across the two adjacent integers.
#' get_pmf(discretise(Fixed(2.25)))
discretise.dist_spec <- function(x, strict = TRUE, remove_trailing_zeros = TRUE,
                                 ...) {
  ## discretise
  if (!is_constrained(x) && strict) {
    cli_abort(
      c(
        "!" = "Cannot discretise a distribution with infinite support.",
        "i" = "Either set a finite maximum or a tolerance greater than 0."
      )
    )
  }
  if (get_distribution(x) == "nonparametric") {
    return(x)
  }
  if (!is.na(sd(x)) && is_constrained(x)) {
    cdf_cutoff <- attr(x, "cdf_cutoff")
    if (is.null(cdf_cutoff)) {
      cdf_cutoff <- 0
    }
    dist_max <- attr(x, "max")
    if (is.null(dist_max)) {
      dist_max <- Inf
    }
    y <- new_single_dist_spec(
      list(
        pmf = discrete_pmf(x, dist_max, cdf_cutoff, width = 1)
      ),
      "nonparametric"
    )
    preserve_attributes <- setdiff(
      names(attributes(x)), c("cdf_cutoff", "max", "names", "class")
    )
    for (attribute in preserve_attributes) {
      attributes(y)[attribute] <- attributes(x)[attribute]
    }
    if (remove_trailing_zeros) {
      non_zero_idx <- which(y$pmf != 0)
      if (length(non_zero_idx) > 0) {
        y$pmf <- y$pmf[seq_len(max(non_zero_idx))]
      }
    }
    y
  } else if (strict) {
    cli_abort(
      c(
        "!" = "Cannot discretise a distribution with uncertain parameters."
      )
    )
  } else {
    x
  }
}
#' @method discretise multi_dist_spec
#' @export
discretise.multi_dist_spec <- function(x, ...) {
  ret <- lapply(x, discretise, ...)
  attributes(ret) <- attributes(x)
  ret
}
#' @rdname discretise
#' @export
discretize <- discretise

#' Define bounds of a `<dist_spec>`
#'
#' @description
#' This sets attributes for further processing
#' @param x A `<dist_spec>`.
#' @param max Numeric, maximum value of the distribution. The distribution will
#' be truncated at this value. Default: `Inf`, i.e. no maximum.
#' @param cdf_cutoff Numeric; the desired CDF cutoff. Any part of the
#' cumulative distribution function beyond 1 minus the value of this argument is
#' removed. Default: `0`, i.e. use the full distribution.
#' @importFrom cli cli_abort
#' @return a `<dist_spec>` with relevant attributes set that define its bounds
#' @seealso [discretise()], which applies these bounds when producing a PMF.
#' @export
#' @examples
#' # Truncate a gamma distribution at 20
#' bound_dist(Gamma(mean = 5, sd = 1), max = 20)
bound_dist <- function(x, max = Inf, cdf_cutoff = 0) {
  if (!is(x, "dist_spec")) {
    cli_abort(
      c(
        "!" = "{.var x} must be of class {.cls dist_spec}.",
        "i" = "It is currently of class {.cls class(x)}."
      )
    )
  }
  ## an estimated nonparametric has no concrete PMF to bound, and its support is
  ## fixed by the Dirichlet prior, so reject bounds rather than silently
  ## dropping them (`discretise()` would never apply them)
  if (ndist(x) == 1 && get_distribution(x) == "nonparametric" &&
        has_uncertainty(x) && (cdf_cutoff > 0 || is.finite(max))) {
    cli_abort(
      c(
        "!" = "Can't apply {.arg max} or {.arg cdf_cutoff} to an estimated
        nonparametric distribution.",
        "i" = "Its support is set by the {.fn Dirichlet} prior; choose the
        number of bins there, or resolve it with {.fn fix_parameters} first."
      )
    )
  }
  ## if it is a single fixed-PMF nonparametric distribution we apply the bounds
  ## directly; an estimated one has no PMF, so it keeps the attribute-based path
  if (ndist(x) == 1 && get_distribution(x) == "nonparametric" &&
        !has_uncertainty(x)) {
    pmf <- get_pmf(x)
    if (cdf_cutoff > 0) {
      cmf <- cumsum(pmf)
      pmf <- pmf[c(TRUE, (1 - cmf[-length(cmf)]) >= cdf_cutoff)]
    }
    if (is.finite(max) && length(pmf) > (max + 1)) {
      pmf <- pmf[seq_len(max + 1)]
    }
    x$pmf <- pmf / sum(pmf)
  } else {
    if (is.finite(max)) attr(x, "max") <- max
    if (cdf_cutoff > 0) attr(x, "cdf_cutoff") <- cdf_cutoff
  }
  x
}
