# Convert a distribution's parameters to its natural parameters (per-type)

Per-type conversion of a distribution's parameters to its natural
parameters. Dispatched on the distribution type; each method reads the
parameter means from `ux` and returns the natural parameters as a named
list (see e.g. `to_natural.gamma`). The shared pre- and post-processing
lives in
[`convert_to_natural()`](https://epiforecasts.io/distspec/reference/convert_to_natural.md),
which computes `ux` once and passes it in.

## Usage

``` r
to_natural(x, ux)
```

## Arguments

- x:

  A single `<dist_spec>`.

- ux:

  The parameter means, as returned by `lapply(x$parameters, mean)`.

## Value

A named list of natural parameters.
