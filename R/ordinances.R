#' @title Ordinance-related API functions (historical ordinance versions)

#' Return information about all ordinances of a given type for a given year
#' @description Corresponds to, for example: https://api.municode.com/CoreContent/Ordinances?nodeId=2023&productId=12429
#' @param product_id A unique code identifying a product (e.g., a zoning ordinance)
#' @param node_id The year for which ordinances are requested
#'
#' @returns A dataframe comprising ordinances
#' @export
list_ordinances <- function(product_id, node_id = NULL) {
  endpoint <- build_endpoint(
    domain = "CoreContent",
    subdomain = "Ordinances",
    parameters = c(productId = product_id, nodeId = node_id))

  result <- endpoint %>%
    get_endpoint() %>%
    tibble::enframe()

  # Handle different response structures based on whether node_id is provided
  if (any(sapply(result$value, is.list))) {
    result <- result %>%
      tidyr::unnest_longer(value) %>%
      tidyr::unnest_wider(value) %>%
      janitor::clean_names()
  } else {
    result <- result %>%
      tidyr::pivot_wider() %>%
      janitor::clean_names()
  }

  return(result)
}

#' Obtain metadata about a given ordinance over time
#' @description Corresponds to, for example: https://api.municode.com/ordinancesToc?nodeId=2023&productId=12429
#' @param product_id A unique identifier for a product
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' get_ordinances_toc(node_id = 2023, product_id = 12429)
#' }
get_ordinances_toc <- function(product_id, node_id = NA) {
  result <-
    build_endpoint(
      domain = "ordinancesToc",
      parameters = c(nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    janitor::clean_names() %>%
    tidyr::unnest_wider(data) %>%
    dplyr::mutate(dplyr::across(.cols = -children, unlist))

  return(result)
}

#' Get the ancestors of a given node in an ordinance's Table of Contents
#' @description Corresponds to, for example: https://api.municode.com/ordinancesToc/breadcrumb?nodeId=2023&productId=12429
#' @param product_id A unique identifier for a product
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#'
#' @export
get_ordinance_ancestors <- function(product_id, node_id) {
  result <-
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

  return(result)
}

#' Get the children of a given node in an ordinance's Table of Contents
#' @description Corresponds to, for example: https://api.municode.com/ordinancesToc/children?productId=12429&nodeId=2023
#' @param product_id A unique identifier for a product
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @export
get_ordinance_children <- function(product_id, node_id) {
  result <-
    build_endpoint(
      domain = "ordinancesToc",
      subdomain = "children",
      parameters = c(nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::unnest_wider(value) %>%
    tidyr::unnest_wider(Data)

  return(result)
}
