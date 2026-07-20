# Collapsing (convolving) consecutive nonparametric distributions within a
# composite <dist_spec>.

#' @export
collapse <- function(x, ...) {
  UseMethod("collapse")
}
#' Collapse nonparametric distributions in a <dist_spec>
#'
#' @name collapse
#' @description
#' This convolves any consecutive nonparametric distributions contained
#' in the <dist_spec>.
#' @param x A `<dist_spec>`
#' @param ... ignored
#' @return A `<dist_spec>` where consecutive nonparametric distributions
#' have been convolved
#' @importFrom cli cli_abort
#' @method collapse dist_spec
#' @seealso [discretise()] to produce the nonparametric components this
#'   convolves. The `vignette("distspec")` shows the full
#'   `get_pmf(collapse(discretise(d1 + d2)))` pipeline.
#' @export
#' @examples
#' # A fixed gamma distribution with mean 5 and sd 1.
#' dist1 <- Gamma(mean = 5, sd = 1, max = 20)
#'
#' # An uncertain lognormal distribution with meanlog and sdlog normally
#' # distributed as Normal(3, 0.5) and Normal(2, 0.5) respectively
#' dist2 <- LogNormal(
#'   meanlog = Normal(3, 0.5),
#'   sdlog = Normal(2, 0.5),
#'   max = 20
#' )
#'
#' # The sum of two distributions
#' collapse(discretise(dist1 + dist2, strict = FALSE))
collapse.dist_spec <- function(x, ...) {
  x
}
#' @method collapse multi_dist_spec
#' @export
collapse.multi_dist_spec <- function(x, ...) {
  ## get nonparametric distributions
  nonparametric <- vapply(
    seq_along(x), get_distribution,
    x = x, character(1)
  ) == "nonparametric"
  ## find consecutive nonparametric distributions
  consecutive <- rle(nonparametric)
  ids <- unique(c(1, cumsum(consecutive$lengths[-length(consecutive$lengths)])))
  ## find ids of nonparametric distributions that are collapsable
  ## (i.e. have other nonparametric distributions followign them)
  collapseable <- ids[consecutive$values & (consecutive$lengths > 1)]
  ## identify ids of distributions that follow the collapseable distributions
  next_ids <- lapply(collapseable, function(id) {
    ids[id] + seq_len(consecutive$lengths[id] - 1)
  })
  for (id in collapseable) {
    ## collapse distributions
    for (next_id in next_ids[id]) {
      x[[ids[id]]]$pmf <- stable_convolve(
        get_pmf(x[[ids[id]]]), rev(get_pmf(x[[next_id]]))
      )
    }
  }
  ## remove collapsed pmfs
  x[unlist(next_ids)] <- NULL
  ## if wev have collapsed all we turn into a single dist_spec
  if ((length(x) == 1) && is(x[[1]], "dist_spec")) x <- x[[1]]
  x
}
