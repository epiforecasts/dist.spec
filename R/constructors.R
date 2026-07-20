# User-facing distribution constructors (LogNormal, Gamma, ...) and the shared
# machinery that builds and validates <dist_spec> objects from parameters.

#' Probability distributions
#'
#' @description
#' distspec represents probability distributions (typically epidemiological
#' delays, such as generation times or reporting delays) as `<dist_spec>`
#' objects. Each supported distribution has its own constructor: [LogNormal()],
#' [Gamma()], [Normal()], [Exp()], [Weibull()], [Beta()], [Fixed()],
#' [NonParametric()] and [Dirichlet()].
#'
#' @details
#' A parameter can be given either as a fixed numeric value or as an uncertain
#' value (another `<dist_spec>`); currently only normally distributed uncertain
#' parameters (from [Normal()]) are supported.
#'
#' Each distribution has a "natural" (canonical) parameterisation, such as
#' `shape` and `rate` for [Gamma()] or `meanlog` and `sdlog` for [LogNormal()].
#' It can sometimes also be specified using other parameters, such as its mean
#' and standard deviation, which are then converted to the natural parameters
#' (by random sampling if they are uncertain).
#'
#' @seealso [discretise()] and [collapse()] to discretise and convolve
#'   distributions, [sample_dist()] to draw samples, and [get_parameters()] /
#'   [get_pmf()] to inspect them.
#' @name Distributions
NULL

#' Lognormal distribution
#'
#' @description
#' A lognormal distribution as a `<dist_spec>`, given either by its natural
#' parameters `meanlog`/`sdlog` or by its `mean`/`sd`.
#'
#' @inheritParams stats::Lognormal
#' @param mean,sd Mean and standard deviation of the distribution, as an
#'   alternative to `meanlog`/`sdlog`.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' LogNormal(mean = 4, sd = 1)
#' LogNormal(mean = 4, sd = 1, max = 10)
#' # Uncertain parameters must be given as the natural parameters
#' LogNormal(meanlog = Normal(1.5, 0.5), sdlog = 0.25, max = 10)
LogNormal <- function(meanlog, sdlog, mean, sd, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "lognormal", ...)
}

#' Gamma distribution
#'
#' @description
#' A gamma distribution as a `<dist_spec>`, given either by its natural
#' parameters `shape`/`rate` (or `shape`/`scale`) or by its `mean`/`sd`.
#'
#' @inheritParams stats::GammaDist
#' @param mean,sd Mean and standard deviation of the distribution, as an
#'   alternative to `shape`/`rate`.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' Gamma(mean = 4, sd = 1)
#' Gamma(shape = 16, rate = 4)
#' Gamma(shape = Normal(16, 2), rate = Normal(4, 1))
Gamma <- function(shape, rate, scale, mean, sd, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "gamma", ...)
}

#' Normal distribution
#'
#' @description
#' A normal distribution as a `<dist_spec>`, given by its `mean` and `sd`. Also
#' used to give an uncertain parameter of another distribution.
#'
#' @param mean,sd Mean and standard deviation of the distribution.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' Normal(mean = 4, sd = 1)
#' Normal(mean = 4, sd = 1, max = 10)
Normal <- function(mean, sd, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "normal", ...)
}

#' Beta distribution
#'
#' @description
#' A beta distribution as a `<dist_spec>`, given either by its shape parameters
#' `shape1`/`shape2` or by its `mean`/`sd`. It is not discretised.
#'
#' @param shape1,shape2 Shape parameters of the beta distribution.
#' @param mean,sd Mean and standard deviation of the distribution, as an
#'   alternative to `shape1`/`shape2`.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' Beta(shape1 = 2, shape2 = 5)
#' Beta(mean = 0.3, sd = 0.15)
Beta <- function(shape1, shape2, mean, sd, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "beta", ...)
}

