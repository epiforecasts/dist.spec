# Exponential distribution

An exponential distribution as a `<dist_spec>`, given either by its
`rate` or by its `mean`.

## Usage

``` r
Exp(rate, mean, ...)
```

## Arguments

- rate:

  vector of rates.

- mean:

  Mean of the distribution, as an alternative to `rate`.

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
Exp(rate = 1)
#> - exp distribution:
#>   rate:
#>     1
Exp(mean = 4)
#> - exp distribution:
#>   rate:
#>     0.25
```
