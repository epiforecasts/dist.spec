# Nonparametric distribution

A nonparametric distribution as a `<dist_spec>`, defined directly by its
probability mass function. The PMF can instead be estimated during model
fitting by passing a
[`Dirichlet()`](https://epiforecasts.io/distspec/dev/reference/Dirichlet.md)
prior.

## Usage

``` r
NonParametric(pmf, ...)
```

## Arguments

- pmf:

  Probability mass function, as a zero-indexed numeric vector (the first
  entry is the mass at zero) or a `<dist_spec>` (e.g. from
  [`Dirichlet()`](https://epiforecasts.io/distspec/dev/reference/Dirichlet.md)).
  A numeric vector is normalised to sum to one.

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
NonParametric(c(0.1, 0.3, 0.2, 0.4))
#> - nonparametric distribution
#>   PMF: [0.1 0.3 0.2 0.4]

# With a Dirichlet prior (estimated during model fitting)
NonParametric(pmf = Dirichlet(c(1, 1, 1, 1)))
#> - nonparametric distribution:
#>   pmf:
#>     - dirichlet distribution:
#>       alpha:
#>         1 1 1 1
```
