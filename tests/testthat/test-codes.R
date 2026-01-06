test_that("get_codes_toc returns table of contents", {
  skip_on_cran()
  skip_if_offline()

  # Using known job_id and product_id for Alexandria Zoning
  result <- get_codes_toc(job_id = 426172, product_id = 12429)

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true("id" %in% names(result))
  expect_true("heading" %in% names(result) || "toc_heading" %in% names(result))
})

test_that("get_codes_toc removes unwanted columns", {
  skip_on_cran()
  skip_if_offline()

  result <- get_codes_toc(job_id = 426172, product_id = 12429)

  expect_false("data" %in% names(result))
  expect_false("node_depth" %in% names(result))
  expect_false("doc_order_id" %in% names(result))
})

test_that("get_section_text returns content for valid node", {
  skip_on_cran()
  skip_if_offline()

  result <- get_section_text(node_id = "SUHITA", product_id = 12429)

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true("id" %in% names(result))
  expect_true("heading" %in% names(result))
  expect_true("content" %in% names(result))
})

test_that("get_section_text cleans HTML from content", {
  skip_on_cran()
  skip_if_offline()

  result <- get_section_text(node_id = "SUHITA", product_id = 12429)

  if (nrow(result) > 0 && !is.na(result$content[1])) {
    # Content should not contain HTML tags
    expect_false(grepl("<p>", result$content[1]))
    expect_false(grepl("</p>", result$content[1]))
  }
})

test_that("get_section_text includes node_type column", {
  skip_on_cran()
  skip_if_offline()

  result <- get_section_text(node_id = "SUHITA", product_id = 12429)

  expect_true("node_type" %in% names(result))
  expect_true("current" %in% result$node_type)
})

test_that("get_section_ancestors returns ancestors", {
  skip_on_cran()
  skip_if_offline()

  result <- get_section_ancestors(
    job_id = 426172,
    node_id = "ARTIGERE",
    product_id = 12429
  )

  expect_s3_class(result, "data.frame")
  expect_true("ancestor_id" %in% names(result) || "id" %in% names(result))
})

test_that("get_section_children returns child nodes", {
  skip_on_cran()
  skip_if_offline()

  result <- get_section_children(
    job_id = 426172,
    node_id = "ARTIGERE",
    product_id = 12429
  )

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
})

test_that("get_section_text handles invalid node_id", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    get_section_text(node_id = "INVALID123", product_id = 12429),
    "Failed to fetch|Can't compute column|NULL"
  )
})
