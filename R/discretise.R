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
#' the remaining PMF is renormalised to sum to one. A `cdf_cutoff` below `1`
#' additionally trims the tail, keeping the distribution only up to its
#' `cdf_cutoff` quantile.
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

  ## truncate at the `cdf_cutoff` quantile if one is set (1 = keep everything)
  if (!missing(cdf_cutoff) && cdf_cutoff < 1) {
    ## max value from the cutoff using the primarycensored quantile function
    cdf_cutoff_max <- do.call(
      primarycensored::qprimarycensored,
      c(
        list(
          p = cdf_cutoff,
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
#'   nonparametric. Extract the resulting PMF vector with [get_pmf()].
#' @seealso [collapse()] to convolve the discretised components of a composite
#'   distribution into a single PMF, and [sample_dist()] to draw random samples.
#'   The `vignette("distspec")` shows the full
#'   `get_pmf(collapse(discretise(d1 + d2)))` pipeline.
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
    cdf_cutoff <- attr(x, "cdf_cutoff") %||% 1
    dist_max <- attr(x, "max") %||% Inf
    y <- new_single_dist_spec(
      list(
        pmf = discrete_pmf(x, dist_max, cdf_cutoff, width = 1)
      ),
      "nonparametric"
    )
    preserve_attributes <- setdiff(
      names(attributes(x)), c("cdf_cutoff", "max", "names", "class")
    )
    attributes(y)[preserve_attributes] <- attributes(x)[preserve_attributes]
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
#' Set the bounds that constrain a distribution when it is discretised: `max`
#' truncates the support at that value, while `cdf_cutoff` trims the tail by
#' keeping the distribution only up to its `cdf_cutoff` quantile. Either bound
#' drops the mass beyond it and renormalises the remaining PMF to sum to one.
#' @param x A `<dist_spec>`.
#' @param max Numeric, maximum value of the distribution. The distribution will
#' be truncated at this value. Default: `Inf`, i.e. no maximum.
#' @param cdf_cutoff Numeric in `(0, 1]`; the cumulative probability up to which
#' the distribution is kept, i.e. it is truncated at the `cdf_cutoff` quantile.
#' For example `cdf_cutoff = 0.999` keeps the distribution up to its 99.9th
#' percentile. Default: `1`, i.e. keep the full distribution. A value below
#' `0.5` is rejected, as it is almost certainly the tail probability to *drop*
#' rather than the CDF level to keep (use `1 - x` instead).
#' @importFrom cli cli_abort
#' @importFrom rlang `%||%`
#' @return a `<dist_spec>` with relevant attributes set that define its bounds
#' @seealso [discretise()], which applies these bounds when producing a PMF.
#' @export
#' @examples
#' # Truncate a gamma distribution at 20
#' bound_dist(Gamma(mean = 5, sd = 1), max = 20)
#' # Keep it up to its 99.9th percentile
#' bound_dist(Gamma(mean = 5, sd = 1), cdf_cutoff = 0.999)
bound_dist <- function(x, max = Inf, cdf_cutoff = 1) {
  if (!is(x, "dist_spec")) {
    cli_abort(
      c(
        "!" = "{.var x} must be of class {.cls dist_spec}.",
        "i" = "It is currently of class {.cls class(x)}."
      )
    )
  }
  ## `cdf_cutoff` is the cumulative probability to keep up to (1 = keep the full
  ## distribution); guard against the tail-probability-to-drop convention
  if (!is.numeric(cdf_cutoff) || length(cdf_cutoff) != 1 ||
        cdf_cutoff <= 0 || cdf_cutoff > 1) {
    cli_abort(
      c(
        "!" = "{.arg cdf_cutoff} must be a single number in `(0, 1]`.",
        "i" = "It is the cumulative probability to keep up to (e.g.
        {.val {0.999}}); `1` keeps the full distribution."
      )
    )
  }
  if (cdf_cutoff < 0.5) {
    cli_abort(
      c(
        "!" = "{.arg cdf_cutoff} = {cdf_cutoff} would keep less than half of the
        distribution.",
        "i" = "{.arg cdf_cutoff} is the CDF level to keep up to (e.g.
        {.val {0.999}}). Did you mean {.code cdf_cutoff = {1 - cdf_cutoff}}?"
      )
    )
  }
  ## an uncertain nonparametric has no concrete PMF to bound, and its support is
  ## fixed by the Dirichlet prior, so reject bounds rather than silently
  ## dropping them (`discretise()` would never apply them)
  if (ndist(x) == 1 && get_distribution(x) == "nonparametric" &&
        has_uncertainty(x) && (cdf_cutoff < 1 || is.finite(max))) {
    cli_abort(
      c(
        "!" = "Can't apply {.arg max} or {.arg cdf_cutoff} to an uncertain
        nonparametric distribution.",
        "i" = "Its support is set by the {.fn Dirichlet} prior; choose the
        number of bins there, or resolve it with {.fn fix_parameters} first."
      )
    )
  }
  ## if it is a single fixed-PMF nonparametric distribution we apply the bounds
  ## directly; an uncertain one has no PMF, so it keeps the attribute-based path
  if (ndist(x) == 1 && get_distribution(x) == "nonparametric" &&
        !has_uncertainty(x)) {
    pmf <- get_pmf(x)
    if (cdf_cutoff < 1) {
      cmf <- cumsum(pmf)
      pmf <- pmf[c(TRUE, cmf[-length(cmf)] <= cdf_cutoff)]
    }
    if (is.finite(max) && length(pmf) > (max + 1)) {
      pmf <- pmf[seq_len(max + 1)]
    }
    x$pmf <- pmf / sum(pmf)
  } else {
    if (is.finite(max)) attr(x, "max") <- max
    if (cdf_cutoff < 1) attr(x, "cdf_cutoff") <- cdf_cutoff
  }
  x
}
