test_that("get_states returns a dataframe", {
  skip_on_cran()
  skip_if_offline()

  result <- get_states()

  expect_s3_class(result, "data.frame")
  expect_true("state_id" %in% names(result) || "id" %in% names(result))
  expect_true("state_name" %in% names(result) || "name" %in% names(result))
  expect_true("state_abbreviation" %in% names(result) || "abbreviation" %in% names(result))
  expect_gt(nrow(result), 50)  # Should have at least 50 states/territories
})

test_that("get_states returns consistent data types", {
  skip_on_cran()
  skip_if_offline()

  result <- get_states()

  expect_true(is.numeric(result[[1]]) || is.character(result[[1]]))
})

test_that("get_state_by_abbreviation returns data for valid abbreviation", {
  skip_on_cran()
  skip_if_offline()

  result <- get_state_by_abbreviation("VA")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_true("state_id" %in% names(result) || "id" %in% names(result))
})

test_that("get_state_by_abbreviation accepts uppercase abbreviations", {
  skip_on_cran()
  skip_if_offline()

  result <- get_state_by_abbreviation("CA")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
})

test_that("get_state_by_abbreviation handles invalid abbreviations", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_state_by_abbreviation("ZZ"),
    "Failed to fetch|Can't compute column"
  )
})
