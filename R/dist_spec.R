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
      ## an estimated distribution is compared by its Dirichlet prior, a fixed
      ## one by its PMF; the two are never equal
      d1 <- extract_single_dist(e1, i)
      d2 <- extract_single_dist(e2, i)
      est1 <- has_uncertainty(d1)
      est2 <- has_uncertainty(d2)
      if (est1 != est2) {
        return(FALSE)
      }
      same <- if (est1) {
        identical(get_parameters(d1$pmf)$alpha, get_parameters(d2$pmf)$alpha)
      } else {
        identical(get_pmf(e1, i), get_pmf(e2, i))
      }
      if (!same) {
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
          ## if parameters are the same type they need to be same value;
          ## numeric parameters may be vectors, so compare whole values
          same <- if (is(params1[[param]], "dist_spec")) {
            params1[[param]] == params2[[param]]
          } else {
            length(params1[[param]]) == length(params2[[param]]) &&
              all(params1[[param]] == params2[[param]])
          }
          if (!same) {
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
#' This combines the given distributions into a single composite `<dist_spec>`
#' holding multiple delay distributions.
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
  if (!all(vapply(dist_specs, is, "dist_spec", FUN.VALUE = logical(1)))) {
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
  n_convolutions <- sum(convolutions)
  ## can only have one `multi_dist_spec`
  if (n_convolutions > 0) {
    if (n_convolutions > 1) {
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
#' @return A numeric vector of means, one per component of the `<dist_spec>`;
#'   `NA` for any component with uncertain parameters unless
#'   `ignore_uncertainty = TRUE`.
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
mean.dist_spec <- function(x, ..., ignore_uncertainty = FALSE) {
  cli_abort(
    "Don't know how to calculate the mean of a {.val {get_distribution(x)}}
    distribution."
  )
}

#' @method mean uncertain_dist_spec
#' @importFrom cli cli_inform
#' @export
mean.uncertain_dist_spec <- function(x, ..., ignore_uncertainty = FALSE) {
  ## an uncertain distribution carries a prior, so its mean is `NA` unless we
  ## ignore the uncertainty; then we resolve it to its mean/point estimate with
  ## `fix_parameters()` and take that distribution's mean. This handles both an
  ## uncertain parametric distribution and an estimated nonparametric one.
  if (!ignore_uncertainty) {
    cli_inform(
      c(
        "Returning NA: this distribution has uncertain parameters.",
        "i" = "Use {.code mean(x, ignore_uncertainty = TRUE)} for the mean of
        the point estimates, or resolve the uncertainty first with
        {.fn fix_parameters}."
      ),
      .frequency = "regularly",
      .frequency_id = "uncertain_mean_na"
    )
    return(NA_real_)
  }
  mean(fix_parameters(x, strategy = "mean"))
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

#' @importFrom cli cli_inform
#' @export
sd.uncertain_dist_spec <- function(x, ...) {
  cli_inform(
    c(
      "Returning NA: this distribution has uncertain parameters.",
      "i" = "Resolve the uncertainty first with {.fn fix_parameters}."
    ),
    .frequency = "regularly",
    .frequency_id = "uncertain_sd_na"
  )
  NA_real_
}

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
#' @seealso [fix_parameters()] to resolve an uncertain distribution to fixed
#'   parameters before sampling, and [discretise()] to obtain a PMF instead.
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

# An uncertain distribution (including an estimated Dirichlet-backed
# nonparametric) carries a prior and so cannot be sampled directly; the user
# resolves it with `fix_parameters()` first.
#' @exportS3Method
sample_dist.uncertain_dist_spec <- function(x, n, ...) {
  cli_abort(
    c(
      "!" = "Can only sample from a distribution with fixed parameters.",
      "i" = "Resolve the parameters first with {.fn fix_parameters}, then
      sample."
    )
  )
}

#' @rdname sample_dist
#' @export
sample_dist.multi_dist_spec <- function(x, n, ...) {
  ## An uncertain component errors via its own
  ## `sample_dist.uncertain_dist_spec()` method.
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
#' @return A numeric vector of maxima, one per component.
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
    attr(x, "max") %||% Inf
  )
}

#' @export
max.multi_dist_spec <- function(x, ...) {
  vapply(x, max, numeric(1))
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
      single <- extract_single_dist(x, i)
      if (has_uncertainty(single)) {
        ## uncertain: the PMF is itself a distribution (a Dirichlet prior),
        ## shown nested just like an uncertain parametric parameter
        cat(indent_str, "- nonparametric distribution:\n", sep = "")
        cat(indent_str, "  pmf:\n", sep = "")
        print_dist_spec_indented(single$pmf, indent = indent + 4)
      } else {
        cat(
          indent_str, "- nonparametric distribution\n", indent_str, "  PMF: [",
          paste(signif(get_pmf(x, i), digits = 2), collapse = " "), "]\n",
          sep = ""
        )
      }
    } else if (get_distribution(x, i) == "fixed") {
      ## fixed
      params_i <- get_parameters(x, i)
      cat(indent_str, "- fixed value:\n", sep = "")
      if (is.numeric(params_i$value)) {
        cat(indent_str, "  ", params_i$value, "\n", sep = "")
      } else {
        print_dist_spec_indented(params_i$value, indent = indent + 4)
      }
    } else {
      ## parametric
      params_i <- get_parameters(x, i)
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
      for (param in names(params_i)) {
        cat(
          indent_str, "  ", param, ":\n",
          sep = ""
        )
        if (is.numeric(params_i[[param]])) {
          cat(
            indent_str, "    ",
            paste(signif(params_i[[param]], digits = 2), collapse = " "), "\n",
            sep = ""
          )
        } else {
          print_dist_spec_indented(params_i[[param]], indent = indent + 4)
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
#'   discretisation). This applies only to components discretised from a
#'   continuous distribution; a nonparametric component is already discretised
#'   on its integer support and is unaffected by `res`.
#' @param cumulative Logical; whether to plot the cumulative distribution in
#'   addition to the probability mass function
#' @param ... ignored
#' @details
#' A component must have a finite range to be plotted. One with no finite `max`
#' and no `cdf_cutoff` of its own raises an error; bound it first (e.g. with
#' [bound_dist()]).
#' @return A `{ggplot2}` object showing the PMF (and, if `cumulative = TRUE`,
#'   the CDF) of each component, faceted by distribution.
#' @importFrom ggplot2 aes ggplot geom_col geom_line geom_step facet_wrap vars
#' theme_bw scale_color_brewer labs
#' @importFrom stats ave
#' @importFrom rlang .data `%||%`
#' @importFrom cli cli_abort cli_warn
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
      if (res != 1) {
        cli_warn(
          c(
            "!" = "{.arg res} does not apply to nonparametric components.",
            "i" = "A nonparametric component is already discretised on its
            integer support, so this facet is drawn on integer support
            regardless of {.arg res}."
          ),
          .frequency = "regularly",
          .frequency_id = "plot_res_nonparametric"
        )
      }
      pmf_dt <- nonparametric_pmf_data(x, i, samples)
    } else {
      # parametric
      uncertain <- has_uncertainty(x, i)
      if (!uncertain) {
        samples <- 1 ## only need 1 sample if fixed
      }
      dists <- lapply(seq_len(samples), function(y) {
        fix_parameters(extract_single_dist(x, i), strategy = "sample")
      })
      cdf_cutoff <- attr(x, "cdf_cutoff") %||% 1
      pmf_dt <- lapply(dists, function(y) {
        max_value <- attr(y, "max")
        ## an unbounded component has no finite range to plot; require the user
        ## to bound it rather than picking a range silently
        if (is.infinite(max(y)) && cdf_cutoff == 1) {
          cli_abort(
            c(
              "!" = "Can't plot a {.val {get_distribution(x, i)}} distribution
              with no finite range.",
              "i" = "Set a finite {.arg max} or a {.arg cdf_cutoff} below 1
              (for example with {.fn bound_dist})."
            )
          )
        }
        pmf_args <- list(y, cdf_cutoff = cdf_cutoff, width = res)
        if (!is.null(max_value)) {
          pmf_args$max_value <- max_value
        }
        pmf <- do.call(discrete_pmf, pmf_args)
        data.frame(x = (seq_along(pmf) - 1) * res, p = pmf)
      })
      pmf_dt <- do.call(rbind, Map(function(dt, s) {
        dt$sample <- s
        dt
      }, pmf_dt, seq_along(pmf_dt)))

      dist_name <- paste0(
        ifelse(uncertain, "Uncertain ", ""),
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
#'
#' Call this before [sample_dist()] or [get_pmf()] on an uncertain
#' distribution, as neither can operate on a distribution that still carries a
#' prior.
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

  ## Dirichlet-backed nonparametric: resolve its prior to a fixed PMF
  if (get_distribution(x) == "nonparametric" && has_uncertainty(x)) {
    alpha <- get_parameters(x$pmf)$alpha
    pmf <- if (strategy == "mean") {
      alpha / sum(alpha)
    } else {
      rdirichlet(alpha)
    }
    return(NonParametric(pmf = pmf))
  }
  ## fixed nonparametric or fully numeric parametric: nothing to do
  if (!has_uncertainty(x)) {
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
  ## the parameters are now fixed, so recompute the uncertainty marker; this
  ## drops the "uncertain_dist_spec" class while leaving other class memberships
  ## intact
  mark_uncertainty(x)
}

#' @export
#' @method fix_parameters multi_dist_spec
fix_parameters.multi_dist_spec <- function(x, ...) {
  x[] <- lapply(x, fix_parameters, ...)
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
  tol_constrained <- !is.null(cdf_cutoff) && cdf_cutoff < 1
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
  alpha <- if (has_uncertainty(component)) {
    get_parameters(component$pmf)$alpha
  }
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
