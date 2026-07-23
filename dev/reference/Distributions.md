# Probability distributions

distspec represents probability distributions (typically epidemiological
delays, such as generation times or reporting delays) as `<dist_spec>`
objects. Each supported distribution has its own constructor:
[`LogNormal()`](https://epiforecasts.io/distspec/dev/reference/LogNormal.md),
[`Gamma()`](https://epiforecasts.io/distspec/dev/reference/Gamma.md),
[`Normal()`](https://epiforecasts.io/distspec/dev/reference/Normal.md),
[`Exp()`](https://epiforecasts.io/distspec/dev/reference/Exp.md),
[`Weibull()`](https://epiforecasts.io/distspec/dev/reference/Weibull.md),
[`Beta()`](https://epiforecasts.io/distspec/dev/reference/Beta.md),
[`Fixed()`](https://epiforecasts.io/distspec/dev/reference/Fixed.md),
[`NonParametric()`](https://epiforecasts.io/distspec/dev/reference/NonParametric.md)
and
[`Dirichlet()`](https://epiforecasts.io/distspec/dev/reference/Dirichlet.md).

## Details

A parameter can be given either as a fixed numeric value or as an
uncertain value (another `<dist_spec>`); currently only normally
distributed uncertain parameters (from
[`Normal()`](https://epiforecasts.io/distspec/dev/reference/Normal.md))
are supported.

Each distribution has a "natural" parameterisation (the one used in the
stan models) and can sometimes also be specified using other parameters,
such as its mean and standard deviation, which are then converted to the
natural parameters (by random sampling if they are uncertain).

## See also

[`discretise()`](https://epiforecasts.io/distspec/dev/reference/discretise.md)
and
[`collapse()`](https://epiforecasts.io/distspec/dev/reference/collapse.md)
to discretise and convolve distributions,
[`sample_dist()`](https://epiforecasts.io/distspec/dev/reference/sample_dist.md)
to draw samples, and
[`get_parameters()`](https://epiforecasts.io/distspec/dev/reference/get_parameters.md)
/
[`get_pmf()`](https://epiforecasts.io/distspec/dev/reference/get_pmf.md)
to inspect them.
