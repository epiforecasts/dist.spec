test_that("a normal is specified via its natural mean and sd", {
  result <- Normal(mean = 4, sd = 2)
  expect_equal(get_distribution(result), "normal")
  expect_equal(get_parameters(result), list(mean = 4, sd = 2))
})

test_that("distributions with vector-valued parameters compare correctly", {
  expect_true(Normal(mean = c(1, 2), sd = 1) == Normal(mean = c(1, 2), sd = 1))
  expect_false(Normal(mean = c(1, 2), sd = 1) == Normal(mean = c(1, 3), sd = 1))
  expect_false(
    Normal(mean = c(1, 2), sd = 1) == Normal(mean = c(1, 2, 3), sd = 1)
  )
  expect_true(
    Normal(mean = c(1, 2), sd = 1) != Normal(mean = c(1, 3), sd = 1)
  )
})
