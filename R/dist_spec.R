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
#' @param ... Additional arguments passed to methods.
#'
#' @param max_value Numeric, the maximum value to allow.
#' Samples outside of this range are resampled.
#'
#' @param width Numeric, the width of each discrete bin.
#
#' @return A vector representing a probability distribution.
#' @keywords internal
#' @inheritParams bound_dist
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

#' Creates a delay distribution as the sum of two other delay distributions.
#'
#' @return A delay distribution representing the sum of the two delays
#' @param e1 The first delay distribution (of type <dist_spec>) to
#' combine.
#'
#' @param e2 The second delay distribution (of type <dist_spec>) to
#' combine.
#' @method + dist_spec
#' @export
#' @examples
#' # A fixed lognormal distribution with mean 5 and sd 1.
#' dist1 <- LogNormal(
#'   meanlog = 1.6, sdlog = 1, max = 20
#' )
#' dist1 + dist1
#'
#' # An uncertain gamma distribution with shape and rate normally distributed
#' # as Normal(3, 0.5) and Normal(2, 0.5) respectively
#' dist2 <- Gamma(
#'   shape = Normal(3, 0.5),
#'   rate = Normal(2, 0.5),
#'   max = 20
#' )
#' dist1 + dist2
`+.dist_spec` <- function(e1, e2) {
  c(e1, e2)
}

##' Compares two delay distributions
##'
##' @param e1 The first delay distribution (of type <dist_spec>) to
##' combine.
##'
##' @param e2 The second delay distribution (of type <dist_spec>) to
##' combine.
##' @method == dist_spec
##' @return TRUE or FALSE
##' @export
##' @examples
##' Fixed(1) == Normal(1, 0.5)
## nolint start: cyclocomp_linter
`==.dist_spec` <- function(e1, e2) {
  ## both must have same number of distributions
  if (ndist(e1) != ndist(e2)) {
    return(FALSE)
  }
  ## loop over constituent distributions
  for (i in seq_len(ndist(e1))) {
    ## distributions need to be the same
    if (get_distribution(e1, i) != get_distribution(e2, i)) {
      return(FALSE)
    }
    if (get_distribution(e1, i) == "nonparametric") {
      ## if nonparametric then PMFs need to be the same
      if (!identical(get_pmf(e1, i), get_pmf(e2, i))) {
        return(FALSE)
      }
    } else {
      ## if parametric then all parameters need to be the same
      params1 <- get_parameters(e1, i)
      params2 <- get_parameters(e2, i)
      for (param in names(params1)) {
        ## all parameters must be the same type
        if ((is(params1[[param]], "dist_spec") &&
          is(params2[[param]], "dist_spec")) ||
          (is.numeric(params1[[param]]) && is.numeric(params2[[param]]))) {
          ## if parameters are the same type they need to be same value
          if (!(params1[[param]] == params2[[param]])) {
            return(FALSE)
          }
        } else {
          return(FALSE)
        }
      }
    }
  }
  TRUE
}
## nolint end: cyclocomp_linter

##' @rdname equals-.dist_spec
##' @method != dist_spec
##' @export
`!=.dist_spec` <- function(e1, e2) {
  !(e1 == e2) # nolint: comparison_negation_linter
}

#' Combines multiple delay distributions for further processing
#'
#' @description
#' This combines the parameters so that they can be fed as multiple delay
#' distributions to `epinow()` or `estimate_infections()`.
#'
#' Note that distributions that already are combinations of other distributions
#' cannot be combined with other combinations of distributions.
#'
#' @param ... The delay distributions to combine
#' @importFrom cli cli_abort
#' @return Combined delay distributions (with class `<dist_spec>`)
#' @method c dist_spec
#' @export
#' @examples
#' # A fixed lognormal distribution with mean 5 and sd 1.
#' dist1 <- LogNormal(
#'   meanlog = 1.6, sdlog = 1, max = 20
#' )
#' dist1 + dist1
#'
#' # An uncertain gamma distribution with shape and rate normally distributed
#' # as Normal(3, 0.5) and Normal(2, 0.5) respectively
#' dist2 <- Gamma(
#'   shape = Normal(3, 0.5),
#'   rate = Normal(2, 0.5),
#'   max = 20
#' )
#' c(dist1, dist2)
c.dist_spec <- function(...) {
  ## process delay distributions
  dist_specs <- list(...)
  if (length(dist_specs) == 1) {
    return(dist_specs[[1]])
  }
  if (!(all(vapply(dist_specs, is, "dist_spec", FUN.VALUE = logical(1))))) {
    cli_abort(
      c(
        "!" = "All distributions must be of class {.cls dist_spec}."
      )
    )
  }
  convolutions <- vapply(
    dist_specs, is, "multi_dist_spec",
    FUN.VALUE = logical(1)
  )
  ## can only have one `multi_dist_spec`
  if (sum(convolutions) > 0) {
    if (sum(convolutions) > 1) {
      cli_abort(
        c(
          "!" = "Can't convolve convolutions with other convolutions"
        )
      )
    }
    ## preserve convolution attribute
    convolution_attributes <- attributes(dist_specs[[which(convolutions)]])
    dist_specs[!convolutions] <- lapply(dist_specs[!convolutions], list)
    dist_specs <- unlist(dist_specs, recursive = FALSE)
    attributes(dist_specs) <- convolution_attributes
  } else {
    attr(dist_specs, "class") <- c("multi_dist_spec", "dist_spec", "list")
  }

  dist_specs
}

#' Returns the mean of one or more delay distribution
#'
#' @description
#' This works out the mean of all the (parametric / nonparametric) delay
#' distributions combined in the passed <dist_spec>.
#'
#' @param x The `<dist_spec>` to use
#' @param ... Not used
#' @param ignore_uncertainty Logical; whether to ignore any uncertainty in
#'   parameters. If set to FALSE (the default) then the mean of any uncertain
#'   parameters will be returned as NA.
#' @importFrom cli cli_abort
#' @method mean dist_spec
#' @importFrom utils head
#' @export
#' @examples
#' # A fixed lognormal distribution with mean 5 and sd 1.
#' dist1 <- LogNormal(mean = 5, sd = 1, max = 20)
#' mean(dist1)
#'
#' # An uncertain gamma distribution with shape and rate normally distributed
#' # as Normal(3, 0.5) and Normal(2, 0.5) respectively
#' dist2 <- Gamma(
#'   shape = Normal(3, 0.5),
#'   rate = Normal(2, 0.5),
#'   max = 20
#' )
#' mean(dist2)
#'
#' # The mean of the sum of two distributions
#' mean(dist1 + dist2)
mean.dist_spec <- function(x, ...) {
  cli_abort(
    "Don't know how to calculate the mean of a {.val {get_distribution(x)}}
    distribution."
  )
}

