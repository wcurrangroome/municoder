#' @title Code-related API functions (current ordinance versions)

#' Fetch and reshape the raw CodesContent response for a node
#' @param node_id A unique identifier for a node within the specified product
#' @param product_id A unique identifier for a product
#' @param job_id Optional job identifier; required when `show_changes = TRUE`
#' @param past_job_id Optional prior job to diff against; required when
#'   `show_changes = TRUE`
#' @param show_changes If `TRUE`, request redline markup comparing `job_id`
#'   against `past_job_id`
#' @return A one-row tibble with one column per top-level response field
#' @keywords internal
fetch_section_result <- function(node_id, product_id, job_id = NULL,
                                 past_job_id = NULL, show_changes = FALSE) {
  parameters <- c(nodeId = node_id, productId = product_id)

  if (isTRUE(show_changes)) {
    if (is.null(job_id) || is.null(past_job_id)) {
      stop("`show_changes = TRUE` requires both `job_id` and `past_job_id`.",
           call. = FALSE)
    }
    parameters <- c(parameters,
                    jobId = job_id, pastJobId = past_job_id, showChanges = "true")
  } else if (!is.null(job_id)) {
    parameters <- c(parameters, jobId = job_id)
  }

  build_endpoint(domain = "CodesContent", parameters = parameters) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider()
}

#' Extract the Docs payload (id, title, content) from a CodesContent response
#' @param result A reshaped CodesContent response from `fetch_section_result()`
#' @return A tibble with cleaned `id`, `title`, and `content` columns
#' @keywords internal
extract_section_docs <- function(result) {
  result %>%
    dplyr::select(Docs) %>%
    tidyr::unnest_longer(Docs) %>%
    tidyr::unnest_wider(Docs) %>%
    janitor::clean_names()
}

#' Get text and metadata for a given node within a given ordinance
#' @description Corresponds to, for example: https://api.municode.com/CodesContent?jobId=426172&nodeId=THZOORALVI&productId=12429
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#' @param job_id Optional job identifier; required when `show_changes = TRUE`
#' @param past_job_id Optional prior job identifier to diff against; required
#'   when `show_changes = TRUE`
#' @param show_changes If `TRUE`, request a redline comparison of `job_id`
#'   against `past_job_id`. Note that `get_section_text()` strips HTML, which
#'   discards the insertion/deletion markup; use [get_section_html()] to retain
#'   the redline in the `content_html` column.
#'
#' @returns A dataframe with the content and metadata pertaining to a specific node within an ordinance
#' @export
#'
#' @examples
#' \dontrun{
#' get_section_text(node_id = "SUHITA", product_id = "12429")
#' }
get_section_text <- function(node_id = NULL, product_id, job_id = NULL,
                             past_job_id = NULL, show_changes = FALSE) {
  result <- fetch_section_result(node_id, product_id, job_id = job_id,
                                 past_job_id = past_job_id, show_changes = show_changes)

  docs <- extract_section_docs(result) %>%
    dplyr::transmute(
      id,
      node_type = "current",
      heading = title,
      content = clean_html_content(content))

  ## Guard on nrow(): a node with no next/previous sibling unnests to a
  ## zero-row tibble, and length() would count columns (always >= 1) and
  ## wrongly enter the branch. Empty siblings collapse to NULL so they
  ## contribute no spurious all-NA columns to the bound result.
  next_node <- result %>%
    dplyr::select(NextNode) %>%
    tidyr::unnest_longer(NextNode)

  next_node <- if (nrow(next_node) > 0) {
    next_node %>%
      tidyr::pivot_wider(names_from = NextNode_id, values_from = NextNode) %>%
      tidyr::unnest_wider(Data) %>%
      dplyr::mutate(dplyr::across(dplyr::everything(), unlist)) %>%
      janitor::clean_names() %>%
      dplyr::mutate(node_type = "next")
  } else {
    NULL
  }

  previous_node <- result %>%
    dplyr::select(PrevNode) %>%
    tidyr::unnest_longer(PrevNode)

  previous_node <- if (nrow(previous_node) > 0) {
    previous_node %>%
      tidyr::pivot_wider(names_from = PrevNode_id, values_from = PrevNode) %>%
      tidyr::unnest_wider(Data) %>%
      dplyr::mutate(dplyr::across(dplyr::everything(), unlist)) %>%
      janitor::clean_names() %>%
      dplyr::mutate(node_type = "previous")
  } else {
    NULL
  }

  dplyr::bind_rows(docs, next_node, previous_node) %>%
    dplyr::select(id, heading, node_type, content, dplyr::everything())
}

