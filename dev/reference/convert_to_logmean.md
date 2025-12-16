# Convert mean and sd to log mean for a log normal distribution

**\[stable\]** Convert from mean and standard deviation to the log mean
of the lognormal distribution. Useful for defining distributions
supported by `estimate_infections()`, `epinow()`, and
`regional_epinow()`.

**\[stable\]** Convert from mean and standard deviation to the log mean
of the lognormal distribution. Useful for defining distributions
supported by `estimate_infections()`, `epinow()`, and
`regional_epinow()`.

## Usage

``` r
convert_to_logmean(mean, sd)

convert_to_logmean(mean, sd)
```

## Arguments

- mean:

  Numeric, mean of a distribution

- sd:

  Numeric, standard deviation of a distribution

## Value

The log mean of a lognormal distribution

The log mean of a lognormal distribution

## Examples

``` r
convert_to_logmean(2, 1)
#> [1] 0.5815754
```
