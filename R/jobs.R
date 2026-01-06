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
  result <-
    build_endpoint(
      domain = "Jobs",
      subdomain = "latest") %>%
    stringr::str_c("/", product_id) %>%
    get_endpoint() %>%
    tibble::enframe()  %>%
    tidyr::pivot_wider() %>%
    tidyr::unnest_wider(Product, names_sep = "") %>%
    tidyr::unnest_wider(ProductContentType, names_sep = "_") %>%
    tidyr::unnest_wider(ProductFeatures) %>%
    tidyr::unnest_wider(ProductClient) %>%
    tidyr::unnest_wider(State) %>%
    janitor::clean_names() %>%
    dplyr::mutate(dplyr::across(.cols = dplyr::where(is.list), unlist))

  return(result)
}