#' @method mean uncertain
#' @export
mean.uncertain <- function(x, ..., ignore_uncertainty = FALSE) {
  ## an uncertain distribution has at least one prior parameter, so its mean is
  ## `NA` unless we ignore the uncertainty; then we use each parameter's mean
  ## and defer to the fixed per-type method via `NextMethod()`.
  if (!ignore_uncertainty) {
    return(NA_real_)
  }
  x$parameters <- lapply(x$parameters, mean, ignore_uncertainty = TRUE)
  NextMethod()
}

#' @method mean multi_dist_spec
#' @export
mean.multi_dist_spec <- function(x, ..., ignore_uncertainty = FALSE) {
  vapply(x, mean, ignore_uncertainty = ignore_uncertainty, numeric(1))
}


#' Returns the standard deviation of one or more delay distribution
#'
#' @name sd
#' @description
#' This works out the standard deviation of all the (parametric /
#' nonparametric) delay distributions combined in the passed <dist_spec>.
#' If any of the parameters are themselves uncertain then `NA` is returned.
#'
#' @param x The <dist_spec> to use
#' @param ... Not used
#' @return A vector of standard deviations.
#' @keywords internal
#' @export
#' @examples
#' \dontrun{
#' # A fixed lognormal distribution with mean 5 and sd 1.
#' dist1 <- LogNormal(mean = 5, sd = 1, max = 20)
#' sd(dist1)
#'
#' # A gamma distribution with mean 3 and sd 2
#' dist2 <- Gamma(mean = 3, sd = 2)
#' sd(dist2)
#'
#' # The sd of the sum of two distributions
#' sd(dist1 + dist2)
#' }
sd <- function(x, ...) {
  UseMethod("sd")
}

#' @rdname sd
#' @importFrom cli cli_abort
#' @export
sd.dist_spec <- function(x, ...) {
  cli_abort(
    "Don't know how to calculate the standard deviation of a
    {.val {get_distribution(x)}} distribution."
  )
}

#' @export
sd.uncertain <- function(x, ...) NA_real_

#' @export
sd.multi_dist_spec <- function(x, ...) {
  vapply(x, sd, numeric(1))
}
#' @export
sd.default <- function(x, ...) {
  stats::sd(x, ...)
}

#' Sample from a distribution
#'
#' @description
#' Draws random samples from a `<dist_spec>` whose parameters are fixed numbers,
#' using the base-R random-generation function for its family (e.g. [rgamma()]
#' for a gamma distribution). A discretised distribution is sampled on its
#' integer support.
#'
#' Only distributions with fixed parameters can be sampled. If any parameter is
#' itself a distribution (a prior), there is no single distribution to sample
#' from and an error is raised.
#'
#' A composite (multi-component) distribution is sampled per component, in
#' keeping with `mean()`/`sd()`, which also return one value per component. Use
#' `rowSums()` on the result to obtain samples of the combined (convolved)
#' distribution.
#'
#' @param x A `<dist_spec>`.
#' @param n The number of samples to draw.
#' @param ... Not used.
#' @return For a single distribution, a numeric vector of `n` samples. For a
#'   composite distribution of `k` components, an `n` by `k` matrix, one column
#'   of `n` samples per component (`rowSums()` gives `n` samples of the combined
#'   distribution).
#' @export
#' @examples
#' # Samples from a fixed gamma distribution
#' sample_dist(Gamma(shape = 2, rate = 1), 10)
#'
#' # Samples from a discretised distribution, drawn on its integer support
#' sample_dist(discretise(Gamma(shape = 2, rate = 1, max = 20)), 10)
#'
#' # A fixed distribution always returns the same value
#' sample_dist(Fixed(3), 5)
#'
#' # A composite: an n-by-k matrix, one column per component
#' sample_dist(Gamma(shape = 2, rate = 1) + Gamma(shape = 3, rate = 1), 10)
#' @importFrom cli cli_abort
sample_dist <- function(x, n, ...) {
  ## `n` validation is shared by every method, so it lives here in the generic.
  if (!is.numeric(n) || length(n) != 1 || !is.finite(n) || n < 0 ||
        n != trunc(n)) {
    cli_abort("{.arg n} must be a single non-negative integer.")
  }
  UseMethod("sample_dist")
}

#' @rdname sample_dist
#' @export
sample_dist.dist_spec <- function(x, n, ...) {
  cli_abort(
    "Don't know how to sample from a {.val {get_distribution(x)}} distribution."
  )
}

# Uncertain and estimated distributions carry a prior component and so cannot be
# sampled directly; the user resolves them with `fix_parameters()` first.
#' @exportS3Method
sample_dist.uncertain <- function(x, n, ...) {
  cli_abort(
    c(
      "!" = "Can only sample from a distribution with fixed parameters.",
      "i" = "Resolve the parameters first with {.fn fix_parameters}, then
      sample."
    )
  )
}

#' @exportS3Method
sample_dist.estimated <- function(x, n, ...) {
  sample_dist.uncertain(x, n, ...)
}

#' @rdname sample_dist
#' @export
sample_dist.multi_dist_spec <- function(x, n, ...) {
  ## An uncertain component errors via its own `sample_dist.uncertain()` method.
  vapply(x, sample_dist, numeric(n), n = n)
}

