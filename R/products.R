#' @title Product-related API functions

#' Get metadata about a specified product
#' @description Corresponds to, for example: https://api.municode.com/Products/name?clientId=12053&productName=code+of+ordinances
#' @param client_id A unique identifier for a client
#' @param product_name The name of a product type, e.g., "Code of Ordinances"
#' @export
#'
#' @examples
#' \dontrun{
#' get_product_metadata(client_id = 12053, product_name = "Code of Ordinances")
#' }
get_product_metadata <- function(client_id, product_name) {
  product_name <- product_name %>%
    stringr::str_replace_all(" ", "+") %>%
    stringr::str_to_lower()

  result <-
    build_endpoint(
      domain = "Products",
      subdomain = "name",
      parameters = c(clientId = client_id, productName = product_name)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    tidyr::unnest_wider(ContentType) %>%
    transform_nested_client() %>%
    janitor::clean_names() %>%
    dplyr::select(
      product_id,
      product_name,
      dplyr::matches("client")) %>%
    dplyr::select(-c(client_pop_range_id, client_classification_id, client_show_advance_sheet, dplyr::matches("client_library|meetings"))) %>%
    dplyr::rename_with(~ stringr::str_replace_all(.x, "client_client", "client")) %>%
    dplyr::mutate(dplyr::across(dplyr::where(is.list), unlist))

  return(result)
}
