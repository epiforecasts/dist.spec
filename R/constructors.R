# The shared machinery that builds and validates <dist_spec> objects from
# parameters. The per-type constructors live in their own files (e.g. gamma.R).

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
