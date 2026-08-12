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
  ## The API matches product names case-insensitively. Spaces are left intact;
  ## build_endpoint() percent-encodes query values, so manual substitution is
  ## both unnecessary and wrong (it would encode the literal "+").
  product_name <- stringr::str_to_lower(product_name)

  response <-
    build_endpoint(
      domain = "Products",
      subdomain = "name",
      parameters = c(clientId = client_id, productName = product_name)) %>%
    get_endpoint()

  ## The API now wraps this endpoint's payload in an envelope:
  ## {IsSuccess, IsError, Message, Model}. The product fields live in Model.
  if (!is.null(response$Model) || "IsSuccess" %in% names(response)) {
    if (isTRUE(response$IsError) || is.null(response$Model)) {
      stop(
        "Municode API returned an error for client_id ", client_id,
        ", product_name '", product_name, "': ", response$Message)
    }
    response <- response$Model
  }

  result <-
    response %>%
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
    ## Keep non-list columns, plus any list column whose every element is a
    ## single scalar (checking all rows, not just the first, avoids ragged
    ## columns slipping through and misaligning on a later unlist).
    dplyr::select(dplyr::where(~ !is.list(.x) || all(lengths(.x) == 1)))

  result
}
