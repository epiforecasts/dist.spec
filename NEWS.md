# distspec 0.1.0

distspec 0.1.0 splits the `<dist_spec>` interface out of EpiNow2. The entries
below are changes relative to that code as it stood in EpiNow2 1.9.0.

## New features

- Distribution constructors now validate the structure of the object they build
  (class, parameters, and `max`/`cdf_cutoff` attributes) and raise an
  informative error if it is malformed.
- Added a `Beta()` distribution (`shape1`/`shape2`, or `mean`/`sd`).
- Added `Exponential()` and `Weibull()` distributions.
- Added `Dirichlet()` and support for uncertain nonparametric distributions
  specified via a Dirichlet prior (`NonParametric(pmf = Dirichlet(...))`).
- Added `sample_dist()` to draw random samples from a distribution with fixed
  parameters. A composite distribution is sampled per component, returning an
  `n` by `k` matrix (`rowSums()` gives samples of the combined distribution).
  Distributions with uncertain (prior) parameters cannot be sampled and raise
  an error.
- Added `has_uncertainty()`, a predicate for whether a `<dist_spec>` (or a
  component of a composite) carries a prior, so dependent packages and internal
  code can test for uncertainty in one place.
- Uncertainty in a distribution specified with non-natural parameters (e.g.
  `Gamma(mean = Normal(4, 0.5), sd = 1)`) is now propagated to the natural
  parameters with a first-order delta-method approximation. This replaces an
  ad-hoc rule that understated the natural-parameter standard deviations several
  times over.
- `discretise()` gains a `remove_trailing_zeros` argument (default `TRUE`).
- Exported the lower-level helpers `sd()`, `ndist()`, `natural_params()` and
  `lower_bounds()` so that dependent packages can reuse them.
- `natural_params()` and `lower_bounds()` accept a distribution type given by
  name (e.g. `natural_params("gamma")`), as well as a `<dist_spec>`, so dependent
  packages can query type metadata without constructing an instance.

## Breaking changes

- The package has been renamed from `dist.spec` to `distspec`.
- A distribution's type is now carried in the S3 class of its `<dist_spec>`
  (e.g. `c("gamma", "dist_spec")`), so per-type behaviour dispatches directly and
  each distribution's methods live in one place. The internal `distribution`
  dispatch class and `new_dist()` have been removed. The internal helpers
  `natural_params()` and `lower_bounds()` now take a `<dist_spec>` rather than a
  distribution-name string.
- `get_parameters()` is now an S3 generic.
- The `cdf_cutoff` argument (on the distribution constructors and `bound_dist()`)
  is the cumulative probability to keep up to: `cdf_cutoff = 0.999` truncates at
  the 99.9th percentile, and the default `1` keeps the full distribution. A value
  below `0.5` is rejected, as it is almost certainly the tail probability to drop
  (use `1 - x`).

## Deprecations

- `Exp()` is deprecated in favour of `Exponential()`.

## Bug fixes

- `NonParametric()` and `Dirichlet(prior = )` now reject a numeric PMF or weight
  vector that contains negative or non-finite values, or is all zero, with an
  informative error, instead of silently producing an invalid distribution.
  Un-normalised non-negative weights are still accepted and normalised.
- A distribution parameter given as a certain distribution (standard deviation
  0, e.g. `Normal(x, 0)`, which collapses to `Fixed(x)`) is now resolved to its
  point value at construction, so it behaves exactly like passing the number.
  Previously such a parameter left the distribution marked uncertain, so
  `mean()` and `sd()` returned `NA` for an otherwise fully-fixed distribution
  (e.g. `Gamma(shape = Normal(3, 0), rate = 2)`).
- `sd()` of a nonparametric distribution now returns the standard deviation
  rather than the variance (a missing square root). This also affects `sd()` of
  any discretised distribution, since `discretise()` produces a nonparametric
  distribution.
- `collapse()` now correctly convolves runs of three or more consecutive
  nonparametric distributions, and runs that do not begin at the first
  component, rather than erroring or convolving the wrong component.
- Convolution in `collapse()` now uses a numerically stable implementation.
- `bound_dist()` now truncates a fixed nonparametric PMF at `max` when the PMF
  is longer than `max + 1`, renormalising the result, and leaves it untouched
  when `max` reaches beyond the support. Previously the condition was inverted,
  so the bound never applied when requested and produced an all-`NA` PMF when
  `max` exceeded the support.
