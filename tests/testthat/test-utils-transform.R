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

  expect_false(stringr::str_detect(result, "<"))
  expect_false(stringr::str_detect(result, ">"))
  expect_true(stringr::str_detect(result, "This is a test"))
})

test_that("clean_html_content removes &nbsp entities", {
  html_text <- "Test&nbsp;with&nbsp;spaces"
  result <- municoder:::clean_html_content(html_text)

  expect_false(stringr::str_detect(result, "&nbsp"))
})

test_that("clean_html_content collapses multiple spaces", {
  html_text <- "Test    with    spaces"
  result <- municoder:::clean_html_content(html_text)

  expect_false(stringr::str_detect(result, "  "))
})

test_that("clean_html_content removes newlines", {
  html_text <- "Test\nwith\nnewlines"
  result <- municoder:::clean_html_content(html_text)

  expect_false(stringr::str_detect(result, "\n"))
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

test_that("html_to_markdown converts headings, emphasis, and entities", {
  expect_equal(municoder:::html_to_markdown("<h1>Title</h1>"), "# Title")
  expect_equal(municoder:::html_to_markdown("<h2>Sub</h2>"), "## Sub")
  expect_equal(municoder:::html_to_markdown("<p>Hello <b>world</b></p>"), "Hello **world**")
  expect_equal(municoder:::html_to_markdown("<p>a <i>x</i></p>"), "a *x*")
  expect_equal(municoder:::html_to_markdown("a &amp; b"), "a & b")
})

test_that("html_to_markdown renders HTML tables as markdown tables", {
  html <- "<table><tr><th>A</th><th>B</th></tr><tr><td>1</td><td>2</td></tr></table>"
  result <- municoder:::html_to_markdown(html)

  expect_true(stringr::str_detect(result, stringr::fixed("| A | B |")))
  expect_true(stringr::str_detect(result, stringr::fixed("| --- | --- |")))
  expect_true(stringr::str_detect(result, stringr::fixed("| 1 | 2 |")))
})

test_that("convert_html_tables_to_markdown leaves table-free input untouched", {
  expect_equal(
    municoder:::convert_html_tables_to_markdown("no table here"),
    "no table here"
  )
})

test_that("convert_html_tables_to_markdown is vectorized over its input", {
  out <- municoder:::convert_html_tables_to_markdown(c("plain", "also plain"))
  expect_length(out, 2)
  expect_equal(out, c("plain", "also plain"))
})

test_that("clean_html_content strips tags, entities, and newlines together", {
  expect_equal(
    municoder:::clean_html_content("<p>Test&nbsp;text</p>\nLine"),
    "Test textLine"
  )
})
