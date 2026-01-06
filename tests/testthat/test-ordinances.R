test_that("list_ordinances returns ordinances", {
  skip_on_cran()
  skip_if_offline()

  result <- list_ordinances(product_id = 12429, node_id = "2023")

  expect_s3_class(result, "data.frame")
})

test_that("list_ordinances works without node_id", {
  skip_on_cran()
  skip_if_offline()

  result <- list_ordinances(product_id = 12429)

  expect_s3_class(result, "data.frame")
})

test_that("get_ordinances_toc returns table of contents", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ordinances_toc(product_id = 12429, node_id = 2023)

  expect_s3_class(result, "data.frame")
  expect_true("id" %in% names(result))
})

test_that("get_ordinances_toc handles NA node_id", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ordinances_toc(product_id = 12429, node_id = NA)

  expect_s3_class(result, "data.frame")
})

test_that("get_ordinance_ancestors returns ancestors", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ordinance_ancestors(product_id = 12429, node_id = 2023)

  expect_s3_class(result, "data.frame")
  expect_true("id" %in% names(result) || "ancestors_id" %in% names(result))
})

test_that("get_ordinance_children returns child nodes", {
  skip_on_cran()
  skip_if_offline()

  result <- get_ordinance_children(product_id = 12429, node_id = 2023)

  expect_s3_class(result, "data.frame")
})

test_that("get_ordinances functions handle invalid product_id", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_ordinances_toc(product_id = 999999999),
    "Failed to fetch|Can't compute column"
  )
})

test_that("list_ordinances handles invalid parameters", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    list_ordinances(product_id = 999999999, node_id = "INVALID"),
    "Failed to fetch|Can't compute column"
  )
})
