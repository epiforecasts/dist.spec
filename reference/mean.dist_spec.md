# Returns the mean of one or more delay distribution

This works out the mean of all the (parametric / nonparametric) delay
distributions combined in the passed \<dist_spec\>.

## Usage

``` r
# S3 method for class 'dist_spec'
mean(x, ..., ignore_uncertainty = FALSE)
```

## Arguments

- x:

  The `<dist_spec>` to use

- ...:

  Not used

- ignore_uncertainty:

  Logical; whether to ignore any uncertainty in parameters. If set to
  FALSE (the default) then the mean of any uncertain parameters will be
  returned as NA.

## Value

A numeric vector of means, one per component of the `<dist_spec>`; `NA`
for any component with uncertain parameters unless
`ignore_uncertainty = TRUE`.

## Examples

``` r
# A fixed lognormal distribution with mean 5 and sd 1.
dist1 <- LogNormal(mean = 5, sd = 1, max = 20)
mean(dist1)
#> [1] 5

# An uncertain gamma distribution with shape and rate normally distributed
# as Normal(3, 0.5) and Normal(2, 0.5) respectively
dist2 <- Gamma(
  shape = Normal(3, 0.5),
  rate = Normal(2, 0.5),
  max = 20
)
mean(dist2)
#> Returning NA: this distribution has uncertain parameters.
#> ℹ Use `mean(x, ignore_uncertainty = TRUE)` for the mean of the point estimates,
#>   or resolve the uncertainty first with `fix_parameters()`.
#> This message is displayed once every 8 hours.
#> [1] NA

# The mean of the sum of two distributions
mean(dist1 + dist2)
#> [1]  5 NA
```
