test_that("transform_list_response converts lists to dataframes", {
  # Create a mock API response (avoid 'name' column to prevent conflicts with enframe)
  mock_response <- list(
    list(id = 1, title = "Test1", status = "A"),
    list(id = 2, title = "Test2", status = "B")
  )

  result <- municoder:::transform_list_response(mock_response)

  expect_s3_class(result, "data.frame")
  expect_true("id" %in% names(result))
  expect_true("title" %in% names(result))
  expect_equal(nrow(result), 2)
})

test_that("clean_html_content removes HTML tags", {
  html_text <- "<p>This is a test</p><br>With HTML"
  result <- municoder:::clean_html_content(html_text)

  expect_false(grepl("<", result))
  expect_false(grepl(">", result))
  expect_true(grepl("This is a test", result))
})

test_that("clean_html_content removes &nbsp entities", {
  html_text <- "Test&nbsp;with&nbsp;spaces"
  result <- municoder:::clean_html_content(html_text)

  expect_false(grepl("&nbsp", result))
})

test_that("clean_html_content collapses multiple spaces", {
  html_text <- "Test    with    spaces"
  result <- municoder:::clean_html_content(html_text)

  expect_false(grepl("  ", result))
})

test_that("clean_html_content removes newlines", {
  html_text <- "Test\nwith\nnewlines"
  result <- municoder:::clean_html_content(html_text)

  expect_false(grepl("\n", result))
})

test_that("clean_client_columns removes specified columns", {
  test_df <- data.frame(
    client_id = 1,
    client_name = "Test",
    classification = "City",
    pop_range = "Large",
    library = "Yes",
    meetings = "Weekly",
    advance = "High",
    other_column = "Keep"
  )

  result <- municoder:::clean_client_columns(test_df)

  expect_false("classification" %in% names(result))
  expect_false("pop_range" %in% names(result))
  expect_false("library" %in% names(result))
  expect_false("meetings" %in% names(result))
  expect_false("advance" %in% names(result))
  expect_true("client_id" %in% names(result))
  expect_true("client_name" %in% names(result))
  expect_true("other_column" %in% names(result))
})
