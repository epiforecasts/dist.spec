# Get parameters of a parametric distribution

Generic function to extract the distribution parameters (e.g. shape and
rate for Gamma) from a `dist_spec` object.

## Usage

``` r
get_parameters(x, ...)

# S3 method for class 'dist_spec'
get_parameters(x, id = NULL, ...)
```

## Arguments

- x:

  A `dist_spec` object

- ...:

  Additional arguments passed to methods

- id:

  Integer; the id of the distribution to use (if x is a composite
  distribution). If `x` is a single distribution this is ignored and can
  be left at its default value of `NULL`.

## Value

A list of parameters of the distribution.

## Examples

``` r
dist <- Gamma(shape = 3, rate = 2)
get_parameters(dist)
#> $shape
#> [1] 3
#> 
#> $rate
#> [1] 2
#> 
```
