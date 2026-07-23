# Beta distribution

A beta distribution as a `<dist_spec>`, given either by its shape
parameters `shape1`/`shape2` or by its `mean`/`sd`. It is not
discretised.

## Usage

``` r
Beta(shape1, shape2, mean, sd, ...)
```

## Arguments

- shape1, shape2:

  Shape parameters of the beta distribution.

- mean, sd:

  Mean and standard deviation of the distribution, as an alternative to
  `shape1`/`shape2`.

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
Beta(shape1 = 2, shape2 = 5)
#> - beta distribution:
#>   shape1:
#>     2
#>   shape2:
#>     5
Beta(mean = 0.3, sd = 0.15)
#> - beta distribution:
#>   shape1:
#>     2.5
#>   shape2:
#>     5.8
```
