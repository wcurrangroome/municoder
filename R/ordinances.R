#' @title Ordinance-related API functions (historical ordinance versions)

#' Return information about all ordinances of a given type for a given year
#' @description Corresponds to, for example: https://api.municode.com/CoreContent/Ordinances?nodeId=2023&productId=12429
#' @param node_id The year for which ordinances are requested. Optional; when
#'   omitted the response is the top-level index rather than a list of ordinances.
#' @param product_id A unique code identifying a product (e.g., a zoning ordinance)
#'
#' @returns A dataframe comprising ordinances. The shape depends on `node_id`:
#'   when the response contains nested list elements (typically when `node_id`
#'   is supplied) each ordinance becomes a row; otherwise the top-level fields
#'   are pivoted into a single row.
#' @export
list_ordinances <- function(node_id = NULL, product_id) {
  result <- build_endpoint(
    domain = "CoreContent",
    subdomain = "Ordinances",
    parameters = c(productId = product_id, nodeId = node_id)) %>%
    get_endpoint() %>%
    tibble::enframe()

  if (any(purrr::map_lgl(result$value, is.list))) {
    result %>%
      tidyr::unnest_longer(value) %>%
      tidyr::unnest_wider(value) %>%
      janitor::clean_names()
  } else {
    result %>%
      tidyr::pivot_wider() %>%
      janitor::clean_names()
  }
}

#' Obtain metadata about a given ordinance over time
#' @description Corresponds to, for example: https://api.municode.com/ordinancesToc?nodeId=2023&productId=12429
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#'
#' @export
#'
#' @examples
#' \dontrun{
#' get_ordinances_toc(node_id = 2023, product_id = 12429)
#' }
get_ordinances_toc <- function(node_id = NULL, product_id) {
  build_endpoint(
    domain = "ordinancesToc",
    parameters = c(nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    janitor::clean_names() %>%
    tidyr::unnest_wider(data) %>%
    dplyr::mutate(dplyr::across(.cols = -children, unlist))
}

#' Get the ancestors of a given node in an ordinance's Table of Contents
#' @description Corresponds to, for example: https://api.municode.com/ordinancesToc/breadcrumb?nodeId=2023&productId=12429
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#'
#' @export
get_ordinance_ancestors <- function(node_id, product_id) {
  build_endpoint(
    domain = "ordinancesToc",
    subdomain = "breadcrumb",
    parameters = c(nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    tidyr::unnest_wider(Node) %>%
    tidyr::unnest_longer(Ancestors) %>%
    tidyr::unnest_longer(Ancestors) %>%
    janitor::clean_names() %>%
    dplyr::select(id, ancestors, ancestors_id)
}

#' Get the children of a given node in an ordinance's Table of Contents
#' @description Corresponds to, for example: https://api.municode.com/ordinancesToc/children?productId=12429&nodeId=2023
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#' @export
get_ordinance_children <- function(node_id, product_id) {
  build_endpoint(
    domain = "ordinancesToc",
    subdomain = "children",
    parameters = c(nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::unnest_wider(value) %>%
    tidyr::unnest_wider(Data)
}
