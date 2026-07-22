# Dirichlet distribution
#
# A prior over the weights of a nonparametric PMF, used to specify an uncertain
# nonparametric distribution. Its mean is the vector of expected weights,
# alpha / sum(alpha). It is not discretised and has no scalar sd. Per-type
# methods read from x$parameters; see gamma.R and issue #64.

#' Dirichlet prior for a nonparametric distribution
#'
#' @description
#' A Dirichlet prior over the weights of a nonparametric probability mass
#' function, used to specify an uncertain [NonParametric()] distribution whose
#' PMF is left uncertain given the Dirichlet prior. Give either `alpha`
#' directly, or a reference `prior` PMF together with a `concentration`.
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
      check_pmf_values(prior, "prior")
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

#' @exportS3Method
natural_params.dirichlet <- function(x) "alpha"

#' @exportS3Method
lower_bounds.dirichlet <- function(x) {
  c(alpha = 0)
}

#' @method mean dirichlet
#' @export
mean.dirichlet <- function(x, ...) {
  alpha <- x$parameters$alpha
  alpha / sum(alpha)
}