#' Returns the maximum of one or more delay distribution
#'
#' @description
#' This works out the maximum of all the (parametric / nonparametric) delay
#' distributions combined in the passed <dist_spec> (ignoring any uncertainty
#' in parameters)
#'
#' @param x The <dist_spec> to use
#' @param ... Not used
#' @return A vector of means.
#' @method max dist_spec
#' @export
#' @examples
#' # A fixed gamma distribution with mean 5 and sd 1.
#' dist1 <- Gamma(mean = 5, sd = 1, max = 20)
#' max(dist1)
#'
#' # An uncertain lognormal distribution with meanlog and sdlog normally
#' # distributed as Normal(3, 0.5) and Normal(2, 0.5) respectively
#' dist2 <- LogNormal(
#'   meanlog = Normal(3, 0.5),
#'   sdlog = Normal(2, 0.5),
#'   max = 20
#' )
#' max(dist2)
#'
#' # The max the sum of two distributions
#' max(dist1 + dist2)
max.dist_spec <- function(x, ...) {
  ## return fixed value before discretisation (discretise converts to
  ## nonparametric which then uses PMF length)
  if (get_distribution(x) == "fixed") {
    return(get_parameters(x)$value)
  }
  ## try to discretise (which applies cdf cutoff and max)
  x <- discretise(x, strict = FALSE)
  switch(get_distribution(x),
    nonparametric = max(x),
    ifelse(is.null(attr(x, "max")), Inf, attr(x, "max"))
  )
}

