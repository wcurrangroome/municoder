#' @title Client-related API functions

#' Returns metadata about a given client
#' @description Corresponds to, for example: https://api.municode.com/Clients/name?stateAbbr=VA&clientName=Alexandria
#' @param state_abbreviation A two-character state code
#' @param client_name The name of a given client
#'
#' @returns A dataframe of metadata about the specified client
#' @export
#'
#' @examples
#' \dontrun{
#' get_client_metadata("VA", "Alexandria")
#' }
get_client_metadata <- function(state_abbreviation, client_name) {
  result <-
    build_endpoint(
      domain = "Clients",
      subdomain = "name",
      parameters = c(stateAbbr = state_abbreviation, clientName = client_name)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    transform_nested_state() %>%
    janitor::clean_names()

  return(result)
}

#' Return metadata for all Municode clients in a given state
#' @description Corresponds to, for example: https://api.municode.com/Clients/stateAbbr?stateAbbr=VA
#' @param state_abbreviation A two-character state code
#'
#' @returns A dataframe of clients
#' @export
#'
#' @examples
#' \dontrun{
#' get_clients_in_state("VA")
#' }
get_clients_in_state <- function(state_abbreviation) {
  result <-
    build_endpoint(
      domain = "Clients",
      subdomain = "stateAbbr",
      parameters = c(stateAbbr = state_abbreviation)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::unnest_wider(value) %>%
    tidyr::unnest_wider(State) %>%
    janitor::clean_names() %>%
    clean_client_columns()

  return(result)
}

#' Obtain products available for a jurisdiction
#' @description Corresponds to, for example: https://api.municode.com/ClientContent/12053
#' @param client_id A code corresponding to a given client; this can be obtained from `get_clients_in_state()`
#'
#' @returns A dataframe with metadata about each product for a client (e.g., code of ordinances, zoning, etc.)
#' @export
#'
#' @examples
#' \dontrun{
#' get_client_products(980) ## Alexandria, VA
#' }
get_client_products <- function(client_id) {
  raw_result <-
    build_endpoint(
      domain = "ClientContent") %>%
      stringr::str_c("/", client_id) %>%
    get_endpoint()  %>%
    tibble::enframe() %>%
    tidyr::pivot_wider()

  # Check if codes column exists
  if (!"codes" %in% names(raw_result)) {
    stop(sprintf(
      "Failed to fetch products for client_id %s. Client may not exist or have no products available.",
      client_id
    ), call. = FALSE)
  }

  result <- raw_result %>%
    ## selecting only codes; not including "features" nor "munidocs" in the returned data
    dplyr::select(codes) %>%
    tidyr::unnest_longer(codes) %>%
    tidyr::unnest_wider(codes) %>%
    janitor::clean_names()

  return(result)
}
