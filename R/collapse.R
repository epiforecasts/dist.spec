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
#' # The maxf the sum of two distributions
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
  ## position of the first distribution in each run
  run_starts <- c(
    1L, cumsum(consecutive$lengths[-length(consecutive$lengths)]) + 1L
  )
  ## runs of two or more nonparametric distributions can be collapsed
  to_collapse <- which(consecutive$values & consecutive$lengths > 1L)
  for (run_i in to_collapse) {
    first <- run_starts[run_i]
    ## convolve each following distribution in the run into the first
    for (j in first + seq_len(consecutive$lengths[run_i] - 1L)) {
      x[[first]]$pmf <- stable_convolve(
        get_pmf(x[[first]]), rev(get_pmf(x[[j]]))
      )
    }
  }
  ## remove collapsed pmfs
  drop <- unlist(lapply(to_collapse, function(run_i) {
    run_starts[run_i] + seq_len(consecutive$lengths[run_i] - 1L)
  }))
  if (length(drop)) x[drop] <- NULL
  ## if wev have collapsed all we turn into a single dist_spec
  if ((length(x) == 1) && is(x[[1]], "dist_spec")) x <- x[[1]]
  x
}
