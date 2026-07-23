# Calculate the number of distributions in a `<dist_spec>`

Calculate the number of distributions in a `<dist_spec>`

## Usage

``` r
ndist(x)
```

## Arguments

- x:

  A `<dist_spec>` object.

## Value

The number of distributions.

## Examples

``` r
ndist(Gamma(mean = 5, sd = 1))
#> [1] 1
ndist(Gamma(mean = 5, sd = 1) + Exp(rate = 1))
#> [1] 2
```
