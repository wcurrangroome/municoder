test_that("get_clients_in_state returns dataframe for valid state", {
  skip_on_cran()
  skip_if_offline()

  result <- get_clients_in_state("VA")

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true("client_id" %in% names(result) || "id" %in% names(result))
  expect_true("client_name" %in% names(result) || "name" %in% names(result))
})

test_that("get_clients_in_state filters unwanted columns", {
  skip_on_cran()
  skip_if_offline()

  result <- get_clients_in_state("VA")

  expect_false("classification" %in% names(result))
  expect_false("pop_range" %in% names(result))
  expect_false("library" %in% names(result))
  expect_false("meetings" %in% names(result))
})

test_that("get_clients_in_state handles different states", {
  skip_on_cran()
  skip_if_offline()

  va_result <- get_clients_in_state("VA")
  ca_result <- get_clients_in_state("CA")

  expect_s3_class(va_result, "data.frame")
  expect_s3_class(ca_result, "data.frame")
  expect_gt(nrow(ca_result), nrow(va_result))  # CA likely has more clients
})

test_that("get_client_metadata returns data for valid client", {
  skip_on_cran()
  skip_if_offline()

  result <- get_client_metadata("VA", "Alexandria")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_true("client_id" %in% names(result) || "id" %in% names(result))
})

test_that("get_client_metadata handles invalid client names", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_client_metadata("VA", "NonexistentCity12345"),
    "Failed to fetch|Can't compute column|NULL"
  )
})

test_that("get_client_products returns products for valid client", {
  skip_on_cran()
  skip_if_offline()

  # Using known client_id for Alexandria, VA
  result <- get_client_products(980)

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true("product_id" %in% names(result) || "id" %in% names(result))
  expect_true("product_name" %in% names(result) || "name" %in% names(result))
})

test_that("get_client_products handles invalid client_id", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_client_products(999999999),
    "Failed to fetch|Can't compute column|Can't select columns|doesn't exist"
  )
})