#' @export
max.multi_dist_spec <- function(x, ...) {
  vapply(x, max, numeric(1))
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
#' @export
#' @method discretise dist_spec
#' @examples
#' # A fixed gamma distribution with mean 5 and sd 1.
#' dist1 <- Gamma(mean = 5, sd = 1, max = 20)
#'
#' # An uncertain lognormal distribution with meanlog and sdlog normally
#' # distributed as Normal(3, 0.5) and Normal(2, 0.5) respectively
#' dist2 <- LogNormal(
#'   meanlog = Normal(3, 0.5),
#'   sdlog = Normal(2, 0.5),
#'   max = 20
#' )
#'
#' # The maxf the sum of two distributions
#' discretise(dist1 + dist2, strict = FALSE)
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
discretise.multi_dist_spec <- function(x, strict = TRUE, ...) {
  ret <- lapply(x, discretise, strict = strict)
  attributes(ret) <- attributes(x)
  ret
}
#' @rdname discretise
#' @export
discretize <- discretise

#' @export
collapse <- function(x, ...) {
  UseMethod("collapse")
}
#' Collapse nonparametric distributions in a <dist_spec>
#'
#' @name collapse
#' @description
#' This convolves any consecutive nonparametric distributions contained
#' in the <dist_spec>.
#' @param x A `<dist_spec>`
#' @param ... ignored
#' @return A `<dist_spec>` where consecutive nonparametric distributions
#' have been convolved
#' @importFrom cli cli_abort
#' @method collapse dist_spec
#' @export
#' @examples
#' # A fixed gamma distribution with mean 5 and sd 1.
#' dist1 <- Gamma(mean = 5, sd = 1, max = 20)
#'
#' # An uncertain lognormal distribution with meanlog and sdlog normally
#' # distributed as Normal(3, 0.5) and Normal(2, 0.5) respectively
#' dist2 <- LogNormal(
#'   meanlog = Normal(3, 0.5),
#'   sdlog = Normal(2, 0.5),
#'   max = 20
#' )
#'
#' # The maxf the sum of two distributions
#' collapse(discretise(dist1 + dist2, strict = FALSE))
collapse.dist_spec <- function(x, ...) {
  x
}
#' @method collapse multi_dist_spec
#' @export
collapse.multi_dist_spec <- function(x, ...) {
  ## get nonparametric distributions
  nonparametric <- vapply(
    seq_along(x), get_distribution,
    x = x, character(1)
  ) == "nonparametric"
  ## find consecutive nonparametric distributions
  consecutive <- rle(nonparametric)
  ids <- unique(c(1, cumsum(consecutive$lengths[-length(consecutive$lengths)])))
  ## find ids of nonparametric distributions that are collapsable
  ## (i.e. have other nonparametric distributions followign them)
  collapseable <- ids[consecutive$values & (consecutive$lengths > 1)]
  ## identify ids of distributions that follow the collapseable distributions
  next_ids <- lapply(collapseable, function(id) {
    ids[id] + seq_len(consecutive$lengths[id] - 1)
  })
  for (id in collapseable) {
    ## collapse distributions
    for (next_id in next_ids[id]) {
      x[[ids[id]]]$pmf <- stable_convolve(
        get_pmf(x[[ids[id]]]), rev(get_pmf(x[[next_id]]))
      )
    }
  }
  ## remove collapsed pmfs
  x[unlist(next_ids)] <- NULL
  ## if wev have collapsed all we turn into a single dist_spec
  if ((length(x) == 1) && is(x[[1]], "dist_spec")) x <- x[[1]]
  x
}

#' Prints the parameters of one or more delay distributions
#'
#' @description
#' This displays the parameters of the uncertain and probability mass
#' functions of fixed delay distributions combined in the passed <dist_spec>.
#' @param x The `<dist_spec>` to use
#' @param ... Not used
#' @importFrom cli cli_abort
#' @return invisible
#' @method print dist_spec
#' @export
#' @examples
#' #' # A fixed lognormal distribution with mean 5 and sd 1.
#' dist1 <- LogNormal(mean = 1.5, sd = 0.5, max = 20)
#' print(dist1)
#'
#' # An uncertain gamma distribution with shape and rate normally distributed
#' # as Normal(3, 0.5) and Normal(2, 0.5) respectively
#' dist2 <- Gamma(
#'   shape = Normal(3, 0.5), rate = Normal(2, 0.5), max = 20
#' )
#' print(dist2)
print.dist_spec <- function(x, ...) {
  print_dist_spec_indented(x, indent = 0, ...)
}
#' @keywords internal
print_dist_spec_indented <- function(x, indent, ...) {
  indent_str <- strrep(" ", indent)
  if (ndist(x) > 1) {
    cat(indent_str, "Composite distribution:\n", sep = "")
  }
  for (i in seq_len(ndist(x))) {
    if (get_distribution(x, i) == "nonparametric") {
      ## nonparametric
      cat(
        indent_str, "- nonparametric distribution\n", indent_str, "  PMF: [",
        paste(signif(get_pmf(x, i), digits = 2), collapse = " "), "]\n",
        sep = ""
      )
    } else if (get_distribution(x, i) == "fixed") {
      ## fixed
      cat(indent_str, "- fixed value:\n", sep = "")
      if (is.numeric(get_parameters(x, i)$value)) {
        cat(indent_str, "  ", get_parameters(x, i)$value, "\n", sep = "")
      } else {
        print_dist_spec_indented(
          get_parameters(x, i)$value, indent = indent + 4
        )
      }
    } else {
      ## parametric
      cat(indent_str, "- ", get_distribution(x, i), " distribution", sep = "")
      single_dist <- extract_single_dist(x, i)
      constrain_str <- character(0)
      if (!is.null(attr(single_dist, "max")) &&
            is.finite(attr(single_dist, "max"))) {
        constrain_str["max"] <- paste("max:", max(single_dist))
      }
      if (!is.null(attr(single_dist, "cdf_cutoff"))) {
        constrain_str["cdf_cutoff"] <-
          paste("cdf_cutoff:", attr(single_dist, "cdf_cutoff"))
      }
      if (length(constrain_str) > 0) {
        cat(" (", toString(constrain_str), ")", sep = "")
      }
      cat(":\n")
      ## loop over natural parameters and print
      for (param in names(get_parameters(x, i))) {
        cat(
          indent_str, "  ", param, ":\n",
          sep = ""
        )
        if (is.numeric(get_parameters(x, i)[[param]])) {
          cat(
            indent_str, "    ",
            signif(get_parameters(x, i)[[param]], digits = 2), "\n",
            sep = ""
          )
        } else {
          print_dist_spec_indented(
            get_parameters(x, i)[[param]], indent = indent + 4
          )
        }
      }
    }
  }
}

#' Plot PMF and CDF for a dist_spec object
#'
#' @description
#' This function takes a `<dist_spec>` object and plots its probability mass
#' function (PMF) and cumulative distribution function (CDF) using `{ggplot2}`.
#'
#' @param x A `<dist_spec>` object
#' @param samples Integer; Number of samples to generate for distributions
#' with uncertain parameters (default: 50).
#' @param res Numeric; Resolution of the PMF and CDF (default: 1, i.e. integer
#'   discretisation).
#' @param cumulative Logical; whether to plot the cumulative distribution in
#'   addition to the probability mass function
#' @param ... ignored
#' @importFrom ggplot2 aes ggplot geom_col geom_line geom_step facet_wrap vars
#' theme_bw scale_color_brewer labs
#' @importFrom stats ave
#' @importFrom rlang .data
#' @importFrom cli cli_abort
#' @export
#' @examples
#' # A fixed lognormal distribution with mean 5 and sd 1.
#' dist1 <- LogNormal(mean = 1.6, sd = 0.5, max = 20)
#' # Plot discretised distribution with 1 day discretisation window
#' plot(dist1)
#' # Plot discretised distribution with 0.01 day discretisation window
#' plot(dist1, res = 0.01, cumulative = FALSE)
#'
#' # An uncertain gamma distribution with shape and rate normally distributed
#' # as Normal(3, 0.5) and Normal(2, 0.5) respectively
#' dist2 <- Gamma(
#'   shape = Normal(3, 0.5),
#'   rate = Normal(2, 0.5),
#'   max = 20
#' )
#' plot(dist2)
#'
#' # Multiple distributions with 0.1 discretisation window and do not plot the
#' # cumulative distribution
#' plot(dist1 + dist2, res = 0.1, cumulative = FALSE)
plot.dist_spec <- function(x, samples = 50L, res = 1, cumulative = TRUE, ...) {
  # Get the PMF and CDF data
  pmf_data <- lapply(seq_len(ndist(x)), function(i) {
    if (get_distribution(x, i) == "nonparametric") {
      pmf_dt <- nonparametric_pmf_data(x, i, samples)
    } else {
      # parametric
      uncertain <- vapply(get_parameters(x, i), function(y) {
        if (is.numeric(y)) {
          return(FALSE)
        }
        sd_dist <- sd(y)
        is.na(sd_dist) || sd_dist > 0
      }, logical(1))
      if (!any(uncertain)) {
        samples <- 1 ## only need 1 sample if fixed
      }
      dists <- lapply(seq_len(samples), function(y) {
        fix_parameters(extract_single_dist(x, i), strategy = "sample")
      })
      cdf_cutoff <- attr(x, "cdf_cutoff")
      if (is.null(cdf_cutoff)) {
        cdf_cutoff <- 0
      }
      pmf_dt <- lapply(dists, function(y) {
        if (is.infinite(max(y))) {
          cli_abort(
            c(
              "!" = "All distributions in {.var x} must have a finite
              maximum value.",
              "i" = "You can set a finite maximum or CDF cutoff
              when defining the distribution."
            )
          )
        }
        x <- discrete_pmf(
          y,
          max_value = attr(y, "max"), cdf_cutoff = cdf_cutoff, width = res
        )
        data.frame(x = (seq_along(x) - 1) * res, p = x)
      })
      pmf_dt <- do.call(rbind, Map(function(dt, s) {
        dt$sample <- s
        dt
      }, pmf_dt, seq_along(pmf_dt)))

      dist_name <- paste0(
        ifelse(any(uncertain), "Uncertain ", ""),
        get_distribution(x, i), " (ID: ", i, ")"
      )
      pmf_dt$distribution <- dist_name
    }
    pmf_dt
  })
  pmf_data <- do.call(rbind, pmf_data)
  pmf_data$type <- factor("pmf", levels = c("pmf", "cmf"))
  pmf_data$distribution <- factor(
    pmf_data$distribution, levels = unique(pmf_data$distribution)
  )

  # Plot PMF and CDF as facets in the same plot
  p <- ggplot(
    pmf_data,
    mapping = aes(
      x = .data$x, y = .data$p, group = .data$sample, color = .data$type
    )
  ) +
    geom_line() +
    facet_wrap(vars(.data$distribution)) +
    labs(x = "x", y = "Probability") +
    scale_color_brewer(palette = "Dark2") +
    theme_bw()
  if (cumulative) {
    cmf_data <- pmf_data
    cmf_data$p <- ave(
      pmf_data$p, pmf_data$sample, pmf_data$distribution, FUN = cumsum
    )
    cmf_data$type <- factor("cmf", levels = c("pmf", "cmf"))
    p <- p +
      geom_step(data = cmf_data)
  }
  p
}

#' Extract a single element of a composite `<dist_spec>`
#'
#' @param x A composite `dist_spec` object
#' @param i The index to extract
#' @importFrom cli cli_abort
#' @return A single `dist_spec` object
#' @keywords internal
#' @examples
#' dist1 <- LogNormal(mean = 1.6, sd = 0.5, max = 20)
#'
#' # An uncertain gamma distribution with shape and rate normally distributed
#' # as Normal(3, 0.5) and Normal(2, 0.5) respectively
#' dist2 <- Gamma(
#'   shape = Normal(3, 0.5),
#'   rate = Normal(2, 0.5),
#'   max = 20
#' )
#'
#' # Multiple distributions
#' \dontrun{
#' dist <- dist1 + dist2
#' extract_single_dist(dist, 2)
#' }
extract_single_dist <- function(x, i) {
  if (i > ndist(x)) {
    cli_abort(
      c(
        "!" = "i must be less than the number of distributions.",
        "i" = "The number of distributions is {ndist(x)} whiles i is {i}."
      )
    )
  }
  if (ndist(x) == 1) {
    return(x)
  }
  x[[i]]
}

#' @export
fix_parameters <- function(x, ...) {
  UseMethod("fix_parameters")
}
#' Fix the parameters of a `<dist_spec>`
#'
#' @name fix_parameters
#' @description
#' If the given `<dist_spec>` has any uncertainty, it is removed and the
#' corresponding distribution converted into a fixed one.
#' @return A `<dist_spec>` object without uncertainty
#' @export
#' @param x A `<dist_spec>`
#' @param strategy Character; either "mean" (use the mean estimates of the
#'   mean and standard deviation) or "sample" (randomly sample mean and
#'   standard deviation from uncertainty given in the `<dist_spec>`
#' @param ... ignored
#' @importFrom truncnorm rtruncnorm
#' @importFrom rlang arg_match
#' @method fix_parameters dist_spec
#' @examples
#' # An uncertain gamma distribution with shape and rate normally distributed
#' # as Normal(3, 0.5) and Normal(2, 0.5) respectively
#' dist <- Gamma(
#'   shape = Normal(3, 0.5),
#'   rate = Normal(2, 0.5),
#'   max = 20
#' )
#'
#' fix_parameters(dist)
fix_parameters.dist_spec <- function(x, strategy = c("mean", "sample"), ...) {
  ## match strategy argument to options
  strategy <- arg_match(strategy)

  ## Dirichlet-backed nonparametric: resolve to a fixed PMF
  if (get_distribution(x) == "nonparametric" && isTRUE(x$estimated)) {
    pmf <- if (strategy == "mean") {
      x$alpha / sum(x$alpha)
    } else {
      rdirichlet(x$alpha)
    }
    return(NonParametric(pmf = pmf))
  }
  ## fixed nonparametric or fully numeric parametric: nothing to do
  if (get_distribution(x) == "nonparametric" ||
        all(vapply(get_parameters(x), is.numeric, logical(1)))) {
    return(x)
  }
  ## apply strategy depending on choice
  if (strategy == "mean") {
    x$parameters <- lapply(get_parameters(x), mean)
  } else if (strategy == "sample") {
    lower_bound <-
      lower_bounds(x)[natural_params(x)]
    params_mean <- vapply(get_parameters(x), mean, numeric(1))
    params_sd <- vapply(get_parameters(x), sd, numeric(1))
    params_sd[is.na(params_sd)] <- 0
    sampled <- as.list(rtruncnorm(
      n = 1, a = lower_bound,
      mean = params_mean, sd = params_sd
    ))
    names(sampled) <- names(get_parameters(x))
    x$parameters <- sampled
  }
  ## the parameters are now fixed, so drop the "uncertain" marker class
  class(x) <- c(get_distribution(x), "dist_spec")
  x
}

#' @export
#' @method fix_parameters multi_dist_spec
fix_parameters.multi_dist_spec <- function(x, strategy =
                                             c("mean", "sample"), ...) {
  for (i in seq_len(ndist(x))) {
    x[[i]] <- fix_parameters(x[[i]])
  }
  x
}

#' @export
is_constrained <- function(x, ...) {
  UseMethod("is_constrained")
}
#' Check if a <dist_spec> is constrained, i.e. has a finite maximum or nonzero
#' CDF cutoff.
#'
#' @name is_constrained
#'
#' @param x A `<dist_spec>`
#' @param ... ignored
#' @return Logical; TRUE if `x` is constrained
#' @export
#' @method is_constrained dist_spec
#' @examples
#' # A fixed gamma distribution with mean 5 and sd 1.
#' dist1 <- Gamma(mean = 5, sd = 1, max = 20)
#'
#' # An uncertain lognormal distribution with meanlog and sdlog normally
#' # distributed as Normal(3, 0.5) and Normal(2, 0.5) respectively
#' dist2 <- LogNormal(
#'   meanlog = Normal(3, 0.5),
#'   sdlog = Normal(2, 0.5),
#'   max = 20
#' )
#'
#' # both distributions are constrained and therefore so is the sum
#' is_constrained(dist1 + dist2)
is_constrained.dist_spec <- function(x, ...) {
  if (get_distribution(x) %in% c("nonparametric", "fixed")) {
    return(TRUE)
  }
  cdf_cutoff <- attr(x, "cdf_cutoff")
  tol_constrained <- !is.null(cdf_cutoff) && cdf_cutoff > 0
  max_dist <- attr(x, "max")
  max_constrained <- !is.null(max_dist) && is.finite(max_dist)
  tol_constrained || max_constrained
}
#' @method is_constrained multi_dist_spec
#' @export
is_constrained.multi_dist_spec <- function(x, ...) {
  constrained <- vapply(x, is_constrained, logical(1))
  all(constrained)
}

#' @description
#' Constructors for the probability distributions supported by
#' EpiNow2 as `dist_spec` objects.
#'
#' @details
#' Probability distributions are ubiquitous in EpiNow2, usually representing
#' epidemiological delays (e.g., the generation time for delays between
#' becoming infecting and infecting others; or reporting delays)
#'
#' They are generated using functions that have a name corresponding to the
#' probability distribution that is being used. They generated `dist_spec`
#' objects that are then passed to the models underlying EpiNow2.
##
#' All parameters can be given either as fixed values (a numeric value) or as
#' uncertain values (a `dist_sepc`). If given as uncertain values, currently
#' only normally distributed parameters (generated using `Normal()`) are
#' supported.
#'
#' Each distribution has a representation in terms of "natural" parameters (the
#' ones used in stan) but can sometimes also be specified using other
#' parameters such as the mean or standard deviation of the distribution. If
#' not given as natural parameters then these will be calculated from the given
#' parameters. If they have uncertainty, this will be done by random sampling
#' from the given uncertainty and converting resulting parameters to their
#' natural representation.
#'
#' Currently available distributions are lognormal, gamma, normal, beta, fixed
#' (delta), nonparametric, and estimated nonparametric. The nonparametric
#' is a special case where the probability mass function is given directly
#' as a numeric vector. The estimated nonparametric allows the PMF to be
#' estimated during model fitting using a Dirichlet prior.
#'
#' @inheritParams stats::Lognormal
#' @param mean,sd mean and standard deviation of the distribution
#' @param ... arguments to define the limits of the distribution that will be
#' passed to [bound_dist()]
#' @return A `dist_spec` representing a distribution of the given
#' specification.
#' @export
#' @rdname Distributions
#' @name Distributions
#' @order 1
#' @examples
#' LogNormal(mean = 4, sd = 1)
#' LogNormal(mean = 4, sd = 1, max = 10)
#' # If specifying uncertain parameters, use the natural parameters
#' LogNormal(meanlog = Normal(1.5, 0.5), sdlog = 0.25, max = 10)
LogNormal <- function(meanlog, sdlog, mean, sd, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "lognormal", ...)
}

