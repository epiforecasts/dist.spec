# Delta-method standard deviations of the natural parameters

First-order (delta-method) standard deviations of a distribution's
natural parameters, propagated from uncertain unnatural parameters. The
uncertain unnatural parameters are treated as independent normals with
standard deviations `sds`, and for each natural parameter the propagated
standard deviation is `sqrt(sum_i J[j, i]^2 * sds[i]^2)`, where the
Jacobian `J[j, i] = d(natural_j) / d(param_i)` is estimated by central
finite differences. Estimating the Jacobian numerically lets this work
uniformly for every distribution type, including the Weibull, whose
[`to_natural()`](https://epiforecasts.io/distspec/reference/to_natural.md)
solves for the shape numerically.

## Usage

``` r
delta_method_sd(x, sds, natural, h_rel = 1e-04)
```

## Arguments

- x:

  A single `<dist_spec>` whose parameters are the unnatural parameters
  evaluated at their means.

- sds:

  Numeric; the standard deviation of each unnatural parameter, in
  `names(x$parameters)` order (`0` for a fixed parameter).

- natural:

  The natural-parameter list evaluated at the means.

- h_rel:

  Numeric; the relative step of the central finite difference. For
  parameter `i` the step is `h_rel * max(abs(mean_i), 1)`, i.e. relative
  to the parameter value with an absolute floor near zero. The default
  `1e-4` keeps both the truncation error (order `h^2`) and the
  floating-point cancellation error (order `eps / h`) small for the
  smooth
  [`to_natural()`](https://epiforecasts.io/distspec/reference/to_natural.md)
  maps. It is a numerical-differentiation constant exposed here for
  testing, deliberately kept off the user-facing constructors.

## Value

A named numeric vector of standard deviations, one per natural
parameter.
