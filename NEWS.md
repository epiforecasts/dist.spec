# distspec 0.1.0

First release. distspec provides the `<dist_spec>` interface for defining
probability distributions with fixed or uncertain parameters, split out from
EpiNow2.

- `mean()` and `sd()` now emit an informative message when they return `NA`
  because a distribution has uncertain parameters, pointing to
  `mean(x, ignore_uncertainty = TRUE)` and `fix_parameters()`.
- `plot()` now handles an unbounded parametric distribution by defaulting to a
  finite range (up to the 99.9th percentile) for the plot only, rather than
  erroring when no finite maximum or `cdf_cutoff` is set.
- Applying `max` or `cdf_cutoff` to an estimated (Dirichlet-backed)
  nonparametric distribution now raises an informative error, since its support
  is fixed by the Dirichlet prior and the bound would otherwise be silently
  ignored.
- Comparing two distributions with `==` (or `!=`) no longer errors when a
  parameter is a numeric vector of length greater than one; such parameters are
  now compared as whole vectors.
- `bound_dist()` now truncates a fixed nonparametric PMF at `max` when the PMF
  is longer than `max + 1`, renormalising the result, and leaves it untouched
  when `max` reaches beyond the support. Previously the condition was inverted,
  so the bound never applied when requested and produced an all-`NA` PMF when
  `max` exceeded the support.
- Added `has_uncertainty()`, a predicate for whether a `<dist_spec>` (or a
  component of a composite) carries a prior, so dependent packages and internal
  code can test for uncertainty in one place.
- An estimated (Dirichlet-backed) nonparametric distribution is now treated
  consistently as uncertain, storing its Dirichlet prior in place of a concrete
  PMF just as an uncertain parametric distribution stores a `dist_spec` for a
  parameter. It has no PMF until resolved with `fix_parameters()`: `get_pmf()`
  errors on such a distribution, `mean()` returns `NA` (or the prior mean with
  `ignore_uncertainty = TRUE`), and it prints with its prior nested like any
  other uncertain distribution.
- `natural_params()` and `lower_bounds()` again accept a distribution type given
  by name (e.g. `natural_params("gamma")`), as well as a `<dist_spec>`, so
  dependent packages can query type metadata without constructing an instance.
- Each distribution now has its own reference page (`Gamma()`, `LogNormal()`,
  ...) rather than a single combined page, so each shows only its own
  parameters. The reference index covers the full exported API, and the
  `discretise()` help page documents how discretisation works, including the
  fixed point-mass special case.
- A distribution's type is now carried in the S3 class of its `<dist_spec>`
  (e.g. `c("gamma", "dist_spec")`), so per-type behaviour dispatches directly and
  each distribution's methods live in one place. The internal `distribution`
  dispatch class and `new_dist()` have been removed. The internal helpers
  `natural_params()` and `lower_bounds()` now take a `<dist_spec>` rather than a
  distribution-name string.
- Added `sample_dist()` to draw random samples from a distribution with fixed
  parameters. A composite distribution is sampled per component, returning an
  `n` by `k` matrix (`rowSums()` gives samples of the combined distribution).
  Distributions with uncertain (prior) parameters cannot be sampled and raise
  an error.
- The package has been renamed from `dist.spec` to `distspec`.
- Added a `Beta()` distribution (`shape1`/`shape2`, or `mean`/`sd`).
- Discretisation now uses the `primarycensored` package to compute double
  censored probability mass functions.
- Added `Exp()` and `Weibull()` distributions.
- Added `Dirichlet()` and support for estimated nonparametric distributions
  specified via a Dirichlet prior (`NonParametric(pmf = Dirichlet(...))`).
- `Fixed()` distributions may now take a value of `0`; the lower bound for the
  `value` parameter has been corrected accordingly, and a value below that
  bound is now rejected with an informative error instead of silently
  producing an invalid probability mass function.
- `sd()` of a nonparametric distribution now returns the standard deviation
  rather than the variance (a missing square root). This also affects `sd()` of
  any discretised distribution, since `discretise()` produces a nonparametric
  distribution.
- `discretise()` gains a `remove_trailing_zeros` argument (default `TRUE`).
- `fix_parameters()` and `discretise()` now forward `strategy` and
  `remove_trailing_zeros` to the components of a composite distribution, so these
  arguments are no longer silently ignored for composites.
- `get_parameters()` is now an S3 generic.
- Convolution in `collapse()` now uses a numerically stable implementation.
- `collapse()` now correctly convolves runs of three or more consecutive
  nonparametric distributions, and runs that do not begin at the first
  component, rather than erroring or convolving the wrong component.
- Exported the lower-level helpers `sd()`, `ndist()`, `natural_params()` and
  `lower_bounds()` so that dependent packages can reuse them.
- `natural_params()` and `lower_bounds()` are now S3 generics, with each
  distribution's behaviour defined alongside its type (in its own `R/` file)
  rather than in scattered `switch()`/`if` statements. `Gamma()`, `Normal()`,
  `LogNormal()`, `Exp()`, `Weibull()`, `Beta()`, `Fixed()`, the `Dirichlet()`
  prior and the nonparametric distribution now define their per-type behaviour
  (parameter metadata, and `mean()`/`sd()`/`max()` where applicable) this way.
  The internal per-distribution `switch()` statements have been collapsed to
  direct S3 dispatch; attempting to discretise a distribution that has no CDF
  now reports this directly.
- Improved the error messages from `get_element()` and `get_parameters()`: an
  out-of-range `id` now reports the offending value and valid range, and the
  nonparametric error no longer implies that Weibull, Beta and Exponential
  distributions lack parameters.
- Reduced dependencies: dropped `data.table`, `checkmate` and `purrr`.