#' @inheritParams stats::GammaDist
#' @rdname Distributions
#' @title Probability distributions
#' @order 2
#' @export
#' @examples
#' Gamma(mean = 4, sd = 1)
#' Gamma(shape = 16, rate = 4)
#' Gamma(shape = Normal(16, 2), rate = Normal(4, 1))
Gamma <- function(shape, rate, scale, mean, sd, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "gamma", ...)
}

#' @rdname Distributions
#' @order 3
#' @export
#' @examples
#' Normal(mean = 4, sd = 1)
#' Normal(mean = 4, sd = 1, max = 10)
Normal <- function(mean, sd, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "normal", ...)
}

#' @rdname Distributions
#' @order 7
#' @param shape1,shape2 shape parameters of the beta distribution
#' @export
#' @examples
#' Beta(shape1 = 2, shape2 = 5)
#' Beta(mean = 0.3, sd = 0.15)
Beta <- function(shape1, shape2, mean, sd, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "beta", ...)
}

#' @inheritParams stats::Exponential
#' @rdname Distributions
#' @order 4
#' @export
#' @examples
#' Exp(rate = 1)
#' Exp(mean = 4)
Exp <- function(rate, mean, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "exp", ...)
}

#' @inheritParams stats::Weibull
#' @rdname Distributions
#' @order 5
#' @export
#' @examples
#' Weibull(shape = 1, scale = 1)
#' Weibull(shape = 1, scale = 1, max = 10)
#' Weibull(mean = 4, sd = 1)
Weibull <- function(shape, scale, mean, sd, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "weibull", ...)
}

