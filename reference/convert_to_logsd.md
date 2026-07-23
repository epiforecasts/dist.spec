# Convert mean and sd to log standard deviation for a log normal distribution

Convert from mean and standard deviation to the log standard deviation
of the lognormal distribution. Useful for defining a
[`LogNormal()`](https://epiforecasts.io/distspec/reference/LogNormal.md)
distribution from a mean and standard deviation on the natural scale.

## Usage

``` r
convert_to_logsd(mean, sd)
```

## Arguments

- mean:

  Numeric, mean of a distribution

- sd:

  Numeric, standard deviation of a distribution

## Value

The log standard deviation of a lognormal distribution

## Examples

``` r

convert_to_logsd(2, 1)
#> [1] 0.4723807
```
