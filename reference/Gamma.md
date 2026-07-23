# Gamma distribution

A gamma distribution as a `<dist_spec>`, given either by its natural
parameters `shape`/`rate` (or `shape`/`scale`) or by its `mean`/`sd`.

## Usage

``` r
Gamma(shape, rate, scale, mean, sd, ...)
```

## Arguments

- shape, scale:

  shape and scale parameters. Must be positive, `scale` strictly.

- rate:

  an alternative way to specify the scale.

- mean, sd:

  Mean and standard deviation of the distribution, as an alternative to
  `shape`/`rate`.

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
Gamma(mean = 4, sd = 1)
#> - gamma distribution:
#>   shape:
#>     16
#>   rate:
#>     4
Gamma(shape = 16, rate = 4)
#> - gamma distribution:
#>   shape:
#>     16
#>   rate:
#>     4
Gamma(shape = Normal(16, 2), rate = Normal(4, 1))
#> - gamma distribution:
#>   shape:
#>     - normal distribution:
#>       mean:
#>         16
#>       sd:
#>         2
#>   rate:
#>     - normal distribution:
#>       mean:
#>         4
#>       sd:
#>         1
```
