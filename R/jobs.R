#' @title Version-related API functions

#' Returns version history for a given product
#' @description Corresponds to, for example: https://api.municode.com/Jobs/product/12429
#' Returns all historical versions of a product (e.g., all historical versions of the zoning ordinance)
#' @param product_id A unique identifier for a product
#'
#' @export
get_version_history <- function(product_id) {
  raw_result <-
    build_endpoint(
      domain = "Jobs",
      subdomain = "product") %>%
    stringr::str_c("/", product_id) %>%
    get_endpoint()

  # Check if result is empty or invalid
  if (length(raw_result) == 0 || is.null(raw_result)) {
    stop(sprintf(
      "Failed to fetch version history for product_id %s. Product may not exist.",
      product_id
    ), call. = FALSE)
  }

  raw_result %>%
    tibble::enframe() %>%
    tidyr::unnest_wider(value) %>%
    janitor::clean_names()
}

#' Get the current version of a product
#' @description Corresponds to, for example: https://api.municode.com/Jobs/latest/12429
#' Returns the current version of a product (e.g., the current zoning ordinance, reflecting amendments)
#' @param product_id A unique identifier for a product
#' @export
get_current_version <- function(product_id) {
  raw_result <-
    build_endpoint(
      domain = "Jobs",
      subdomain = "latest") %>%
    stringr::str_c("/", product_id) %>%
    get_endpoint()

  if (length(raw_result) == 0 || is.null(raw_result)) {
    stop(sprintf(
      "Failed to fetch current version for product_id %s. Product may not exist.",
      product_id
    ), call. = FALSE)
  }

  ## Drop NULL elements so enframe()/pivot_wider() yield one row per field; the
  ## Municode response schema is not stable (nested objects such as Product,
  ## ProductContentType, ProductFeatures, ProductClient, and State are sometimes
  ## absent or NULL), so unnest only the nested columns that are actually present.
  result <- raw_result %>%
    purrr::compact() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider()

  nested_cols <- c(
    Product = "",
    ProductContentType = "_",
    ProductFeatures = NA_character_,
    ProductClient = NA_character_,
    State = NA_character_)

  for (col in names(nested_cols)) {
    if (col %in% names(result) && is.list(result[[col]])) {
      sep <- nested_cols[[col]]
      if (is.na(sep)) {
        result <- tidyr::unnest_wider(result, dplyr::all_of(col))
      } else {
        result <- tidyr::unnest_wider(result, dplyr::all_of(col), names_sep = sep)
      }
    }
  }

  result %>%
    janitor::clean_names() %>%
    dplyr::mutate(dplyr::across(.cols = dplyr::where(is.list), unlist))
}

#' List the sections that changed in a given version of an ordinance
#' @description Corresponds to, for example: https://api.municode.com/CodesChangedDocs?jobId=494092&productId=15441
#' Returns the set of sections (nodes) that were added or amended in the
#' specified job relative to the preceding version. Useful for tracking
#' ordinance changes over time; pair with [get_version_history()] to walk
#' versions and [get_section_html()] (with `show_changes = TRUE`) to retrieve
#' the redline for each changed node.
#' @param job_id A unique identifier for a job
#' @param product_id A unique identifier for a product
#'
#' @returns A dataframe with one row per changed section and the columns
#'   `node_id`, `title`, `compare_status` (an undocumented change-type code),
#'   and `ancestor_path` (the node's breadcrumb, titles joined by `" > "`).
#'   Returns a zero-row dataframe when the version introduced no changes.
#' @export
#'
#' @examples
#' \dontrun{
#' get_changed_sections(job_id = 494092, product_id = 15441)
#' }
get_changed_sections <- function(job_id, product_id) {
  raw_result <-
    build_endpoint(
      domain = "CodesChangedDocs",
      parameters = c(jobId = job_id, productId = product_id)) %>%
    get_endpoint()

  if (length(raw_result) == 0) {
    return(tibble::tibble(
      node_id = character(),
      title = character(),
      compare_status = integer(),
      ancestor_path = character()))
  }

  raw_result %>%
    tibble::enframe(name = NULL) %>%
    tidyr::unnest_wider(value) %>%
    janitor::clean_names() %>%
    dplyr::mutate(
      ancestor_path = purrr::map_chr(ancestors, function(a)
        paste(purrr::map_chr(a, function(x) as.character(x$Title)), collapse = " > "))) %>%
    dplyr::transmute(
      node_id = as.character(node_id),
      title = as.character(title),
      compare_status,
      ancestor_path)
}