#' Get the Table of Contents for an ordinance
#' @description Corresponds to, for example: https://api.municode.com/codesToc?jobId=426172&productId=12429
#' @param job_id A unique identifier for a job
#' @param product_id A unique identifier for a product
#'
#' @returns A dataframe with TOC sections and associated metadata
#' @export
#'
#' @examples
#' \dontrun{
#' result <- get_codes_toc(job_id = 426172, product_id = 12429)
#' }
get_codes_toc <- function(job_id, product_id) {
  result <-
    build_endpoint(
      domain = "CodesToc",
      parameters = c(jobId = job_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe()  %>%
    tidyr::pivot_wider() %>%
    dplyr::select(
      toc_id = Id,
      toc_heading = Heading,
      children = Children) %>%
    tidyr::unnest_longer(children) %>%
    tidyr::unnest_wider(children) %>%
    dplyr::mutate(dplyr::across(.cols = c(dplyr::where(is.list), -Data), unlist)) %>%
    janitor::clean_names() %>%
    dplyr::select(-c(data, node_depth, doc_order_id))
}

#' Recursively flatten a codesToc tree node into a tidy dataframe
#' @param node A node list from the `codesToc/fullTree` response
#' @return A dataframe with one row per node in the subtree rooted at `node`
#' @keywords internal
flatten_codes_tree <- function(node) {
  or_na <- function(x) if (is.null(x)) NA else x
  data <- node$Data

  this_row <- tibble::tibble(
    id = as.character(or_na(node$Id)),
    heading = as.character(or_na(node$Heading)),
    node_depth = or_na(node$NodeDepth),
    parent_id = as.character(or_na(node$ParentId)),
    doc_order_id = or_na(node$DocOrderId),
    has_children = or_na(node$HasChildren),
    node_key = as.character(or_na(data$NodeKey)),
    is_updated = or_na(data$IsUpdated),
    is_amended = or_na(data$IsAmended),
    has_amended_descendant = or_na(data$HasAmendedDescendant),
    compare_status = or_na(data$CompareStatus),
    doc_type = or_na(data$DocType))

  if (length(node$Children) == 0) {
    return(this_row)
  }

  dplyr::bind_rows(c(list(this_row), purrr::map(node$Children, flatten_codes_tree)))
}

#' Get the full table of contents tree for an ordinance in a single request
#' @description Corresponds to, for example: https://api.municode.com/codesToc/fullTree?jobId=494092&nodeId=15441&productId=15441
#'   Unlike [get_section_children()], which returns one level of the hierarchy
#'   per call, this returns the entire nested tree beneath `node_id` in a single
#'   request and flattens it to a tidy dataframe (one row per node). Per-node
#'   amendment flags are included.
#' @param job_id A unique identifier for a job
#' @param node_id A node to use as the root of the returned tree. Pass the
#'   `product_id` to retrieve the whole code.
#' @param product_id A unique identifier for a product
#'
#' @returns A dataframe with one row per node and the columns `id`, `heading`,
#'   `node_depth`, `parent_id`, `doc_order_id`, `has_children`, `node_key`,
#'   `is_updated`, `is_amended`, `has_amended_descendant`, `compare_status`,
#'   and `doc_type`.
#' @export
#'
#' @examples
#' \dontrun{
#' get_codes_tree(job_id = 494092, node_id = 15441, product_id = 15441)
#' }
get_codes_tree <- function(job_id, node_id, product_id) {
  build_endpoint(
    domain = "codesToc",
    subdomain = "fullTree",
    parameters = c(jobId = job_id, nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    flatten_codes_tree()
}

#' Get raw HTML content and markdown for a given node within a given ordinance
#' @description Identical to `get_section_text()` but preserves the raw HTML in a
#'   `content_html` column instead of stripping tags, and adds a `content_markdown`
#'   column with a markdown conversion. This is critical for extracting data from
#'   sections that contain HTML tables (e.g., dimensional standards).
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#' @param job_id Optional job identifier; required when `show_changes = TRUE`
#' @param past_job_id Optional prior job identifier to diff against; required
#'   when `show_changes = TRUE`
#' @param show_changes If `TRUE`, request a redline comparison of `job_id`
#'   against `past_job_id`. The insertion/deletion markup is preserved in the
#'   returned `content_html` column.
#'
#' @returns A dataframe with the raw HTML content and metadata for the specified node.
#'   Columns: `id`, `heading`, `node_type`, `content_html`, `content_markdown`.
#' @export
#'
#' @examples
#' \dontrun{
#' get_section_html(node_id = "SUHITA", product_id = "12429")
#' }
get_section_html <- function(node_id = NULL, product_id, job_id = NULL,
                             past_job_id = NULL, show_changes = FALSE) {
  fetch_section_result(node_id, product_id, job_id = job_id,
                       past_job_id = past_job_id, show_changes = show_changes) %>%
    extract_section_docs() %>%
    dplyr::transmute(
      id,
      node_type = "current",
      heading = title,
      content_html = content,
      content_markdown = html_to_markdown(content))
}

#' Get information about a given node's ancestor(s)
#' @description Corresponds to, for example: https://api.municode.com/codesToc/breadcrumb?jobId=426172&nodeId=THZOORALVI&productId=12429
#' @param job_id A unique identifier for a job
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#'
#' @export
get_section_ancestors <- function(job_id, node_id, product_id) {
  result <-
    build_endpoint(
      domain = "codesToc",
      subdomain = "breadcrumb",
      parameters = c(jobId = job_id, nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    tidyr::unnest_longer(Node) %>%
    tidyr::unnest_longer(Ancestors) %>%
    tidyr::unnest_wider(Ancestors, names_sep = "_") %>%
    janitor::clean_names() %>%
    dplyr::select(
      node,
      id = node_id,
      ancestor_id = ancestors_id)
}

#' Get information about a given node's children
#' @description Corresponds to, for example: https://api.municode.com/codesToc/children?jobId=426172&nodeId=ARTIGERE&productId=12429
#' @param job_id A unique identifier for a job
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#'
#' @export
#' @examples
#' \dontrun{
#' get_section_children(job_id = 426172, node_id = "ARTIGERE", product_id = 12429)
#' }
get_section_children <- function(job_id, node_id, product_id) {
  raw <- build_endpoint(
    domain = "codesToc",
    subdomain = "children",
    parameters = c(jobId = job_id, nodeId = node_id, productId = product_id)) %>%
    get_endpoint()

  if (length(raw) == 0) {
    return(tibble::tibble(
      id = character(),
      heading = character(),
      has_children = logical()))
  }

  result <- raw %>%
    tibble::enframe() %>%
    tidyr::unnest_wider(value)

  if ("Data" %in% names(result)) {
    result <- tidyr::unnest_wider(result, Data)
  }

  janitor::clean_names(result)
}
