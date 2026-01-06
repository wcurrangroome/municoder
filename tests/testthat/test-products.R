test_that("get_product_metadata returns data for valid product", {
  skip_on_cran()
  skip_if_offline()

  # Using known client_id for Alexandria, VA
  result <- get_product_metadata(12053, "Code of Ordinances")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_true("product_id" %in% names(result))
  expect_true("product_name" %in% names(result))
})

test_that("get_product_metadata handles space conversion", {
  skip_on_cran()
  skip_if_offline()

  # Spaces should be converted to +
  result <- get_product_metadata(12053, "Code of Ordinances")

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
})

test_that("get_product_metadata handles case conversion", {
  skip_on_cran()
  skip_if_offline()

  # Should work with different cases
  result1 <- get_product_metadata(12053, "Code of Ordinances")
  result2 <- get_product_metadata(12053, "CODE OF ORDINANCES")

  expect_s3_class(result1, "data.frame")
  expect_s3_class(result2, "data.frame")
})

test_that("get_product_metadata removes unwanted client columns", {
  skip_on_cran()
  skip_if_offline()

  result <- get_product_metadata(12053, "Code of Ordinances")

  expect_false("client_pop_range_id" %in% names(result))
  expect_false("client_classification_id" %in% names(result))
  expect_false("client_show_advance_sheet" %in% names(result))
})

test_that("get_product_metadata handles invalid product names", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_product_metadata(12053, "NonexistentProduct12345"),
    "Failed to fetch|Can't compute column|NULL"
  )
})

test_that("get_product_metadata handles invalid client_id", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_product_metadata(999999999, "Zoning"),
    "Failed to fetch|Can't compute column"
  )
})
