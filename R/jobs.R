#' @title Job-related API functions

#' Returns data on all jobs for a given product
#' @description Corresponds to, for example: https://api.municode.com/Jobs/product/12429
#' Returns all historical versions of a product (e.g., all historical versions of the zoning ordinance)
#' @param product_id A unique identifier for a product
#'
#' @export
get_jobs_product <- function(product_id) {
  result <-
    build_endpoint(
      domain = "Jobs",
      subdomain = "product") %>%
    stringr::str_c("/", product_id) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::unnest_wider(value) %>%
    janitor::clean_names()

  return(result)
}

#' Get data on the most recent job
#' @description Corresponds to, for example: https://api.municode.com/Jobs/latest/12429
#' Returns the current version of a product (e.g., the current zoning ordinance, reflecting amendments)
#' @param product_id A unique identifier for a product
#' @export
get_jobs_latest <- function(product_id) {
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
