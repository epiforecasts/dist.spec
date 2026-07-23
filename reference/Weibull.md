# Weibull distribution

A Weibull distribution as a `<dist_spec>`, given either by its
`shape`/`scale` or by its `mean`/`sd`.

## Usage

``` r
Weibull(shape, scale, mean, sd, ...)
```

## Arguments

- shape, scale:

  shape and scale parameters, the latter defaulting to 1.

- mean, sd:

  Mean and standard deviation of the distribution, as an alternative to
  `shape`/`scale`.

- ...:

  Limits of the distribution, passed to
  [`bound_dist()`](https://epiforecasts.io/distspec/reference/bound_dist.md).

## Value

A `<dist_spec>`.

## See also

[Distributions](https://epiforecasts.io/distspec/reference/Distributions.md)
for an overview and the other distributions.

## Examples

``` r
Weibull(shape = 1, scale = 1)
#> - weibull distribution:
#>   shape:
#>     1
#>   scale:
#>     1
Weibull(shape = 1, scale = 1, max = 10)
#> - weibull distribution (max: 10):
#>   shape:
#>     1
#>   scale:
#>     1
Weibull(mean = 4, sd = 1)
#> - weibull distribution:
#>   shape:
#>     4.5
#>   scale:
#>     4.4
```
