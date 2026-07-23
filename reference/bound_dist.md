# Define bounds of a `<dist_spec>`

Set the bounds that constrain a distribution when it is discretised:
`max` truncates the support at that value, while `cdf_cutoff` trims the
tail by keeping the distribution only up to its `cdf_cutoff` quantile.
Either bound drops the mass beyond it and renormalises the remaining PMF
to sum to one.

## Usage

``` r
bound_dist(x, max = Inf, cdf_cutoff = 1)
```

## Arguments

- x:

  A `<dist_spec>`.

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

a `<dist_spec>` with relevant attributes set that define its bounds

## See also

[`discretise()`](https://epiforecasts.io/distspec/reference/discretise.md),
which applies these bounds when producing a PMF.

## Examples

``` r
# Truncate a gamma distribution at 20
bound_dist(Gamma(mean = 5, sd = 1), max = 20)
#> - gamma distribution (max: 19):
#>   shape:
#>     25
#>   rate:
#>     5
# Keep it up to its 99.9th percentile
bound_dist(Gamma(mean = 5, sd = 1), cdf_cutoff = 0.999)
#> - gamma distribution (cdf_cutoff: 0.999):
#>   shape:
#>     25
#>   rate:
#>     5
```