#' Exponential distribution
#'
#' @description
#' An exponential distribution as a `<dist_spec>`, given either by its `rate` or
#' by its `mean`.
#'
#' @inheritParams stats::Exponential
#' @param mean Mean of the distribution, as an alternative to `rate`.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' Exp(rate = 1)
#' Exp(mean = 4)
Exp <- function(rate, mean, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "exp", ...)
}

#' Weibull distribution
#'
#' @description
#' A Weibull distribution as a `<dist_spec>`, given either by its
#' `shape`/`scale` or by its `mean`/`sd`.
#'
#' @inheritParams stats::Weibull
#' @param mean,sd Mean and standard deviation of the distribution, as an
#'   alternative to `shape`/`scale`.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' Weibull(shape = 1, scale = 1)
#' Weibull(shape = 1, scale = 1, max = 10)
#' Weibull(mean = 4, sd = 1)
Weibull <- function(shape, scale, mean, sd, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "weibull", ...)
}

#' Fixed (point-mass) distribution
#'
#' @description
#' A fixed (delta) distribution as a `<dist_spec>`, placing all of its mass on a
#' single `value`.
#'
#' @param value Value of the fixed (delta) distribution.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' Fixed(value = 3)
#' Fixed(value = 3.5)
Fixed <- function(value, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "fixed")
}

#' Nonparametric distribution
#'
#' @description
#' A nonparametric distribution as a `<dist_spec>`, defined directly by its
#' probability mass function. The PMF can instead be estimated during model
#' fitting by passing a [Dirichlet()] prior.
#'
#' @param pmf Probability mass function, as a zero-indexed numeric vector (the
#'   first entry is the mass at zero) or a `<dist_spec>` (e.g. from
#'   [Dirichlet()]). A numeric vector is normalised to sum to one.
#' @param ... Limits of the distribution, passed to [bound_dist()].
#' @return A `<dist_spec>`.
#' @seealso [Distributions] for an overview and the other distributions.
#' @export
#' @examples
#' NonParametric(c(0.1, 0.3, 0.2, 0.4))
#'
#' # With a Dirichlet prior (estimated during model fitting)
#' NonParametric(pmf = Dirichlet(c(1, 1, 1, 1)))
NonParametric <- function(pmf, ...) {
  if (is.numeric(pmf)) {
    check_sparse_pmf_tail(pmf)
    pmf <- pmf / sum(pmf)
  }
  params <- list(pmf = pmf)
  new_dist_spec(params, "nonparametric", ...)
}

#' Dirichlet prior for a nonparametric distribution
#'
#' @description
#' A Dirichlet prior over the weights of a nonparametric probability mass
#' function, used to specify an estimated [NonParametric()] distribution whose
#' PMF is estimated during model fitting. Give either `alpha` directly, or a
#' reference `prior` PMF together with a `concentration`.
#'
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
#' @param ... Not used.
#' @return A `<dist_spec>`.
#' @seealso [NonParametric()] to use the prior, and [Distributions] for an
#'   overview.
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
#' @param distribution Character; the distribution type (e.g. `"gamma"`,
#'   `"lognormal"`, `"nonparametric"`).
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
      if (get_distribution(prior_dist) == "dirichlet") {
        ret <- list(pmf = prior_dist, distribution = "nonparametric")
      } else {
        ret <- list(pmf = mean(prior_dist), distribution = "nonparametric")
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

  ## mark uncertain distributions so the shared handlers dispatch
  mark_uncertainty(ret)
}

# Recompute the uncertainty marker class from a distribution's current
# parameters, so the shared `mean`/`sd`/`sample_dist` handlers dispatch on it:
# applied to a distribution that carries a prior (a parametric distribution with
# a prior parameter, or an estimated Dirichlet-backed nonparametric). This is
# idempotent: it strips any existing marker first (leaving other class
# memberships intact) and re-adds one only if a prior remains, so it can be
# re-run whenever the parameters change.
mark_uncertainty <- function(x) {
  class(x) <- setdiff(class(x), "uncertain")
  if (has_uncertainty(x)) {
    class(x) <- c("uncertain", class(x))
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
