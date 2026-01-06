test_that("get_jurisdiction_products returns products", {
  skip_on_cran()
  skip_if_offline()

  result <- get_jurisdiction_products("VA", "Alexandria")

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true("product_id" %in% names(result) || "id" %in% names(result))
  expect_true("product_name" %in% names(result) || "name" %in% names(result))
})

test_that("get_jurisdiction_products handles invalid state", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_jurisdiction_products("ZZ", "InvalidCity"),
    "Could not find client|Failed to fetch"
  )
})

test_that("get_jurisdiction_products handles invalid client name", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_jurisdiction_products("VA", "NonexistentCity12345"),
    "Could not find client|Failed to fetch"
  )
})

test_that("get_jurisdiction_products provides helpful error messages", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_jurisdiction_products("VA", "InvalidName"),
    "Could not find client|Failed to fetch|Unexpected content type"
  )
})

test_that("get_ordinance_toc returns table of contents", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ordinance_toc("VA", "Alexandria", "Zoning")

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true("id" %in% names(result))
  expect_true("heading" %in% names(result) || "toc_heading" %in% names(result))
})

test_that("get_ordinance_toc handles invalid product name", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_ordinance_toc("VA", "Alexandria", "NonexistentProduct"),
    "Could not find product|Failed to fetch"
  )
})

test_that("get_ordinance_toc provides helpful error for missing client", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_ordinance_toc("VA", "InvalidCity", "Zoning"),
    "Could not find client|Failed to fetch|Unexpected content type"
  )
})

test_that("get_ordinance_section returns content", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ordinance_section("VA", "Alexandria", "Zoning", "SUHITA")

  expect_s3_class(result, "data.frame")
  expect_true("id" %in% names(result))
  expect_true("content" %in% names(result))
})

test_that("get_ordinance_section handles invalid node_id", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_ordinance_section("VA", "Alexandria", "Zoning", "INVALID123"),
    "Failed to fetch|Can't compute column"
  )
})

test_that("workflow functions chain correctly", {
  skip_on_cran()
  skip_if_offline()

  # Test that the workflow functions successfully chain API calls
  products <- get_jurisdiction_products("VA", "Alexandria")
  expect_gt(nrow(products), 0)

  toc <- get_ordinance_toc("VA", "Alexandria", "Zoning")
  expect_gt(nrow(toc), 0)

  # Both should succeed if chaining works
  expect_true(TRUE)
})

test_that("workflow functions provide informative errors", {
  skip_on_cran()
  skip_if_offline()

  error_msg <- tryCatch(
    get_jurisdiction_products("VA", "InvalidCity123"),
    error = function(e) conditionMessage(e)
  )

  expect_true(grepl("Could not find client|Failed to fetch|Unexpected content type", error_msg))
})
