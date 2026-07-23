# Get the names of the natural parameters of a distribution

These are the natural (canonical) parameters of a distribution, such as
`shape` and `rate` for a gamma distribution or `meanlog` and `sdlog` for
a lognormal distribution. All other parameter representations (for
example a mean and standard deviation) are converted to these using
[`convert_to_natural()`](https://epiforecasts.io/distspec/reference/convert_to_natural.md).

## Usage

``` r
natural_params(x)
```

## Arguments

- x:

  A `<dist_spec>`.

## Value

A character vector, the natural parameters.

## Examples

``` r
natural_params(Gamma(shape = 1, rate = 1))
#> [1] "shape" "rate" 
# a distribution type can also be given by name
natural_params("gamma")
#> [1] "shape" "rate" 
```
