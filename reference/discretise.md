# Discretise a \<dist_spec\>

Discretise a \<dist_spec\>

## Usage

``` r
# S3 method for class 'dist_spec'
discretise(x, strict = TRUE, remove_trailing_zeros = TRUE, ...)

discretize(x, ...)
```

## Arguments

- x:

  A `<dist_spec>`

- strict:

  Logical; If `TRUE` (default) an error will be thrown if a distribution
  cannot be discretised (e.g., because no finite maximum has been
  specified or parameters are uncertain). If `FALSE` then any
  distribution that cannot be discretised will be returned as is.

- remove_trailing_zeros:

  Logical; If `TRUE` (default), trailing zeroes in the resulting PMF
  will be removed. If `FALSE`, trailing zeroes will be retained.

- ...:

  ignored

## Value

A `<dist_spec>` where all distributions with constant parameters are
nonparametric. Extract the resulting PMF vector with
[`get_pmf()`](https://epiforecasts.io/distspec/reference/get_pmf.md).

## Methodological details

The probability mass function is computed using the `{primarycensored}`
package, which provides double censored PMF calculations. This correctly
represents the probability mass function of a double censored
distribution arising from the difference of two censored events.

The probability mass function of the discretised probability
distribution is a vector where the first entry corresponds to the
integral over the (0,1\] interval of the corresponding continuous
distribution (probability of integer 0), the second entry corresponds to
the (0,2\] interval (probability mass of integer 1), the third entry
corresponds to the (1, 3\] interval (probability mass of integer 2),
etc.

The maximum value truncates the distribution: mass beyond it is dropped
and the remaining PMF is renormalised to sum to one. A `cdf_cutoff`
below `1` additionally trims the tail, keeping the distribution only up
to its `cdf_cutoff` quantile.

### Fixed distributions

A [`Fixed()`](https://epiforecasts.io/distspec/reference/Fixed.md)
(point-mass) distribution is not discretised through a CDF but by its
own method: an integer value places all of the mass on that integer,
while a fractional value splits the mass proportionally across the two
adjacent integers. For example `Fixed(2.25)` places 0.75 on 2 and 0.25
on 3.

## References

Charniga, K., et al. “Best practices for estimating and reporting
epidemiological delay distributions of infectious diseases using public
health surveillance and healthcare data”, *arXiv e-prints*, 2024.
[doi:10.48550/arXiv.2405.08841](https://doi.org/10.48550/arXiv.2405.08841)
Park, S. W., et al., "Estimating epidemiological delay distributions for
infectious diseases", *medRxiv*, 2024.
[doi:10.1101/2024.01.12.24301247](https://doi.org/10.1101/2024.01.12.24301247)
Abbott S., et al., "primarycensored: Primary Event Censored
Distributions", 2025.
[doi:10.5281/zenodo.13632839](https://doi.org/10.5281/zenodo.13632839)

## See also

[`collapse()`](https://epiforecasts.io/distspec/reference/collapse.md)
to convolve the discretised components of a composite distribution into
a single PMF, and
[`sample_dist()`](https://epiforecasts.io/distspec/reference/sample_dist.md)
to draw random samples. The
[`vignette("distspec")`](https://epiforecasts.io/distspec/articles/distspec.md)
shows the full `get_pmf(collapse(discretise(d1 + d2)))` pipeline.

## Examples

``` r
# A fixed gamma distribution with mean 5 and sd 1, discretised to a PMF.
dist1 <- Gamma(mean = 5, sd = 1, max = 20)
get_pmf(discretise(dist1))
#>  [1] 7.460101e-12 5.497386e-06 2.558827e-03 6.103148e-02 2.678533e-01
#>  [6] 3.692708e-01 2.174276e-01 6.734093e-02 1.271811e-02 1.628790e-03
#> [11] 1.528296e-04 1.112675e-05 6.564278e-07 3.244733e-08 1.379517e-09
#> [16] 5.150880e-11 1.720402e-12 4.851675e-14 3.330669e-15

# An uncertain lognormal distribution cannot be discretised, so with
# `strict = FALSE` it is returned unchanged.
dist2 <- LogNormal(
  meanlog = Normal(3, 0.5),
  sdlog = Normal(2, 0.5),
  max = 20
)
discretise(dist2, strict = FALSE)
#> - lognormal distribution (max: 20):
#>   meanlog:
#>     - normal distribution:
#>       mean:
#>         3
#>       sd:
#>         0.5
#>   sdlog:
#>     - normal distribution:
#>       mean:
#>         2
#>       sd:
#>         0.5

# A fractional fixed value splits its mass across the two adjacent integers.
get_pmf(discretise(Fixed(2.25)))
#> [1] 0.00 0.00 0.75 0.25
```
