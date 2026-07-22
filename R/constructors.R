# User-facing distribution constructors (LogNormal, Gamma, ...) and the shared
# machinery that builds and validates <dist_spec> objects from parameters.

#' Probability distributions
#'
#' @description
#' distspec represents probability distributions (typically epidemiological
#' delays, such as generation times or reporting delays) as `<dist_spec>`
#' objects. Each supported distribution has its own constructor: [LogNormal()],
#' [Gamma()], [Normal()], [Exponential()], [Weibull()], [Beta()], [Fixed()],
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
#' (propagating any uncertainty with a first-order delta-method approximation).
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
#' Exponential(rate = 1)
#' Exponential(mean = 4)
Exponential <- function(rate, mean, ...) {
  params <- as.list(environment())
  new_dist_spec(params, "exp", ...)
}

#' @rdname Exponential
#' @export
Exp <- function(...) {
  lifecycle::deprecate_warn("0.1.0", "Exp()", "Exponential()")
  Exponential(...)
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
#' probability mass function. The PMF can instead be left uncertain by
#' passing a [Dirichlet()] prior.
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
#' # With a Dirichlet prior (PMF left uncertain)
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
#' function, used to specify an uncertain [NonParametric()] distribution whose
#' PMF is left uncertain given the Dirichlet prior. Give either `alpha`
#' directly, or a
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
  params <- Filter(Negate(is.name), params)
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
#' a `dist_spec`. If they are uncertain the uncertainty is propagated to the
#' natural parameters with a first-order (delta-method) approximation (see
#' [convert_to_natural()]).
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
new_dist_spec <- function(params, distribution, max = Inf, cdf_cutoff = 1) {
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
      ## a parameter given as a certain distribution (standard deviation 0, e.g.
      ## `Normal(x, 0)`, which collapses to `Fixed(x)`) carries no uncertainty,
      ## so resolve it to its point value; it then behaves exactly like passing
      ## the number, and only genuine (sd > 0 / unknown) priors are kept
      params <- lapply(params, function(p) {
        if (is.numeric(p)) {
          return(p)
        }
        p_sd <- sd(p)
        if (!is.na(p_sd) && p_sd == 0) mean(p) else p
      })
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
        ## warn if any parameter carries genuine uncertainty
        if (has_uncertainty(ret)) {
          np <- natural_params(ret)
          # used inside the cli glue string below (object_usage_linter does not
          # see the interpolation)
          example <- paste0( # nolint: object_usage_linter
            constructor_name(distribution), "(",
            paste0(np, " = Normal(...)", collapse = ", "), ")"
          )
          # nolint start: duplicate_argument_linter
          cli_warn(
            c(
              "!" = "Uncertain {distribution} distribution specified in terms
              of parameters other than its natural parameters
              ({.arg {np}}).",
              "i" = "Propagating the uncertainty to {.arg {np}} with a
              first-order (delta-method) approximation. This assumes the
              parameter uncertainty is small and treats the resulting natural
              parameters as independent, so their correlation is not
              represented.",
              "i" = "To avoid the approximation, specify the distribution
              directly in terms of its natural parameters, e.g.
              {.code {example}}."
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
# a prior parameter, or an uncertain Dirichlet-backed nonparametric). This is
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

# Map a distribution type to the name of its user-facing constructor, used to
# suggest the natural-parameter specification in messages.
constructor_name <- function(distribution) {
  names <- c(
    lognormal = "LogNormal", gamma = "Gamma", normal = "Normal",
    beta = "Beta", exp = "Exponential", weibull = "Weibull"
  )
  if (distribution %in% names(names)) names[[distribution]] else distribution
}

#' Convert a distribution's parameters to its natural parameters (per-type)
#'
#' @description
#' Per-type conversion of a distribution's parameters to its natural parameters.
#' Dispatched on the distribution type; each method reads the parameter means
#' from `ux` and returns the natural parameters as a named list (see e.g.
#' `to_natural.gamma`). The shared pre- and post-processing lives in
#' [convert_to_natural()], which computes `ux` once and passes it in.
#'
#' @param x A single `<dist_spec>`.
#' @param ux The parameter means, as returned by `lapply(x$parameters, mean)`.
#' @return A named list of natural parameters.
#' @keywords internal
to_natural <- function(x, ux) UseMethod("to_natural")

#' Internal function for converting parameters to natural parameters.
#'
#' @description
#' Preprocessing before generating a `dist_spec`: converts a distribution's
#' parameters to its natural parameters via the per-type `to_natural()` method,
#' re-attaching uncertainty where parameters are uncertain.
#'
#' When any of the supplied parameters are uncertain the uncertainty is
#' propagated to the natural parameters using a first-order (delta-method)
#' approximation. The uncertain parameters are treated as independent normals;
#' the natural parameters are evaluated at their means and their variances are
#' obtained from the Jacobian of the transformation, computed by central finite
#' differences. Each natural parameter is returned as a [Normal()] with that
#' mean and standard deviation.
#'
#' @section Residual limitation:
#' The delta method represents each natural parameter's marginal uncertainty but
#' discards the correlation between natural parameters induced by the shared
#' unnatural parameters (for example, `shape` and `rate` of a gamma both depend
#' on the uncertain `mean`). Specify the distribution directly in terms of its
#' natural parameters when that correlation matters.
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
  ## standard deviations of the (independent) uncertain parameters; fixed
  ## parameters have zero uncertainty
  sds <- vapply(params, sd, numeric(1))
  sds[is.na(sds)] <- 0
  ## convert the parameter means to natural parameters (per-type dispatch);
  ## drop any that could not be derived so the sort below flags them as missing
  natural <- to_natural(x, ux)
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
  ## no uncertainty: keep the natural parameters numeric, exactly as when they
  ## are specified directly
  if (all(sds == 0)) {
    return(natural)
  }
  ## propagate the parameter uncertainty to the natural parameters using a
  ## first-order (delta-method) approximation. The Jacobian of the map from the
  ## unnatural to the natural parameters is estimated by central finite
  ## differences, so this works uniformly for every distribution type (including
  ## the Weibull, whose `to_natural()` solves for the shape numerically).
  natural_sd <- delta_method_sd(x, sds, natural)
  natural <- lapply(names(natural), function(param_name) {
    if (natural_sd[[param_name]] > 0) {
      Normal(mean = natural[[param_name]], sd = natural_sd[[param_name]])
    } else {
      natural[[param_name]]
    }
  })
  names(natural) <- natural_params(x)
  natural
}

#' Delta-method standard deviations of the natural parameters
#'
#' @description
#' First-order (delta-method) standard deviations of a distribution's natural
#' parameters, propagated from uncertain unnatural parameters. The uncertain
#' unnatural parameters are treated as independent normals with standard
#' deviations `sds`, and for each natural parameter the propagated standard
#' deviation is `sqrt(sum_i J[j, i]^2 * sds[i]^2)`, where the Jacobian
#' `J[j, i] = d(natural_j) / d(param_i)` is estimated by central finite
#' differences. Estimating the Jacobian numerically lets this work uniformly for
#' every distribution type, including the Weibull, whose [to_natural()] solves
#' for the shape numerically.
#'
#' @param x A single `<dist_spec>` whose parameters are the unnatural parameters
#'   evaluated at their means.
#' @param sds Numeric; the standard deviation of each unnatural parameter, in
#'   `names(x$parameters)` order (`0` for a fixed parameter).
#' @param natural The natural-parameter list evaluated at the means.
#' @param h_rel Numeric; the relative step of the central finite difference. For
#'   parameter `i` the step is `h_rel * max(abs(mean_i), 1)`, i.e. relative to
#'   the parameter value with an absolute floor near zero. The default `1e-4`
#'   keeps both the truncation error (order `h^2`) and the floating-point
#'   cancellation error (order `eps / h`) small for the smooth [to_natural()]
#'   maps. It is a numerical-differentiation constant exposed here for testing,
#'   deliberately kept off the user-facing constructors.
#' @return A named numeric vector of standard deviations, one per natural
#'   parameter.
#' @keywords internal
delta_method_sd <- function(x, sds, natural, h_rel = 1e-4) {
  param_names <- names(x$parameters)
  natural_names <- natural_params(x)
  means <- vapply(x$parameters, mean, numeric(1))
  ## map a numeric vector of unnatural parameters to the natural-parameter
  ## vector (in canonical order) via the per-type `to_natural()` method
  to_natural_vec <- function(values) {
    ux <- as.list(stats::setNames(values, param_names))
    tmp <- x
    tmp$parameters <- ux
    unlist(to_natural(tmp, ux)[natural_names])
  }
  variances <- stats::setNames(numeric(length(natural_names)), natural_names)
  for (i in seq_along(param_names)) {
    if (sds[i] == 0) next
    h <- h_rel * max(abs(means[i]), 1)
    up <- means
    up[i] <- up[i] + h
    down <- means
    down[i] <- down[i] - h
    jac_col <- (to_natural_vec(up) - to_natural_vec(down)) / (2 * h)
    variances <- variances + (jac_col * sds[i])^2
  }
  sqrt(variances)
}
