# distspec (development version)

- The package has been renamed from `dist.spec` to `distspec`. The `dist_spec`
  object class is unchanged.
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
- `discretise()` gains a `remove_trailing_zeros` argument (default `TRUE`).
- `get_parameters()` is now an S3 generic.
- Convolution in `collapse()` now uses a numerically stable implementation.
- Exported the lower-level helpers `sd()`, `ndist()`, `natural_params()` and
  `lower_bounds()` so that dependent packages can reuse them.
- `natural_params()` and `lower_bounds()` are now S3 generics, beginning a
  refactor that defines each distribution's behaviour alongside its type
  instead of in scattered `switch()` statements. `Gamma()`, `Normal()`,
  `LogNormal()`, `Exp()`, `Weibull()`, `Beta()` and `Fixed()` are migrated so
  far.
- Reduced dependencies: dropped `data.table`, `checkmate` and `purrr`.