#' @rdname Distributions
#' @order 6
#' @param value Value of the fixed (delta) distribution
#' @export
#' @examples
#' Fixed(value = 3)
#' Fixed(value = 3.5)
Fixed <- function(value, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "fixed")
}

#' @param pmf Probability mass of the given distribution; this is
#'   passed as either a zero-indexed numeric vector (i.e. the fist entry
#'   represents the probability mass of zero) or a `dist_spec` (e.g.
#'   generated by `Dirichlet()`). If a numeric vector is not summing to one it
#'   will be normalised to sum to one internally.
#' @rdname Distributions
#' @order 5
#' @export
#' @examples
#' NonParametric(c(0.1, 0.3, 0.2, 0.4))
#' NonParametric(c(0.1, 0.3, 0.2, 0.1, 0.1))
#'
#' # With a Dirichlet prior
#' NonParametric(pmf = Dirichlet(c(1, 1, 1, 1)))
NonParametric <- function(pmf, ...) {
  if (is.numeric(pmf)) {
    check_sparse_pmf_tail(pmf)
    pmf <- pmf / sum(pmf)
  }
  params <- list(pmf = pmf)
  new_dist_spec(params, "nonparametric", ...)
}

#' @param alpha A positive numeric vector of concentration parameters.
#' @param prior Either a numeric PMF vector (zero-indexed, i.e. the
#'   first entry represents probability mass at zero) or a
#'   `dist_spec` object. If a `dist_spec` object is provided it will
#'   be discretised and the PMF extracted. If numeric, it will be
#'   normalised to sum to one internally.
#' @param concentration A positive scalar controlling how tightly
#'   the Dirichlet prior concentrates around the supplied PMF.
#'   The Dirichlet alpha vector is computed as
#'   `alpha_i = concentration * p_i` where `p_i` is the prior PMF.
#'   Guidance on values:
#'   - `concentration = 1`: weak prior, each alpha equals the PMF
#'     value (near-uniform for roughly equal PMF entries)
#'   - `concentration = 5-20`: moderate flexibility around the
#'     reference shape
#'   - `concentration = 50+`: strong anchoring to the reference PMF
#'
#' @rdname Distributions
#' @order 6
#' @export
#' @examples
#' Dirichlet(c(1, 1, 1, 1))
#' Dirichlet(prior = c(0.1, 0.3, 0.4, 0.2), concentration = 10)
Dirichlet <- function(alpha, prior, concentration, ...) {
  if (missing(alpha)) {
    if (missing(prior) || missing(concentration)) {
      cli_abort(
        "Either {.arg alpha} or both {.arg prior} and {.arg concentration}
        must be specified."
      )
    }
    if (is(prior, "dist_spec")) {
      pmf <- get_pmf(discretise(prior))
    } else {
      pmf <- prior / sum(prior)
    }
    alpha <- concentration * pmf
  }
  params <- list(alpha = alpha)
  new_dist_spec(params, "dirichlet")
}

