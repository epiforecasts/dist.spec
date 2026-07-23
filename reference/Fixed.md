# Fixed (point-mass) distribution

A fixed (delta) distribution as a `<dist_spec>`, placing all of its mass
on a single `value`.

## Usage

``` r
Fixed(value, ...)
```

## Arguments

- value:

  Value of the fixed (delta) distribution.

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
Fixed(value = 3)
#> - fixed value:
#>   3
Fixed(value = 3.5)
#> - fixed value:
#>   3.5
```
