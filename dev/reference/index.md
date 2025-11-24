# Package index

## Defining probability distributions

Functions that are used to define probability distributions

- [`LogNormal()`](https://epiforecasts.io/dist.spec/dev/reference/Distributions.md)
  [`Gamma()`](https://epiforecasts.io/dist.spec/dev/reference/Distributions.md)
  [`Normal()`](https://epiforecasts.io/dist.spec/dev/reference/Distributions.md)
  [`Fixed()`](https://epiforecasts.io/dist.spec/dev/reference/Distributions.md)
  [`NonParametric()`](https://epiforecasts.io/dist.spec/dev/reference/Distributions.md)
  : Probability distributions

- [`new_dist_spec()`](https://epiforecasts.io/dist.spec/dev/reference/new_dist_spec.md)
  **\[experimental\]** :

  Internal function for generating a `dist_spec` given parameters and a
  distribution.

## Access functions

Functions that are used to acccess properties of probability
distributions

- [`get_distribution()`](https://epiforecasts.io/dist.spec/dev/reference/get_distribution.md)
  **\[experimental\]** :

  Get the distribution of a `<dist_spec>`

- [`get_parameters()`](https://epiforecasts.io/dist.spec/dev/reference/get_parameters.md)
  **\[experimental\]** : Get parameters of a parametric distribution

- [`get_pmf()`](https://epiforecasts.io/dist.spec/dev/reference/get_pmf.md)
  **\[experimental\]** : Get the probability mass function of a
  nonparametric distribution

## Modify distributions

Functions to modify and combine probability distributions

- [`c(`*`<dist_spec>`*`)`](https://epiforecasts.io/dist.spec/dev/reference/c.dist_spec.md)
  **\[experimental\]** : Combines multiple delay distributions for
  further processing

- [`` `+`( ``*`<dist_spec>`*`)`](https://epiforecasts.io/dist.spec/dev/reference/plus-.dist_spec.md)
  **\[experimental\]** : Creates a delay distribution as the sum of two
  other delay distributions.

- [`collapse(`*`<dist_spec>`*`)`](https://epiforecasts.io/dist.spec/dev/reference/collapse.md)
  **\[experimental\]** : Collapse nonparametric distributions in a
  \<dist_spec\>

- [`bound_dist()`](https://epiforecasts.io/dist.spec/dev/reference/bound_dist.md)
  **\[experimental\]** :

  Define bounds of a `<dist_spec>`

- [`discretise(`*`<dist_spec>`*`)`](https://epiforecasts.io/dist.spec/dev/reference/discretise.md)
  [`discretize()`](https://epiforecasts.io/dist.spec/dev/reference/discretise.md)
  **\[experimental\]** : Discretise a \<dist_spec\>

- [`fix_parameters(`*`<dist_spec>`*`)`](https://epiforecasts.io/dist.spec/dev/reference/fix_parameters.md)
  **\[experimental\]** :

  Fix the parameters of a `<dist_spec>`

## Query properties of distributions

Functions used to query properties of probability distributions

- [`max(`*`<dist_spec>`*`)`](https://epiforecasts.io/dist.spec/dev/reference/max.dist_spec.md)
  **\[experimental\]** : Returns the maximum of one or more delay
  distribution
- [`mean(`*`<dist_spec>`*`)`](https://epiforecasts.io/dist.spec/dev/reference/mean.dist_spec.md)
  **\[experimental\]** : Returns the mean of one or more delay
  distribution
- [`is_constrained(`*`<dist_spec>`*`)`](https://epiforecasts.io/dist.spec/dev/reference/is_constrained.md)
  **\[experimental\]** : Check if a \<dist_spec\> is constrained, i.e.
  has a finite maximum or nonzero CDF cutoff.

## Compare distributions

Functions used to compare probability distributions

- [`` `==`( ``*`<dist_spec>`*`)`](https://epiforecasts.io/dist.spec/dev/reference/equals-.dist_spec.md)
  [`` `!=`( ``*`<dist_spec>`*`)`](https://epiforecasts.io/dist.spec/dev/reference/equals-.dist_spec.md)
  : Compares two delay distributions

## Visualise distributions

Functions used to print or plot probability distributions

- [`print(`*`<dist_spec>`*`)`](https://epiforecasts.io/dist.spec/dev/reference/print.dist_spec.md)
  **\[experimental\]** : Prints the parameters of one or more delay
  distributions
- [`plot(`*`<dist_spec>`*`)`](https://epiforecasts.io/dist.spec/dev/reference/plot.dist_spec.md)
  **\[experimental\]** : Plot PMF and CDF for a dist_spec object
