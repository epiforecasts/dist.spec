# Normal distribution

A normal distribution as a `<dist_spec>`, given by its `mean` and `sd`.
Also used to give an uncertain parameter of another distribution.

## Usage

``` r
Normal(mean, sd, ...)
```

## Arguments

- mean, sd:

  Mean and standard deviation of the distribution.

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
Normal(mean = 4, sd = 1)
#> - normal distribution:
#>   mean:
#>     4
#>   sd:
#>     1
Normal(mean = 4, sd = 1, max = 10)
#> - normal distribution (max: 10):
#>   mean:
#>     4
#>   sd:
#>     1
```
