# Discretised probability mass function

This function returns the probability mass function of a discretised and
truncated distribution defined by distribution type, maximum value and
model parameters.

## Usage

``` r
discrete_pmf(x, ...)
```

## Arguments

- x:

  A `<dist_spec>`. Discretisation dispatches on the distribution type:
  any type with a `dist_cdf()` method uses the default `.dist_spec`
  method, while `"fixed"` is handled as a point mass by its own method.

- ...:

  Additional arguments passed to methods. The default method takes
  `max_value` (the maximum value to allow), `cdf_cutoff` and `width`
  (the width of each discrete bin).

## Value

A vector representing a probability distribution.

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
