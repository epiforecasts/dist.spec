# Changelog

## distspec 0.1.0

distspec 0.1.0 splits the `<dist_spec>` interface out of EpiNow2. The
entries below are changes relative to that code as it stood in EpiNow2
1.9.0.

### New features

- Distribution constructors now validate the structure of the object
  they build (class, parameters, and `max`/`cdf_cutoff` attributes) and
  raise an informative error if it is malformed.
- Added a [`Beta()`](https://epiforecasts.io/distspec/reference/Beta.md)
  distribution (`shape1`/`shape2`, or `mean`/`sd`).
- Added
  [`Exponential()`](https://epiforecasts.io/distspec/reference/Exponential.md)
  and
  [`Weibull()`](https://epiforecasts.io/distspec/reference/Weibull.md)
  distributions.
- Added
  [`Dirichlet()`](https://epiforecasts.io/distspec/reference/Dirichlet.md)
  and support for uncertain nonparametric distributions specified via a
  Dirichlet prior (`NonParametric(pmf = Dirichlet(...))`).
- Added
  [`sample_dist()`](https://epiforecasts.io/distspec/reference/sample_dist.md)
  to draw random samples from a distribution with fixed parameters. A
  composite distribution is sampled per component, returning an `n` by
  `k` matrix ([`rowSums()`](https://rdrr.io/r/base/colSums.html) gives
  samples of the combined distribution). Distributions with uncertain
  (prior) parameters cannot be sampled and raise an error.
- Added
  [`has_uncertainty()`](https://epiforecasts.io/distspec/reference/has_uncertainty.md),
  a predicate for whether a `<dist_spec>` (or a component of a
  composite) carries a prior, so dependent packages and internal code
  can test for uncertainty in one place.
- Uncertainty in a distribution specified with non-natural parameters
  (e.g. `Gamma(mean = Normal(4, 0.5), sd = 1)`) is now propagated to the
  natural parameters with a first-order delta-method approximation. This
  replaces an ad-hoc rule that understated the natural-parameter
  standard deviations several times over.
- [`discretise()`](https://epiforecasts.io/distspec/reference/discretise.md)
  gains a `remove_trailing_zeros` argument (default `TRUE`).
- Exported the lower-level helpers
  [`sd()`](https://epiforecasts.io/distspec/reference/sd.md),
  [`ndist()`](https://epiforecasts.io/distspec/reference/ndist.md),
  [`natural_params()`](https://epiforecasts.io/distspec/reference/natural_params.md)
  and
  [`lower_bounds()`](https://epiforecasts.io/distspec/reference/lower_bounds.md)
  so that dependent packages can reuse them.
- [`natural_params()`](https://epiforecasts.io/distspec/reference/natural_params.md)
  and
  [`lower_bounds()`](https://epiforecasts.io/distspec/reference/lower_bounds.md)
  accept a distribution type given by name
  (e.g. `natural_params("gamma")`), as well as a `<dist_spec>`, so
  dependent packages can query type metadata without constructing an
  instance.

### Breaking changes

- The package has been renamed from `dist.spec` to `distspec`.
- A distribution’s type is now carried in the S3 class of its
  `<dist_spec>` (e.g. `c("gamma", "dist_spec")`), so per-type behaviour
  dispatches directly and each distribution’s methods live in one place.
  The internal `distribution` dispatch class and `new_dist()` have been
  removed. The internal helpers
  [`natural_params()`](https://epiforecasts.io/distspec/reference/natural_params.md)
  and
  [`lower_bounds()`](https://epiforecasts.io/distspec/reference/lower_bounds.md)
  now take a `<dist_spec>` rather than a distribution-name string.
- [`get_parameters()`](https://epiforecasts.io/distspec/reference/get_parameters.md)
  is now an S3 generic.
- The `cdf_cutoff` argument (on the distribution constructors and
  [`bound_dist()`](https://epiforecasts.io/distspec/reference/bound_dist.md))
  is the cumulative probability to keep up to: `cdf_cutoff = 0.999`
  truncates at the 99.9th percentile, and the default `1` keeps the full
  distribution. A value below `0.5` is rejected, as it is almost
  certainly the tail probability to drop (use `1 - x`).

### Deprecations

- [`Exp()`](https://epiforecasts.io/distspec/reference/Exponential.md)
  is deprecated in favour of
  [`Exponential()`](https://epiforecasts.io/distspec/reference/Exponential.md).

### Bug fixes

- [`NonParametric()`](https://epiforecasts.io/distspec/reference/NonParametric.md)
  and `Dirichlet(prior = )` now reject a numeric PMF or weight vector
  that contains negative or non-finite values, or is all zero, with an
  informative error, instead of silently producing an invalid
  distribution. Un-normalised non-negative weights are still accepted
  and normalised.
- A distribution parameter given as a certain distribution (standard
  deviation 0, e.g. `Normal(x, 0)`, which collapses to `Fixed(x)`) is
  now resolved to its point value at construction, so it behaves exactly
  like passing the number. Previously such a parameter left the
  distribution marked uncertain, so
  [`mean()`](https://rdrr.io/r/base/mean.html) and
  [`sd()`](https://epiforecasts.io/distspec/reference/sd.md) returned
  `NA` for an otherwise fully-fixed distribution
  (e.g. `Gamma(shape = Normal(3, 0), rate = 2)`).
- [`sd()`](https://epiforecasts.io/distspec/reference/sd.md) of a
  nonparametric distribution now returns the standard deviation rather
  than the variance (a missing square root). This also affects
  [`sd()`](https://epiforecasts.io/distspec/reference/sd.md) of any
  discretised distribution, since
  [`discretise()`](https://epiforecasts.io/distspec/reference/discretise.md)
  produces a nonparametric distribution.
- [`collapse()`](https://epiforecasts.io/distspec/reference/collapse.md)
  now correctly convolves runs of three or more consecutive
  nonparametric distributions, and runs that do not begin at the first
  component, rather than erroring or convolving the wrong component.
- Convolution in
  [`collapse()`](https://epiforecasts.io/distspec/reference/collapse.md)
  now uses a numerically stable implementation.
- [`bound_dist()`](https://epiforecasts.io/distspec/reference/bound_dist.md)
  now truncates a fixed nonparametric PMF at `max` when the PMF is
  longer than `max + 1`, renormalising the result, and leaves it
  untouched when `max` reaches beyond the support. Previously the
  condition was inverted, so the bound never applied when requested and
  produced an all-`NA` PMF when `max` exceeded the support.
- Comparing two distributions with `==` (or `!=`) no longer errors when
  a parameter is a numeric vector of length greater than one; such
  parameters are now compared as whole vectors.
- [`fix_parameters()`](https://epiforecasts.io/distspec/reference/fix_parameters.md)
  and
  [`discretise()`](https://epiforecasts.io/distspec/reference/discretise.md)
  now forward `strategy` and `remove_trailing_zeros` to the components
  of a composite distribution, so these arguments are no longer silently
  ignored for composites.
- [`Fixed()`](https://epiforecasts.io/distspec/reference/Fixed.md)
  distributions may now take a value of `0`; the lower bound for the
  `value` parameter has been corrected accordingly, and a value below
  that bound is now rejected with an informative error instead of
  silently producing an invalid probability mass function.
- An uncertain (Dirichlet-backed) nonparametric distribution is now
  treated consistently as uncertain, storing its Dirichlet prior in
  place of a concrete PMF just as an uncertain parametric distribution
  stores a `dist_spec` for a parameter. It has no PMF until resolved
  with
  [`fix_parameters()`](https://epiforecasts.io/distspec/reference/fix_parameters.md):
  [`get_pmf()`](https://epiforecasts.io/distspec/reference/get_pmf.md)
  errors on such a distribution,
  [`mean()`](https://rdrr.io/r/base/mean.html) returns `NA` (or the
  prior mean with `ignore_uncertainty = TRUE`), and it prints with its
  prior nested like any other uncertain distribution.
- Applying `max` or `cdf_cutoff` to an uncertain (Dirichlet-backed)
  nonparametric distribution now raises an informative error, since its
  support is fixed by the Dirichlet prior and the bound would otherwise
  be silently ignored.
- [`plot()`](https://rdrr.io/r/graphics/plot.default.html) gives an
  actionable error when asked to plot a distribution with no finite
  range (no finite `max` and no `cdf_cutoff`), pointing to
  [`bound_dist()`](https://epiforecasts.io/distspec/reference/bound_dist.md),
  rather than a cryptic message or a silently chosen default range.
- [`mean()`](https://rdrr.io/r/base/mean.html) and
  [`sd()`](https://epiforecasts.io/distspec/reference/sd.md) now emit an
  informative message when they return `NA` because a distribution has
  uncertain parameters, pointing to `mean(x, ignore_uncertainty = TRUE)`
  and
  [`fix_parameters()`](https://epiforecasts.io/distspec/reference/fix_parameters.md).
- Improved the error messages from
  [`get_element()`](https://epiforecasts.io/distspec/reference/get_element.md)
  and
  [`get_parameters()`](https://epiforecasts.io/distspec/reference/get_parameters.md):
  an out-of-range `id` now reports the offending value and valid range,
  and the nonparametric error no longer implies that Weibull, Beta and
  Exponential distributions lack parameters.

### Documentation

- Each distribution now has its own reference page
  ([`Gamma()`](https://epiforecasts.io/distspec/reference/Gamma.md),
  [`LogNormal()`](https://epiforecasts.io/distspec/reference/LogNormal.md),
  …) rather than a single combined page, so each shows only its own
  parameters. The reference index covers the full exported API, and the
  [`discretise()`](https://epiforecasts.io/distspec/reference/discretise.md)
  help page documents how discretisation works, including the fixed
  point-mass special case.
- Documentation improvements: the getting-started vignette now shows the
  end-to-end `get_pmf(collapse(discretise(d1 + d2)))` pipeline for
  combining two delays into a single PMF, stale EpiNow2 and Stan
  references have been removed from the roxygen, and the
  [`bound_dist()`](https://epiforecasts.io/distspec/reference/bound_dist.md),
  [`discretise()`](https://epiforecasts.io/distspec/reference/discretise.md),
  [`fix_parameters()`](https://epiforecasts.io/distspec/reference/fix_parameters.md)
  and [`sd()`](https://epiforecasts.io/distspec/reference/sd.md) help
  pages have clearer descriptions and runnable examples.

### Package changes

- Discretisation now uses the `primarycensored` package to compute
  double censored probability mass functions.
- [`natural_params()`](https://epiforecasts.io/distspec/reference/natural_params.md)
  and
  [`lower_bounds()`](https://epiforecasts.io/distspec/reference/lower_bounds.md)
  are now S3 generics, with each distribution’s behaviour defined
  alongside its type (in its own `R/` file) rather than in scattered
  [`switch()`](https://rdrr.io/r/base/switch.html)/`if` statements.
  [`Gamma()`](https://epiforecasts.io/distspec/reference/Gamma.md),
  [`Normal()`](https://epiforecasts.io/distspec/reference/Normal.md),
  [`LogNormal()`](https://epiforecasts.io/distspec/reference/LogNormal.md),
  [`Exp()`](https://epiforecasts.io/distspec/reference/Exponential.md),
  [`Weibull()`](https://epiforecasts.io/distspec/reference/Weibull.md),
  [`Beta()`](https://epiforecasts.io/distspec/reference/Beta.md),
  [`Fixed()`](https://epiforecasts.io/distspec/reference/Fixed.md), the
  [`Dirichlet()`](https://epiforecasts.io/distspec/reference/Dirichlet.md)
  prior and the nonparametric distribution now define their per-type
  behaviour (parameter metadata, and
  [`mean()`](https://rdrr.io/r/base/mean.html)/[`sd()`](https://epiforecasts.io/distspec/reference/sd.md)/[`max()`](https://rdrr.io/r/base/Extremes.html)
  where applicable) this way. The internal per-distribution
  [`switch()`](https://rdrr.io/r/base/switch.html) statements have been
  collapsed to direct S3 dispatch; attempting to discretise a
  distribution that has no CDF now reports this directly.
- Internal idiomatic cleanups: switched the uncertain-parameter checks
  to the existing
  [`has_uncertainty()`](https://epiforecasts.io/distspec/reference/has_uncertainty.md)
  predicate (removing a near-duplicate helper), threaded pre-computed
  parameter means through
  [`to_natural()`](https://epiforecasts.io/distspec/reference/to_natural.md)
  to avoid redundant `lapply(x$parameters, mean)` calls in every method,
  vectorised the attribute-copy loop in
  [`discretise()`](https://epiforecasts.io/distspec/reference/discretise.md),
  used `%||%` for null-default attribute guards, and extracted repeated
  [`get_parameters()`](https://epiforecasts.io/distspec/reference/get_parameters.md)
  calls and `sum(convolutions)` into local variables.
- Reduced dependencies: dropped `data.table`, `checkmate` and `purrr`,
  and moved `ggplot2` to `Suggests`.
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) now prompts
  to install `ggplot2` if it is missing, so it is no longer a hard
  dependency of the package.
