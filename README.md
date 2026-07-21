
<!-- README.md is generated from README.Rmd. Please edit that file -->

# distspec: probability distributions with certain or uncertain parameters

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/epiforecasts/distspec/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/epiforecasts/distspec/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/epiforecasts/distspec/graph/badge.svg)](https://app.codecov.io/gh/epiforecasts/distspec)
[![CRAN
status](https://www.r-pkg.org/badges/version/distspec)](https://CRAN.R-project.org/package=distspec)

[![MIT
license](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/epiforecasts/distspec/blob/main/LICENSE.md/)
[![GitHub
contributors](https://img.shields.io/github/contributors/epiforecasts/distspec)](https://github.com/epiforecasts/distspec/graphs/contributors)
[![universe](https://epiforecasts.r-universe.dev/badges/distspec)](http://epiforecasts.r-universe.dev/distspec)
<!-- badges: end -->

distspec represents a probability distribution as a single object, a
`<dist_spec>`, whose parameters can be either fixed or uncertain. It
grew out of [EpiNow2](https://epiforecasts.io/EpiNow2/) and targets the
delay distributions that recur in infectious disease modelling —
generation times, incubation periods, reporting delays — while remaining
independent of any particular model.

With distspec you can:

- define a distribution with a named constructor (`Gamma()`,
  `LogNormal()`, `Normal()`, `Exponential()`, `Weibull()`, `Beta()`,
  `Fixed()` or `NonParametric()`), by its natural parameters or by its
  mean and standard deviation;
- give any parameter an uncertain prior (for example
  `Gamma(shape = Normal(2, 0.5), rate = 1)`), or leave a nonparametric
  mass function to be estimated during model fitting via a `Dirichlet()`
  prior;
- discretise a continuous distribution to a probability mass function
  (`discretise()`), convolve distributions (`+`, `collapse()`), draw
  samples (`sample_dist()`), and query means, standard deviations,
  bounds and PMFs.

## Installation

Install the development version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("epiforecasts/distspec")
```

## Quick start

``` r
library(distspec)
#> 
#> Attaching package: 'distspec'
#> The following objects are masked from 'package:stats':
#> 
#>     Gamma, sd

# A gamma delay with mean 4 and standard deviation 2, truncated at 20
delay <- Gamma(mean = 4, sd = 2, max = 20)
delay
#> - gamma distribution (max: 20):
#>   shape:
#>     4
#>   rate:
#>     1

# Discretise it to a probability mass function
get_pmf(discretise(delay))
#>  [1] 4.348792e-03 6.644381e-02 1.734249e-01 2.178947e-01 1.932673e-01
#>  [6] 1.407835e-01 9.044713e-02 5.327464e-02 2.944744e-02 1.550665e-02
#> [11] 7.859601e-03 3.862608e-03 1.850583e-03 8.678941e-04 3.997049e-04
#> [16] 1.812269e-04 8.105858e-05 3.582527e-05 1.566718e-05 6.787387e-06

# A parameter can itself be a distribution, expressing uncertainty
Gamma(shape = Normal(2, 0.5), rate = 1)
#> - gamma distribution:
#>   shape:
#>     - normal distribution:
#>       mean:
#>         2
#>       sd:
#>         0.5
#>   rate:
#>     1
```

See `vignette("distspec")` to get started, and the [reference
index](https://epiforecasts.io/distspec/reference/) for the full list of
functions.

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

All contributions to this project are gratefully acknowledged using the
[`allcontributors` package](https://github.com/ropensci/allcontributors)
following the [all-contributors](https://allcontributors.org)
specification. Contributions of any kind are welcome!

### Code

<a href="https://github.com/epiforecasts/distspec/commits?author=sbfnk">sbfnk</a>,
<a href="https://github.com/epiforecasts/distspec/commits?author=dependabot[bot]">dependabot\[bot\]</a>,
<a href="https://github.com/epiforecasts/distspec/commits?author=github-merge-queue[bot]">github-merge-queue\[bot\]</a>,
<a href="https://github.com/epiforecasts/distspec/commits?author=seabbs">seabbs</a>,
<a href="https://github.com/epiforecasts/distspec/commits?author=github-actions[bot]">github-actions\[bot\]</a>

### Issues

<a href="https://github.com/epiforecasts/distspec/issues?q=is%3Aissue+author%3Ajamesmbaazam">jamesmbaazam</a>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->
