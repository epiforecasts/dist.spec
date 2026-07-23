# Check whether a `<dist_spec>` is uncertain

A distribution is uncertain when it carries a prior: a parametric
distribution with a `<dist_spec>` (rather than numeric) parameter, or a
nonparametric distribution whose PMF is given by a `<dist_spec>` (a
[`Dirichlet()`](https://epiforecasts.io/distspec/reference/Dirichlet.md)
prior) rather than a numeric vector.

## Usage

``` r
has_uncertainty(x, id = NULL)
```

## Arguments

- x:

  A `<dist_spec>`.

- id:

  Integer; the id of the distribution to use (if x is a composite
  distribution). If `x` is a single distribution this is ignored and can
  be left at its default value of `NULL`.

## Value

`TRUE` if the (component) distribution is uncertain.

## Examples

``` r
has_uncertainty(Gamma(shape = 1, rate = 1))
#> [1] FALSE
has_uncertainty(Gamma(shape = Normal(1, 0.5), rate = 1))
#> [1] TRUE
```
