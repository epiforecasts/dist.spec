# Sample from a distribution

Draws random samples from a `<dist_spec>` whose parameters are fixed
numbers, using the base-R random-generation function for its family
(e.g. [`rgamma()`](https://rdrr.io/r/stats/GammaDist.html) for a gamma
distribution). A discretised distribution is sampled on its integer
support.

Only distributions with fixed parameters can be sampled. If any
parameter is itself a distribution (a prior), there is no single
distribution to sample from and an error is raised.

A composite (multi-component) distribution is sampled per component, in
keeping with
[`mean()`](https://rdrr.io/r/base/mean.html)/[`sd()`](https://epiforecasts.io/distspec/dev/reference/sd.md),
which also return one value per component. Use
[`rowSums()`](https://rdrr.io/r/base/colSums.html) on the result to
obtain samples of the combined (convolved) distribution.

## Usage

``` r
sample_dist(x, n, ...)

# S3 method for class 'dist_spec'
sample_dist(x, n, ...)

# S3 method for class 'multi_dist_spec'
sample_dist(x, n, ...)
```

## Arguments

- x:

  A `<dist_spec>`.

- n:

  The number of samples to draw.

- ...:

  Not used.

## Value

For a single distribution, a numeric vector of `n` samples. For a
composite distribution of `k` components, an `n` by `k` matrix, one
column of `n` samples per component
([`rowSums()`](https://rdrr.io/r/base/colSums.html) gives `n` samples of
the combined distribution).

## See also

[`fix_parameters()`](https://epiforecasts.io/distspec/dev/reference/fix_parameters.md)
to resolve an uncertain distribution to fixed parameters before
sampling, and
[`discretise()`](https://epiforecasts.io/distspec/dev/reference/discretise.md)
to obtain a PMF instead.

## Examples

``` r
# Samples from a fixed gamma distribution
sample_dist(Gamma(shape = 2, rate = 1), 10)
#>  [1] 3.9266582 1.5419166 2.5444757 0.3473226 1.3127312 3.4250423 1.8222424
#>  [8] 3.3235029 2.3495432 0.2337395

# Samples from a discretised distribution, drawn on its integer support
sample_dist(discretise(Gamma(shape = 2, rate = 1, max = 20)), 10)
#>  [1] 3 2 4 2 2 0 3 1 2 2

# A fixed distribution always returns the same value
sample_dist(Fixed(3), 5)
#> [1] 3 3 3 3 3

# A composite: an n-by-k matrix, one column per component
sample_dist(Gamma(shape = 2, rate = 1) + Gamma(shape = 3, rate = 1), 10)
#>            [,1]      [,2]
#>  [1,] 0.9323295 4.4677389
#>  [2,] 7.1981323 3.1174378
#>  [3,] 0.7382134 5.4940801
#>  [4,] 1.4220351 2.0545171
#>  [5,] 0.8131301 3.4376809
#>  [6,] 1.8968205 4.0997749
#>  [7,] 2.4862998 1.6711702
#>  [8,] 0.6983282 4.5241614
#>  [9,] 4.6943206 3.8135499
#> [10,] 1.3618472 0.9549377
```
