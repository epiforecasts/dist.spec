# Get the lower bounds of the parameters of a distribution

This is used to avoid sampling parameter values that have no support.

## Usage

``` r
lower_bounds(x)
```

## Arguments

- x:

  A `<dist_spec>`.

## Value

A numeric vector, the lower bounds.

## Examples

``` r
lower_bounds(LogNormal(meanlog = 0, sdlog = 1))
#> meanlog   sdlog    mean      sd 
#>    -Inf       0       0       0 
# a distribution type can also be given by name
lower_bounds("lognormal")
#> meanlog   sdlog    mean      sd 
#>    -Inf       0       0       0 
```
