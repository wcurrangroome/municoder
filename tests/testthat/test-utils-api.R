test_that("build_endpoint constructs URLs correctly", {
  # Test basic endpoint
  expect_equal(
    build_endpoint("States"),
    "https://api.municode.com/States"
  )

  # Test with subdomain
  expect_equal(
    build_endpoint("States", subdomain = "abbr"),
    "https://api.municode.com/States/abbr"
  )

  # Test with parameters
  expect_equal(
    build_endpoint("States", parameters = c(stateAbbr = "VA")),
    "https://api.municode.com/States?stateAbbr=VA"
  )

  # Test with subdomain and parameters
  expect_equal(
    build_endpoint("States", subdomain = "abbr", parameters = c(stateAbbr = "VA")),
    "https://api.municode.com/States/abbr?stateAbbr=VA"
  )

  # Test with multiple parameters
  result <- build_endpoint("Clients", subdomain = "name",
                          parameters = c(stateAbbr = "VA", clientName = "Alexandria"))
  expect_true(grepl("stateAbbr=VA", result))
  expect_true(grepl("clientName=Alexandria", result))

  # Test with NULL parameters
  expect_equal(
    build_endpoint("States", parameters = c(foo = NULL, bar = "test")),
    "https://api.municode.com/States?bar=test"
  )

  # Test with NA parameters
  expect_equal(
    build_endpoint("States", parameters = c(foo = NA, bar = "test")),
    "https://api.municode.com/States?bar=test"
  )
})

test_that("get_endpoint handles errors gracefully", {
  # Test with invalid URL
  expect_error(
    get_endpoint("https://api.municode.com/InvalidEndpoint"),
    "Failed to fetch from Municode API"
  )
})

test_that("get_endpoint returns data for valid endpoints", {
  skip_on_cran()
  skip_if_offline()

  # Test with a known working endpoint
  result <- get_endpoint("https://api.municode.com/States")
  expect_type(result, "list")
  expect_gt(length(result), 0)
})

test_that("get_endpoint respects max_retries parameter", {
  # This is difficult to test without mocking, but we can verify the parameter exists
  expect_error(
    get_endpoint("https://invalid.municode.fake", max_retries = 1),
    "Failed to fetch"
  )
})
