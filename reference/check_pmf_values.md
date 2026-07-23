# Check that a numeric PMF or weight vector is valid

A numeric probability mass function or weight vector must be numeric,
contain only finite, non-negative values, and not be all zero, so that
it can be normalised to sum to one. Raises an informative error
otherwise. Un-normalised vectors are allowed: they are treated as
weights and normalised by the caller.

## Usage

``` r
check_pmf_values(x, arg = "pmf")
```

## Arguments

- x:

  A numeric vector.

- arg:

  The name of the calling argument, used in the error messages.

## Value

`x`, invisibly, if it is valid; otherwise an error is raised.
