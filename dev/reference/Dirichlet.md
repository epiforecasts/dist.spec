# Dirichlet prior for a nonparametric distribution

A Dirichlet prior over the weights of a nonparametric probability mass
function, used to specify an estimated
[`NonParametric()`](https://epiforecasts.io/distspec/dev/reference/NonParametric.md)
distribution whose PMF is estimated during model fitting. Give either
`alpha` directly, or a reference `prior` PMF together with a
`concentration`.

## Usage

``` r
Dirichlet(alpha, prior, concentration, ...)
```

## Arguments

- alpha:

  A positive numeric vector of concentration parameters.

- prior:

  Either a numeric PMF vector (zero-indexed, i.e. the first entry
  represents probability mass at zero) or a `dist_spec` object. If a
  `dist_spec` object is provided it will be discretised and the PMF
  extracted. If numeric, it will be normalised to sum to one internally.

- concentration:

  A positive scalar controlling how tightly the Dirichlet prior
  concentrates around the supplied PMF. The Dirichlet alpha vector is
  computed as `alpha_i = concentration * p_i` where `p_i` is the prior
  PMF. Guidance on values:

  - `concentration = 1`: weak prior, each alpha equals the PMF value
    (near-uniform for roughly equal PMF entries)

  - `concentration = 5-20`: moderate flexibility around the reference
    shape

  - `concentration = 50+`: strong anchoring to the reference PMF

- ...:

  Not used.

## Value

A `<dist_spec>`.

## See also

[`NonParametric()`](https://epiforecasts.io/distspec/dev/reference/NonParametric.md)
to use the prior, and
[Distributions](https://epiforecasts.io/distspec/dev/reference/Distributions.md)
for an overview.

## Examples

``` r
Dirichlet(c(1, 1, 1, 1))
#> - dirichlet distribution:
#>   alpha:
#>     1 1 1 1
Dirichlet(prior = c(0.1, 0.3, 0.4, 0.2), concentration = 10)
#> - dirichlet distribution:
#>   alpha:
#>     1 3 4 2
```
