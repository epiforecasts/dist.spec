# Probability distributions

distspec represents probability distributions (typically epidemiological
delays, such as generation times or reporting delays) as `<dist_spec>`
objects. Each supported distribution has its own constructor:
[`LogNormal()`](https://epiforecasts.io/distspec/reference/LogNormal.md),
[`Gamma()`](https://epiforecasts.io/distspec/reference/Gamma.md),
[`Normal()`](https://epiforecasts.io/distspec/reference/Normal.md),
[`Exponential()`](https://epiforecasts.io/distspec/reference/Exponential.md),
[`Weibull()`](https://epiforecasts.io/distspec/reference/Weibull.md),
[`Beta()`](https://epiforecasts.io/distspec/reference/Beta.md),
[`Fixed()`](https://epiforecasts.io/distspec/reference/Fixed.md),
[`NonParametric()`](https://epiforecasts.io/distspec/reference/NonParametric.md)
and
[`Dirichlet()`](https://epiforecasts.io/distspec/reference/Dirichlet.md).

## Details

A parameter can be given either as a fixed numeric value or as an
uncertain value (another `<dist_spec>`); currently only normally
distributed uncertain parameters (from
[`Normal()`](https://epiforecasts.io/distspec/reference/Normal.md)) are
supported.

Each distribution has a "natural" (canonical) parameterisation, such as
`shape` and `rate` for
[`Gamma()`](https://epiforecasts.io/distspec/reference/Gamma.md) or
`meanlog` and `sdlog` for
[`LogNormal()`](https://epiforecasts.io/distspec/reference/LogNormal.md).
It can sometimes also be specified using other parameters, such as its
mean and standard deviation, which are then converted to the natural
parameters (propagating any uncertainty with a first-order delta-method
approximation).

## See also

[`discretise()`](https://epiforecasts.io/distspec/reference/discretise.md)
and
[`collapse()`](https://epiforecasts.io/distspec/reference/collapse.md)
to discretise and convolve distributions,
[`sample_dist()`](https://epiforecasts.io/distspec/reference/sample_dist.md)
to draw samples, and
[`get_parameters()`](https://epiforecasts.io/distspec/reference/get_parameters.md)
/ [`get_pmf()`](https://epiforecasts.io/distspec/reference/get_pmf.md)
to inspect them.
