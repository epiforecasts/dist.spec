# Validate the structure of a `<dist_spec>`

Asserts the structural invariants of a `<dist_spec>`: its class, the
shape of its parameters, and its `max`/`cdf_cutoff` attributes. Called
by every constructor on the object it builds, so a `<dist_spec>` from
the package is always well-formed. A composite is valid when each of its
components is.

## Usage

``` r
validate_dist_spec(x)
```

## Arguments

- x:

  A `<dist_spec>` object.

## Value

`x`, invisibly, if it is valid; otherwise an error is raised.