#' Draw a single sample from a Dirichlet
#'
#' Base R does not provide an `rdirichlet()`. We use the
#' gamma-normalisation method also used by the Stan model:
#' draw an independent `Gamma(alpha_i, 1)` per bin and rescale by
#' the segment sum. Bins with `alpha == 0` stay at zero so
#' structural zeros (e.g. the t = 0 generation-time bin) are
#' preserved.
#'
#' @references
#' Stan discourse, "Ragged array of simplexes",
#' \url{https://discourse.mc-stan.org/t/ragged-array-of-simplexes/1382/21}.
#'
#' @param alpha A non-negative numeric vector of concentration
#'   parameters.
#' @return A numeric vector the same length as `alpha`, summing
#'   to 1 over the positive-alpha entries.
#' @importFrom stats rgamma
#' @keywords internal
rdirichlet <- function(alpha) {
  positive <- alpha > 0
  pmf <- numeric(length(alpha))
  draws <- rgamma(sum(positive), alpha[positive], 1)
  pmf[positive] <- draws / sum(draws)
  pmf
}

#' Build PMF data for the nonparametric branch of `plot.dist_spec`
#'
#' For a fixed nonparametric delay returns a single row per bin
#' (the stored PMF). For a Dirichlet-backed estimated delay, draws
#' `samples` PMFs from the alpha vector via [rdirichlet()] and
#' returns one row per sample-bin pair so the calling plot can
#' render an uncertainty band.
#'
#' @param x The `<dist_spec>` being plotted.
#' @param i Index of the nonparametric component within `x`.
#' @param samples Number of PMFs to draw when alpha is present.
#' @return A `data.frame` with columns `sample`, `x`, `p`,
#'   `distribution`.
#' @keywords internal
nonparametric_pmf_data <- function(x, i, samples) {
  component <- extract_single_dist(x, i)
  alpha <- component$alpha
  if (!is.null(alpha) && any(alpha > 0)) {
    dist_name <- paste0("Nonparametric (Dirichlet) (ID: ", i, ")")
    return(do.call(rbind, lapply(seq_len(samples), function(s) {
      data.frame(
        sample = s, x = seq_along(alpha) - 1,
        p = rdirichlet(alpha), distribution = dist_name
      )
    })))
  }
  pmf <- get_pmf(x, i)
  data.frame(
    sample = 1, x = seq_along(pmf) - 1, p = pmf,
    distribution = paste0("Nonparametric (ID: ", i, ")")
  )
}

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
natural_params <- function(x) UseMethod("natural_params")

