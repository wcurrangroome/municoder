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

  result <- raw_result %>%
    tibble::enframe() %>%
    tidyr::unnest_wider(value) %>%
    janitor::clean_names()

  return(result)
}

#' Get the current version of a product
#' @description Corresponds to, for example: https://api.municode.com/Jobs/latest/12429
#' Returns the current version of a product (e.g., the current zoning ordinance, reflecting amendments)
#' @param product_id A unique identifier for a product
#' @export
get_current_version <- function(product_id) {
  ## Some products (e.g., Salem, OR / product_id 15441) return an empty
  ## `Product` object from /Jobs/latest, which means downstream nested
  ## fields like `ProductContentType` are absent. Unnest each nested
  ## column only when it exists and has content.
  safe_unnest_wider <- function(df, col, names_sep = NULL) {
    if (!col %in% names(df)) return(df)
    val <- df[[col]]
    if (is.list(val) && all(lengths(val) == 0)) {
      df[[col]] <- NULL
      return(df)
    }
    tidyr::unnest_wider(df, dplyr::all_of(col), names_sep = names_sep)
  }

  result <-
    build_endpoint(
      domain = "Jobs",
      subdomain = "latest") %>%
    stringr::str_c("/", product_id) %>%
    get_endpoint() %>%
    tibble::enframe()  %>%
    tidyr::pivot_wider() %>%
    safe_unnest_wider("Product", names_sep = "") %>%
    safe_unnest_wider("ProductContentType", names_sep = "_") %>%
    safe_unnest_wider("ProductFeatures") %>%
    safe_unnest_wider("ProductClient") %>%
    safe_unnest_wider("State") %>%
    janitor::clean_names() %>%
    dplyr::mutate(dplyr::across(.cols = dplyr::where(is.list), unlist))

  return(result)
}
