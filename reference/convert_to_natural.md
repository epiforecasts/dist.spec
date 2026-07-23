# Internal function for converting parameters to natural parameters.

Preprocessing before generating a `dist_spec`: converts a distribution's
parameters to its natural parameters via the per-type
[`to_natural()`](https://epiforecasts.io/distspec/reference/to_natural.md)
method, re-attaching uncertainty where parameters are uncertain.

When any of the supplied parameters are uncertain the uncertainty is
propagated to the natural parameters using a first-order (delta-method)
approximation. The uncertain parameters are treated as independent
normals; the natural parameters are evaluated at their means and their
variances are obtained from the Jacobian of the transformation, computed
by central finite differences. Each natural parameter is returned as a
[`Normal()`](https://epiforecasts.io/distspec/reference/Normal.md) with
that mean and standard deviation.

## Usage

``` r
convert_to_natural(x)
```

## Arguments

- x:

  A `<dist_spec>`.

## Value

A named list of natural parameters.

## Residual limitation

The delta method represents each natural parameter's marginal
uncertainty but discards the correlation between natural parameters
induced by the shared unnatural parameters (for example, `shape` and
`rate` of a gamma both depend on the uncertain `mean`). Specify the
distribution directly in terms of its natural parameters when that
correlation matters.
