# Internal function for generating a `dist_spec` given parameters and a distribution.

This will convert all parameters to natural parameters before generating
a `dist_spec`. If they are uncertain the uncertainty is propagated to
the natural parameters with a first-order (delta-method) approximation
(see
[`convert_to_natural()`](https://epiforecasts.io/distspec/reference/convert_to_natural.md)).

## Usage

``` r
new_dist_spec(params, distribution, max = Inf, cdf_cutoff = 1)
```

## Arguments

- params:

  Parameters of the distribution (including `max`)

- distribution:

  Character; the distribution type (e.g. `"gamma"`, `"lognormal"`,
  `"nonparametric"`).

- max:

  Numeric, maximum value of the distribution. The distribution will be
  truncated at this value. Default: `Inf`, i.e. no maximum.

- cdf_cutoff:

  Numeric in `(0, 1]`; the cumulative probability up to which the
  distribution is kept, i.e. it is truncated at the `cdf_cutoff`
  quantile. For example `cdf_cutoff = 0.999` keeps the distribution up
  to its 99.9th percentile. Default: `1`, i.e. keep the full
  distribution. A value below `0.5` is rejected, as it is almost
  certainly the tail probability to *drop* rather than the CDF level to
  keep (use `1 - x` instead).

## Value

A `dist_spec` of the given specification.

## Examples

``` r
new_dist_spec(
  params = list(mean = 2, sd = 1),
  distribution = "normal"
)
#> - normal distribution:
#>   mean:
#>     2
#>   sd:
#>     1
```
