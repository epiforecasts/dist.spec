# Internal function for converting parameters to natural parameters.

Preprocessing before generating a `dist_spec`: converts a distribution's
parameters to its natural parameters via the per-type `to_natural()`
method, re-attaching uncertainty by sampling where parameters are
uncertain.

## Usage

``` r
convert_to_natural(x)
```

## Arguments

- x:

  A `<dist_spec>`.

## Value

A named list of natural parameters.