- Comparing two distributions with `==` (or `!=`) no longer errors when a
  parameter is a numeric vector of length greater than one; such parameters are
  now compared as whole vectors.
- `fix_parameters()` and `discretise()` now forward `strategy` and
  `remove_trailing_zeros` to the components of a composite distribution, so these
  arguments are no longer silently ignored for composites.
- `Fixed()` distributions may now take a value of `0`; the lower bound for the
  `value` parameter has been corrected accordingly, and a value below that
  bound is now rejected with an informative error instead of silently
  producing an invalid probability mass function.
- An uncertain (Dirichlet-backed) nonparametric distribution is now treated
  consistently as uncertain, storing its Dirichlet prior in place of a concrete
  PMF just as an uncertain parametric distribution stores a `dist_spec` for a
  parameter. It has no PMF until resolved with `fix_parameters()`: `get_pmf()`
  errors on such a distribution, `mean()` returns `NA` (or the prior mean with
  `ignore_uncertainty = TRUE`), and it prints with its prior nested like any
  other uncertain distribution.
- Applying `max` or `cdf_cutoff` to an uncertain (Dirichlet-backed)
  nonparametric distribution now raises an informative error, since its support
  is fixed by the Dirichlet prior and the bound would otherwise be silently
  ignored.
- `plot()` gives an actionable error when asked to plot a distribution with no
  finite range (no finite `max` and no `cdf_cutoff`), pointing to `bound_dist()`,
  rather than a cryptic message or a silently chosen default range.
- `mean()` and `sd()` now emit an informative message when they return `NA`
  because a distribution has uncertain parameters, pointing to
  `mean(x, ignore_uncertainty = TRUE)` and `fix_parameters()`.
- Improved the error messages from `get_element()` and `get_parameters()`: an
  out-of-range `id` now reports the offending value and valid range, and the
  nonparametric error no longer implies that Weibull, Beta and Exponential
  distributions lack parameters.

## Documentation

- Each distribution now has its own reference page (`Gamma()`, `LogNormal()`,
  ...) rather than a single combined page, so each shows only its own
  parameters. The reference index covers the full exported API, and the
  `discretise()` help page documents how discretisation works, including the
  fixed point-mass special case.
- Documentation improvements: the getting-started vignette now shows the
  end-to-end `get_pmf(collapse(discretise(d1 + d2)))` pipeline for combining two
  delays into a single PMF, stale EpiNow2 and Stan references have been removed
  from the roxygen, and the `bound_dist()`, `discretise()`, `fix_parameters()`
  and `sd()` help pages have clearer descriptions and runnable examples.

## Package changes

- Discretisation now uses the `primarycensored` package to compute double
  censored probability mass functions.
- `natural_params()` and `lower_bounds()` are now S3 generics, with each
  distribution's behaviour defined alongside its type (in its own `R/` file)
  rather than in scattered `switch()`/`if` statements. `Gamma()`, `Normal()`,
  `LogNormal()`, `Exp()`, `Weibull()`, `Beta()`, `Fixed()`, the `Dirichlet()`
  prior and the nonparametric distribution now define their per-type behaviour
  (parameter metadata, and `mean()`/`sd()`/`max()` where applicable) this way.
  The internal per-distribution `switch()` statements have been collapsed to
  direct S3 dispatch; attempting to discretise a distribution that has no CDF
  now reports this directly.
- Internal idiomatic cleanups: switched the uncertain-parameter checks to the
  existing `has_uncertainty()` predicate (removing a near-duplicate helper),
  threaded pre-computed parameter means through `to_natural()` to avoid
  redundant `lapply(x$parameters, mean)` calls in every method, vectorised the
  attribute-copy loop in `discretise()`, used `%||%` for null-default attribute
  guards, and extracted repeated `get_parameters()` calls and `sum(convolutions)`
  into local variables.
- Reduced dependencies: dropped `data.table`, `checkmate` and `purrr`, and
  moved `ggplot2` to `Suggests`. `plot()` now prompts to install `ggplot2` if it
  is missing, so it is no longer a hard dependency of the package.
