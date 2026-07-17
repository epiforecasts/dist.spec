# Contributing to `{distspec}`

This outlines how to propose a change to `{distspec}`. In general, we accept contributions
in the form of issues and/or pull requests.

## Small changes

### Grammatical issues

You can fix typos, spelling mistakes, or grammatical errors in the documentation directly using the GitHub web interface, as long as the changes are made in the _source_ file. 
This generally means you'll need to edit [roxygen2 comments](https://roxygen2.r-lib.org/articles/roxygen2.html) in an `.R`, not a `.Rd` file. 
You can find the `.R` file that generates the `.Rd` by reading the comment in the first line of the `.Rd` file in the `/man` directory.

## Big changes

If you want to make a bigger change, it's a good idea to first file an issue and make sure 
someone from the team agrees that it’s needed.
Any of the following counts as a big change:

### New features

You can suggest an idea for a new feature/enhancement.
Please provide as much detail of its use case as possible.

### Bugs

If you have found a bug, ideally illustrate it with a minimal [reprex](https://www.tidyverse.org/help/#reprex)
(this will also help you write a unit test, if you opt to fix it yourself). 

### Vignettes

If you find an issue with existing vignettes or would like to help improve them, outline
the suggested changes in the submitted issue for discussion with the team.
Use the various GitHub
markdown features to (cross)reference lines, highlight suggested deletions/additions, etc.

For new vignettes, please provide an outline of the vignette to be discussed with the team first.

### Pull request process

*   Fork the package and clone onto your computer. If you haven't done this before, we recommend using `usethis::create_from_github("epiforecasts/distspec", fork = TRUE)`.
*   Install all development dependences with `devtools::install_dev_deps()`, and then make sure the package passes R CMD check by running `devtools::check()`. 
    If R CMD check doesn't pass cleanly, it's a good idea to ask for help before continuing. 
*   Create a Git branch for your pull request (PR). We recommend using `usethis::pr_init("brief-description-of-change")`.

* We use `pre-commit` to check our changes match our package standards. This is optional but can be enabled using the following steps.

```r
# if python is not installed on your system
install.packages("reticulate")
reticulate::install_miniconda()
# install precommit if not already installed
precommit::install_precommit()
# set up precommit for use
precommit::use_precommit()
```

*   Make your changes, commit to git, and then create a PR by running `usethis::pr_push()`, and following the prompts in your browser.
    The title of your PR should briefly describe the change.
    The body of your PR should contain `Fixes #issue-number`.

*  For user-facing changes, add a bullet to the top of `NEWS.md` (i.e. just below the first header). Follow the style described in <https://style.tidyverse.org/news.html>.

#### What happens after submitting a PR?

*   PRs are reviewed by the team before they are merged. The review process only begins after the continuous integration checks, which have to be manually triggered by a maintainer for first-time contributors, have passed.

*   The Github Actions checks currently take a while (about an hour), so it might be helpful to "watch" the repository and check your email for a notification when it's all done.

*   Usually, all the review conversations occur under the PR. The reviewer merges the PR when every issue has been resolved. Please use the "Resolve conversation" functionality in the GitHub web interface to indicate when a specific issue has been adressed, responding with a commit pointing to the change made where applicable.

*   When a PR is ready to be merged, you may be asked to [rebase](https://www.atlassian.com/git/tutorials/merging-vs-rebasing) on the `main` branch. You can do this by checking out your branch and running `git rebase main`. If it is successful, your commits will be placed on top of the commit history of `main` in preparation for a merge. A rebase might result in some merge conflicts. Make sure that they are resolved, then push your changes to your branch again (using the `--force` option, that is, `git push -f`, if required).

*   A number of issues can cause the Github checks to fail. It can be helpful to safeguard against them by doing the following:
  *   Check that there are no linting issues by running `lintr::lint_package()`.
  *   Run `devtoools::check()` to check for wider package issues like mismatching documentation, etc. (this currently requires a fair bit of time/computation).
  *   (Optional) Turn on continuous integration with Github Actions on your forked repository.
  
* On a case-by-case basis, you may be asked to increment the package version both in the `NEWS.md` and `DESCRIPTION` files. Please do not do this unless you're asked to. We follow the [Tidyverse package versioning guide](https://r-pkgs.org/lifecycle.html). You can run `usethis::use_version()` to automatically make the changes for you interactively.
  
### Code style

*   New code should follow the tidyverse [style guide](https://style.tidyverse.org). 
    You can use the [styler](https://CRAN.R-project.org/package=styler) package to apply these styles, but please don't restyle code that has nothing to do with your PR.

*  We use [roxygen2](https://cran.r-project.org/package=roxygen2), with [Markdown syntax](https://cran.r-project.org/web/packages/roxygen2/vignettes/rd-formatting.html), for documentation.  

*  We use [testthat](https://cran.r-project.org/package=testthat) for unit tests. 
   Contributions with test cases included are easier to accept.

## Adding a new distribution

Each distribution's behaviour comes from a small set of S3 methods dispatched on the distribution *type*. Adding one means writing a new `R/<type>.R` file that implements those methods.

### How dispatch works

A `<dist_spec>` carries its distribution type as the head of its S3 class (e.g. `c("gamma", "dist_spec")`), so your per-type methods dispatch on it directly and read parameters from `x$parameters` (or `x$pmf` for the nonparametric family). The framework handles the shared work: validating the number of samples, and resolving a distribution whose parameters are themselves priors. An uncertain distribution is given an extra `"uncertain"` class, so `mean.uncertain()`/`sample_dist.uncertain()` intercept it before your method runs. As a result **your per-type methods only ever see fixed, numeric parameters and are written as plain functions**.

### The methods

Create `R/<type>.R` and implement the methods that apply. Only `natural_params()` and `lower_bounds()` are always required. `mean()`/`sd()` need a closed form, `sample_dist()` gives random draws, `dist_cdf()` is only for distributions that can be discretised, and `to_natural()` is needed only if your constructor accepts an alternative parameterisation (e.g. `mean`/`sd`) that must be converted to the natural parameters.

```r
# R/mydist.R -- methods for the "mydist" distribution. Each dispatches on the
# "mydist" class of a `<dist_spec>` and reads fixed parameters from
# `x$parameters`. Uncertainty and validation are handled by the framework, so
# these methods are pure.

# Required: the names of the natural (estimated) parameters, in order.
#' @exportS3Method
natural_params.mydist <- function(x) c("param1", "param2")

# Required: the lower bound of each parameter (include any `mean`/`sd`
# alternative parameterisation the constructor accepts).
#' @exportS3Method
lower_bounds.mydist <- function(x) {
  c(param1 = 0, param2 = 0)
}

# Optional: the analytic mean. Omit if there is no closed form.
#' @method mean mydist
#' @export
mean.mydist <- function(x, ...) {
  x$parameters$param1
}

# Optional: the analytic standard deviation. Omit if there is no closed form.
#' @method sd mydist
#' @export
sd.mydist <- function(x, ...) {
  x$parameters$param2
}

# Optional: random draws, using the family's base-R generator. A composite
# (multi-component) distribution is sampled per component automatically.
#' @importFrom stats rmydist
#' @exportS3Method
sample_dist.mydist <- function(x, n, ...) {
  rmydist(n, x$parameters$param1, x$parameters$param2)
}

# Optional (alternative parameterisations): convert the parameters the
# constructor accepts (e.g. `mean`/`sd`) to the natural parameters. Take the
# parameter means from `x$parameters` and return a named list.
#' @exportS3Method
to_natural.mydist <- function(x) {
  ux <- lapply(x$parameters, mean)
  list(param1 = ux$param1, param2 = ux$param2)
}

# Optional (discretisation): the CDF as a *function* whose arguments match the
# natural parameters (e.g. a base-R `p*` function such as `pgamma`). Provide this
# only if the distribution can be discretised; omit it otherwise (it then errors
# informatively via `dist_cdf.default()`).
#' @exportS3Method
dist_cdf.mydist <- function(x) pmydist

# Optional (bespoke discretisation): if your distribution discretises in a
# special way rather than through a CDF (as the point-mass `fixed` does), provide
# a `discrete_pmf()` method instead of `dist_cdf()`:
#
# #' @exportS3Method
# discrete_pmf.mydist <- function(x, max_value, ...) {
#   ## return a numeric PMF vector computed from `x$parameters`
# }
```

### Steps

1. File an issue describing the distribution (see [Big changes](#big-changes)).
2. Create `R/<type>.R` with the methods above (copy the template, replacing `mydist` with your type name).
3. Add a user-facing constructor in `R/dist_spec.R`, following the existing pattern (see e.g. `Exp()`), and document it under the shared `Distributions` help topic:

    ```r
    MyDist <- function(param1, param2, ...) {
      params <- as.list(environment())
      new_dist_spec(params, "mydist", ...)
    }
    ```

4. Run `devtools::document()` so the new S3 methods are registered in `NAMESPACE`.
5. Add tests under `tests/testthat/` and a bullet to `NEWS.md`.
6. Check locally with `devtools::test()`, `lintr::lint_package()` and `devtools::check()`.

## Code of Conduct

Please note that the `{distspec}` project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this
project you agree to abide by its terms.
