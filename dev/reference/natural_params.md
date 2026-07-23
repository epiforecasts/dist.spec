# Get the names of the natural parameters of a distribution

These are the parameters used in the stan models. All other parameter
representations are converted to these using
[`convert_to_natural()`](https://epiforecasts.io/distspec/dev/reference/convert_to_natural.md)
before being passed to the stan models.

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
