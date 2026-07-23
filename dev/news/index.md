# Changelog

## distspec (development version)

- Applying `max` or `cdf_cutoff` to an estimated (Dirichlet-backed)
  nonparametric distribution now raises an informative error, since its
  support is fixed by the Dirichlet prior and the bound would otherwise
  be silently ignored.
- Added
  [`has_uncertainty()`](https://epiforecasts.io/distspec/dev/reference/has_uncertainty.md),
  a predicate for whether a `<dist_spec>` (or a component of a
  composite) carries a prior, so dependent packages and internal code
  can test for uncertainty in one place.
- An estimated (Dirichlet-backed) nonparametric distribution is now
  treated consistently as uncertain, storing its Dirichlet prior in
  place of a concrete PMF just as an uncertain parametric distribution
  stores a `dist_spec` for a parameter. It has no PMF until resolved
  with
  [`fix_parameters()`](https://epiforecasts.io/distspec/dev/reference/fix_parameters.md):
  [`get_pmf()`](https://epiforecasts.io/distspec/dev/reference/get_pmf.md)
  errors on such a distribution,
  [`mean()`](https://rdrr.io/r/base/mean.html) returns `NA` (or the
  prior mean with `ignore_uncertainty = TRUE`), and it prints with its
  prior nested like any other uncertain distribution.
- [`natural_params()`](https://epiforecasts.io/distspec/dev/reference/natural_params.md)
  and
  [`lower_bounds()`](https://epiforecasts.io/distspec/dev/reference/lower_bounds.md)
  again accept a distribution type given by name
  (e.g. `natural_params("gamma")`), as well as a `<dist_spec>`, so
  dependent packages can query type metadata without constructing an
  instance.
- Each distribution now has its own reference page
  ([`Gamma()`](https://epiforecasts.io/distspec/dev/reference/Gamma.md),
  [`LogNormal()`](https://epiforecasts.io/distspec/dev/reference/LogNormal.md),
  …) rather than a single combined page, so each shows only its own
  parameters. The reference index covers the full exported API, and the
  [`discretise()`](https://epiforecasts.io/distspec/dev/reference/discretise.md)
  help page documents how discretisation works, including the fixed
  point-mass special case.
- A distribution’s type is now carried in the S3 class of its
  `<dist_spec>` (e.g. `c("gamma", "dist_spec")`), so per-type behaviour
  dispatches directly and each distribution’s methods live in one place.
  The internal `distribution` dispatch class and `new_dist()` have been
  removed. The internal helpers
  [`natural_params()`](https://epiforecasts.io/distspec/dev/reference/natural_params.md)
  and
  [`lower_bounds()`](https://epiforecasts.io/distspec/dev/reference/lower_bounds.md)
  now take a `<dist_spec>` rather than a distribution-name string.
- Added
  [`sample_dist()`](https://epiforecasts.io/distspec/dev/reference/sample_dist.md)
  to draw random samples from a distribution with fixed parameters. A
  composite distribution is sampled per component, returning an `n` by
  `k` matrix ([`rowSums()`](https://rdrr.io/r/base/colSums.html) gives
  samples of the combined distribution). Distributions with uncertain
  (prior) parameters cannot be sampled and raise an error.
- The package has been renamed from `dist.spec` to `distspec`.
- Added a
  [`Beta()`](https://epiforecasts.io/distspec/dev/reference/Beta.md)
  distribution (`shape1`/`shape2`, or `mean`/`sd`).
- Discretisation now uses the `primarycensored` package to compute
  double censored probability mass functions.
- Added [`Exp()`](https://epiforecasts.io/distspec/dev/reference/Exp.md)
  and
  [`Weibull()`](https://epiforecasts.io/distspec/dev/reference/Weibull.md)
  distributions.
- Added
  [`Dirichlet()`](https://epiforecasts.io/distspec/dev/reference/Dirichlet.md)
  and support for estimated nonparametric distributions specified via a
  Dirichlet prior (`NonParametric(pmf = Dirichlet(...))`).
- [`Fixed()`](https://epiforecasts.io/distspec/dev/reference/Fixed.md)
  distributions may now take a value of `0`; the lower bound for the
  `value` parameter has been corrected accordingly, and a value below
  that bound is now rejected with an informative error instead of
  silently producing an invalid probability mass function.
- [`sd()`](https://epiforecasts.io/distspec/dev/reference/sd.md) of a
  nonparametric distribution now returns the standard deviation rather
  than the variance (a missing square root). This also affects
  [`sd()`](https://epiforecasts.io/distspec/dev/reference/sd.md) of any
  discretised distribution, since
  [`discretise()`](https://epiforecasts.io/distspec/dev/reference/discretise.md)
  produces a nonparametric distribution.
- [`discretise()`](https://epiforecasts.io/distspec/dev/reference/discretise.md)
  gains a `remove_trailing_zeros` argument (default `TRUE`).
- [`get_parameters()`](https://epiforecasts.io/distspec/dev/reference/get_parameters.md)
  is now an S3 generic.
- Convolution in
  [`collapse()`](https://epiforecasts.io/distspec/dev/reference/collapse.md)
  now uses a numerically stable implementation.
- Exported the lower-level helpers
  [`sd()`](https://epiforecasts.io/distspec/dev/reference/sd.md),
  [`ndist()`](https://epiforecasts.io/distspec/dev/reference/ndist.md),
  [`natural_params()`](https://epiforecasts.io/distspec/dev/reference/natural_params.md)
  and
  [`lower_bounds()`](https://epiforecasts.io/distspec/dev/reference/lower_bounds.md)
  so that dependent packages can reuse them.
- [`natural_params()`](https://epiforecasts.io/distspec/dev/reference/natural_params.md)
  and
  [`lower_bounds()`](https://epiforecasts.io/distspec/dev/reference/lower_bounds.md)
  are now S3 generics, with each distribution’s behaviour defined
  alongside its type (in its own `R/` file) rather than in scattered
  [`switch()`](https://rdrr.io/r/base/switch.html)/`if` statements.
  [`Gamma()`](https://epiforecasts.io/distspec/dev/reference/Gamma.md),
  [`Normal()`](https://epiforecasts.io/distspec/dev/reference/Normal.md),
  [`LogNormal()`](https://epiforecasts.io/distspec/dev/reference/LogNormal.md),
  [`Exp()`](https://epiforecasts.io/distspec/dev/reference/Exp.md),
  [`Weibull()`](https://epiforecasts.io/distspec/dev/reference/Weibull.md),
  [`Beta()`](https://epiforecasts.io/distspec/dev/reference/Beta.md),
  [`Fixed()`](https://epiforecasts.io/distspec/dev/reference/Fixed.md),
  the
  [`Dirichlet()`](https://epiforecasts.io/distspec/dev/reference/Dirichlet.md)
  prior and the nonparametric distribution now define their per-type
  behaviour (parameter metadata, and
  [`mean()`](https://rdrr.io/r/base/mean.html)/[`sd()`](https://epiforecasts.io/distspec/dev/reference/sd.md)/[`max()`](https://rdrr.io/r/base/Extremes.html)
  where applicable) this way. The internal per-distribution
  [`switch()`](https://rdrr.io/r/base/switch.html) statements have been
  collapsed to direct S3 dispatch; attempting to discretise a
  distribution that has no CDF now reports this directly.
- Reduced dependencies: dropped `data.table`, `checkmate` and `purrr`.
