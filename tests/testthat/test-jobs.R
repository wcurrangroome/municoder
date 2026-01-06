test_that("get_current_version returns data for valid product_id", {
  skip_on_cran()
  skip_if_offline()

  # Using known product_id for Alexandria Zoning
  result <- get_current_version(12429)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_true("id" %in% names(result))
})

test_that("get_current_version unnests nested structures", {
  skip_on_cran()
  skip_if_offline()

  result <- get_current_version(12429)

  # Should have columns from nested Product, State, etc.
  expect_gt(ncol(result), 5)
  # Should not have list columns
  expect_false(any(sapply(result, is.list)))
})

test_that("get_current_version handles invalid product_id", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_current_version(999999999),
    "Failed to fetch|Can't compute column"
  )
})

test_that("get_version_history returns multiple jobs for product", {
  skip_on_cran()
  skip_if_offline()

  result <- get_version_history(12429)

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true("id" %in% names(result) || "name" %in% names(result))
})

test_that("get_version_history handles invalid product_id", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_version_history(999999999),
    "Failed to fetch|Can't compute column"
  )
})

test_that("get_version_history returns historical versions", {
  skip_on_cran()
  skip_if_offline()

  result <- get_version_history(12429)

  # A product should have at least 1 job (current version)
  expect_gte(nrow(result), 1)
})