#' @exportS3Method
natural_params.default <- function(x) {
  cli::cli_abort(
    "Cannot determine natural parameters for {.val {class(x)[1]}}."
  )
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
lower_bounds <- function(x) UseMethod("lower_bounds")

#' @exportS3Method
lower_bounds.default <- function(x) {
  cli::cli_abort(
    "Cannot determine lower bounds for {.val {class(x)[1]}}."
  )
}

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
#' @export
bound_dist <- function(x, max = Inf, cdf_cutoff = 0) {
  if (!is(x, "dist_spec")) {
    cli_abort(
      c(
        "!" = "{.var x} must be of class {.cls dist_spec}.",
        "i" = "It is currently of class {.cls class(x)}."
      )
    )
  }
  ## if it is a single nonparametric distribution we apply the bounds directly
  if (ndist(x) == 1 && get_distribution(x) == "nonparametric") {
    pmf <- get_pmf(x)
    if (cdf_cutoff > 0) {
      cmf <- cumsum(pmf)
      pmf <- pmf[c(TRUE, (1 - cmf[-length(cmf)]) >= cdf_cutoff)]
    }
    if (is.finite(max) && (max + 1) > length(x$pmf)) {
      pmf <- pmf[seq(1, max + 1)]
    }
    x$pmf <- pmf / sum(pmf)
  } else {
    if (is.finite(max)) attr(x, "max") <- max
    if (cdf_cutoff > 0) attr(x, "cdf_cutoff") <- cdf_cutoff
  }
  x
}

#' Extract parameter names
#' @description
#' Internal function for extracting given parameter names of a distribution
#' from the environment. Called by `new_dist_spec`
#'
#' @param params Given parameters (obtained using `as.list(environment())`)
#' @return A character vector of parameters and their values.
#' @inheritParams natural_params
#' @importFrom cli cli_abort
#' @keywords internal
extract_params <- function(params, distribution) {
  params <- params[!vapply(params, inherits, "name", FUN.VALUE = TRUE)]
  n_params <- length(natural_params(dist_prototype(distribution)))
  if (length(params) != n_params) {
    cli_abort(
      c(
        "!" = "Exactly {n_params} parameters of the {distribution}
        distribution must be specified.",
        "i" = "You have specified {length(params)} parameters, which is not
        equal to {n_params}."
      )
    )
  }
  params
}

# Validate a fixed `value` against its lower bound. An uncertain (non-numeric)
# value is bound-checked when sampled rather than here.
validate_fixed_value <- function(value) {
  lb <- lower_bounds(dist_prototype("fixed"))[["value"]]
  if (is.numeric(value) && any(value < lb)) {
    cli_abort(
      c(
        "!" = "Parameter {.arg value} must be greater than or equal to its
        lower bound {lb}.",
        "i" = "It is currently set to less than the lower bound."
      )
    )
  }
  invisible(value)
}

#' Internal function for generating a `dist_spec` given parameters and a
#' distribution.
#'
#' @description
#' This will convert all parameters to natural parameters before generating
#' a `dist_spec`. If they have uncertainty this will be done using sampling.
#' @param params Parameters of the distribution (including `max`)
#' @inheritParams extract_params
#' @inheritParams bound_dist
#' @importFrom cli cli_abort cli_warn
#' @return A `dist_spec` of the given specification.
#' @export
#' @examples
#' new_dist_spec(
#'   params = list(mean = 2, sd = 1),
#'   distribution = "normal"
#' )
new_dist_spec <- function(params, distribution, max = Inf, cdf_cutoff = 0) {
  if (distribution == "nonparametric") {
    ## nonparametric distribution
    if (inherits(params$pmf, "dist_spec")) {
      prior_dist <- params$pmf
      ret <- list(
        pmf = mean(prior_dist),
        distribution = "nonparametric"
      )
      if (get_distribution(prior_dist) == "dirichlet") {
        ret$estimated <- TRUE
        ret$alpha <- get_parameters(prior_dist)$alpha
      }
    } else {
      ret <- list(
        pmf = params$pmf,
        distribution = "nonparametric"
      )
    }
    ret <- new_single_dist_spec(ret, "nonparametric")
  } else {
    ## extract parameters and convert all to dist_spec
    params <- extract_params(params, distribution)
    ## fixed distribution
    if (distribution == "fixed") {
      validate_fixed_value(params[["value"]])
      ret <- new_single_dist_spec(list(parameters = params), "fixed")
    } else {
      ## parametric probability distribution. Build the object first so that the
      ## per-type metadata methods can dispatch on it (there is no separate
      ## dispatch token); parameters are validated and converted in place.
      ret <- new_single_dist_spec(list(parameters = params), distribution)
      ## check bounds
      lb_all <- lower_bounds(ret)
      for (param_name in names(params)) {
        lb <- lb_all[param_name]
        if (is.numeric(params[[param_name]]) &&
              any(params[[param_name]] < lb)) {
          cli_abort(
            c(
              "!" = "Parameter {param_name} must be greater than its
              lower bound {lb}.",
              "i" = "It is currently set to less than the lower bound."
            )
          )
        }
      }

      ## convert any unnatural parameters
      unnatural_params <- setdiff(names(params), natural_params(ret))
      if (length(unnatural_params) > 0) {
        ## sample parameters if they are uncertain
        uncertain <- vapply(params, function(x) {
          if (is.numeric(x)) {
            return(FALSE)
          }
          sd_dist <- sd(x)
          is.na(sd_dist) || sd_dist > 0
        }, logical(1))
        if (any(uncertain)) {
          # nolint start: duplicate_argument_linter
          cli_warn(
            c(
              "!" = "Uncertain {distribution} distribution specified in
              terms of parameters that are not the \"natural\" parameters of
              the distribution {natural_params(ret)}.",
              "i" = "Converting using a crude and very approximate method
            that is likely to produce biased results.",
              "i" = "If possible it is preferable to specify the
            distribution directly in terms of the natural parameters."
            )
          )
          # nolint end
        }
        ## generate natural parameters
        ret$parameters <- convert_to_natural(ret)
      }
      ## convert normal with sd == 0 to fixed
      if (distribution == "normal" && is.numeric(ret$parameters$sd) &&
            ret$parameters$sd == 0) {
        validate_fixed_value(ret$parameters$mean)
        ret <- new_single_dist_spec(
          list(parameters = list(value = ret$parameters$mean)), "fixed"
        )
      }
    }
  }

  ## apply bounds
  ret <- bound_dist(ret, max, cdf_cutoff)

  ## mark uncertain / estimated distributions so the shared handlers dispatch
  mark_uncertainty(ret)
}

# Prepend a marker class to a distribution that carries a prior, so the shared
# `mean`/`sd`/`sample_dist` handlers dispatch on it: `"uncertain"` for a
# parametric distribution with a prior parameter, `"estimated"` for a
# Dirichlet-backed nonparametric. Fixed distributions get no marker.
mark_uncertainty <- function(x) {
  marker <- NULL
  if (get_distribution(x) == "nonparametric") {
    if (isTRUE(x$estimated)) {
      marker <- "estimated"
    }
  } else if (!all(vapply(x$parameters, is.numeric, logical(1)))) {
    marker <- "uncertain"
  }
  if (!is.null(marker)) {
    class(x) <- c(marker, class(x))
  }
  x
}

# Attach the type-aware class to a single `dist_spec`, subclass-first
# (`c(type, "dist_spec")`): per-type methods dispatch on the type head, and
# whole-spec methods fall through to the `"dist_spec"` tail. The type is also
# kept in the `$distribution` field for `get_distribution()`.
new_single_dist_spec <- function(ret, distribution) {
  ret$distribution <- distribution
  class(ret) <- c(distribution, "dist_spec")
  ret
}

# A minimal, parameterless `dist_spec` of a type, used only to dispatch the
# per-type metadata methods (`natural_params()`, `lower_bounds()`) before a full
# object has been constructed.
dist_prototype <- function(distribution) {
  new_single_dist_spec(list(), distribution)
}

# Per-type conversion of a distribution's parameters to its natural parameters.
# Dispatched on the distribution type; each method reads the raw parameters from
# `x$parameters`, takes their means, and returns the natural parameters as a
# named list (see e.g. `to_natural.gamma`). The shared pre/post-processing lives
# in `convert_to_natural()`.
to_natural <- function(x) UseMethod("to_natural")

#' Internal function for converting parameters to natural parameters.
#'
#' @description
#' Preprocessing before generating a `dist_spec`: converts a distribution's
#' parameters to its natural parameters via the per-type `to_natural()` method,
#' re-attaching uncertainty by sampling where parameters are uncertain.
#' @inheritParams natural_params
#' @importFrom cli cli_abort
#' @return A named list of natural parameters.
#' @keywords internal
convert_to_natural <- function(x) {
  params <- x$parameters
  ## unnatural parameter means
  ux <- lapply(params, mean)
  if (anyNA(ux)) {
    cli_abort(
      c(
        "!" = "Cannot nest uncertainty in a distributions that is not
      specified with its natural parameters.",
        "i" = "Specify the distribution in terms of its natural
      parameters if you want to nest uncertainty."
      )
    )
  }
  ## estimate relative uncertainty of parameters
  sds <- vapply(params, sd, numeric(1))
  sds[is.na(sds)] <- 0
  rel_unc <- mean(sds^2 / unlist(ux))
  ## convert the parameter means to natural parameters (per-type dispatch);
  ## drop any that could not be derived so the sort below flags them as missing
  natural <- to_natural(x)
  natural <- natural[!vapply(natural, is.null, logical(1))]
  ## sort into the canonical natural-parameter order
  natural <- natural[natural_params(x)]
  if (anyNA(names(natural))) {
    cli_abort(
      c(
        "!" = "Incompatible combination of parameters of a
      {get_distribution(x)} distribution specified: {names(params)}."
      )
    )
  }
  ## re-attach uncertainty by sampling around the natural parameters
  if (rel_unc > 0) {
    natural <- lapply(names(natural), function(param_name) {
      Normal(
        mean = natural[[param_name]],
        sd = sqrt(abs(natural[[param_name]]) * rel_unc)
      )
    })
    names(natural) <- natural_params(x)
  }
  natural
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
  get_element(x, id, "pmf")
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
ndist <- function(x) {
  if (is(x, "multi_dist_spec")) {
    length(x)
  } else {
    1L
  }
}
