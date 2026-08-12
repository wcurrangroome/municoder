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
    "Failed to fetch|Municode API request failed|Can't compute column|NULL"
  )
})

test_that("flatten_codes_tree flattens a nested tree to one row per node", {
  tree <- list(
    Id = "ROOT", Heading = "Root", NodeDepth = -1L, HasChildren = TRUE,
    ParentId = NULL, DocOrderId = 0L,
    Data = list(NodeKey = "k0", IsUpdated = FALSE, IsAmended = FALSE,
                HasAmendedDescendant = TRUE, CompareStatus = 0L, DocType = 1L),
    Children = list(
      list(Id = "A", Heading = "Child A", NodeDepth = 0L, HasChildren = FALSE,
           ParentId = "ROOT", DocOrderId = 1L,
           Data = list(NodeKey = "k1", IsUpdated = FALSE, IsAmended = TRUE,
                       HasAmendedDescendant = FALSE, CompareStatus = 2L, DocType = 1L),
           Children = list()),
      list(Id = "B", Heading = "Child B", NodeDepth = 0L, HasChildren = FALSE,
           ParentId = "ROOT", DocOrderId = 2L,
           Data = list(NodeKey = "k2", IsUpdated = FALSE, IsAmended = FALSE,
                       HasAmendedDescendant = FALSE, CompareStatus = 0L, DocType = 1L),
           Children = list())))

  result <- municoder:::flatten_codes_tree(tree)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
  # Root first, then children in order
  expect_equal(result$id, c("ROOT", "A", "B"))
  # NULL ParentId on the root becomes NA, not an error
  expect_equal(result$parent_id, c(NA, "ROOT", "ROOT"))
  expect_true(result$is_amended[result$id == "A"])
  # Everything is unnested -- no residual list columns
  expect_false(any(vapply(result, is.list, logical(1))))
})

test_that("get_section_html show_changes requires job_id and past_job_id", {
  expect_error(
    get_section_html(node_id = "SUHITA", product_id = 15441, show_changes = TRUE),
    "requires both"
  )
})

test_that("get_codes_tree returns a flattened tree with one row per node", {
  skip_on_cran()
  skip_if_offline()

  result <- get_codes_tree(job_id = 494092, node_id = 15441, product_id = 15441)

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 1)
  expect_true(all(c("id", "heading", "node_depth", "parent_id", "is_amended") %in% names(result)))
  expect_false(any(vapply(result, is.list, logical(1))))
})
