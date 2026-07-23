# Lognormal distribution

A lognormal distribution as a `<dist_spec>`, given either by its natural
parameters `meanlog`/`sdlog` or by its `mean`/`sd`.

## Usage

``` r
LogNormal(meanlog, sdlog, mean, sd, ...)
```

## Arguments

- meanlog, sdlog:

  mean and standard deviation of the distribution on the log scale with
  default values of `0` and `1` respectively.

- mean, sd:

  Mean and standard deviation of the distribution, as an alternative to
  `meanlog`/`sdlog`.

- ...:

  Limits of the distribution, passed to
  [`bound_dist()`](https://epiforecasts.io/distspec/dev/reference/bound_dist.md).

## Value

A `<dist_spec>`.

## See also

[Distributions](https://epiforecasts.io/distspec/dev/reference/Distributions.md)
for an overview and the other distributions.

## Examples

``` r
LogNormal(mean = 4, sd = 1)
#> - lognormal distribution:
#>   meanlog:
#>     1.4
#>   sdlog:
#>     0.25
LogNormal(mean = 4, sd = 1, max = 10)
#> - lognormal distribution (max: 10):
#>   meanlog:
#>     1.4
#>   sdlog:
#>     0.25
# Uncertain parameters must be given as the natural parameters
LogNormal(meanlog = Normal(1.5, 0.5), sdlog = 0.25, max = 10)
#> - lognormal distribution (max: 10):
#>   meanlog:
#>     - normal distribution:
#>       mean:
#>         1.5
#>       sd:
#>         0.5
#>   sdlog:
#>     0.25
```
