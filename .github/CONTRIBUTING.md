# Contributing to `{dist.spec}`

This outlines how to propose a change to `{dist.spec}`. In general, we accept contributions
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

*   Fork the package and clone onto your computer. If you haven't done this before, we recommend using `usethis::create_from_github("epiforecasts/dist.spec", fork = TRUE)`.
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

## Code of Conduct

Please note that the `{dist.spec}` project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this
project you agree to abide by its terms.
