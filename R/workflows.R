#' @title Workflow helper functions for common multi-step operations

#' Resolve a client_id from a state and client name, erroring if not found
#' @param state_abbreviation Two-character state code
#' @param client_name Name of the municipality
#' @return A single client_id
#' @keywords internal
resolve_client_id <- function(state_abbreviation, client_name) {
  client_id <- get_client_metadata(state_abbreviation, client_name)$client_id

  if (is.null(client_id) || length(client_id) == 0) {
    stop(sprintf(
      "Could not find client '%s' in state '%s'",
      client_name, state_abbreviation
    ), call. = FALSE)
  }

  client_id
}

#' Resolve a product_id from a client_id and product name, erroring if not found
#' @param client_id A unique identifier for a client
#' @param product_name Name of the product
#' @param client_name Name of the municipality, used only for the error message
#' @return A single product_id
#' @keywords internal
resolve_product_id <- function(client_id, product_name, client_name) {
  product_id <- get_product_metadata(client_id, product_name)$product_id

  if (is.null(product_id) || length(product_id) == 0) {
    stop(sprintf(
      "Could not find product '%s' for client '%s'",
      product_name, client_name
    ), call. = FALSE)
  }

  product_id
}

#' Get ordinance section content in one step
#' @description Convenience function that chains together multiple API calls to retrieve
#' ordinance section content given just the jurisdiction, product name, and node ID.
#' @param state_abbreviation Two-character state code (e.g., "VA")
#' @param client_name Name of the municipality (e.g., "Alexandria")
#' @param product_name Name of the product (e.g., "Zoning", "Code of Ordinances")
#' @param node_id Unique identifier for the section within the ordinance
#' @return A dataframe with the content and metadata for the specified section
#' @export
#'
#' @examples
#' \dontrun{
#' # Get a section from Alexandria's zoning ordinance
#' content <- get_ordinance_section(
#'   state_abbreviation = "VA",
#'   client_name = "Alexandria",
#'   product_name = "Zoning",
#'   node_id = "ARTIIIREZORE"
#' )
#' }
get_ordinance_section <- function(state_abbreviation, client_name, product_name, node_id) {
  client_id <- resolve_client_id(state_abbreviation, client_name)
  product_id <- resolve_product_id(client_id, product_name, client_name)

  get_section_text(node_id, product_id)
}

#' Get full table of contents for an ordinance in one step
#' @description Convenience function that retrieves the complete table of contents
#' for an ordinance given just the jurisdiction and product name.
#' @param state_abbreviation Two-character state code (e.g., "VA")
#' @param client_name Name of the municipality (e.g., "Alexandria")
#' @param product_name Name of the product (e.g., "Zoning", "Code of Ordinances")
#' @return A dataframe with the table of contents
#' @export
#'
#' @examples
#' \dontrun{
#' # Get table of contents for Alexandria's zoning ordinance
#' toc <- get_ordinance_toc(
#'   state_abbreviation = "VA",
#'   client_name = "Alexandria",
#'   product_name = "Zoning"
#' )
#' }
get_ordinance_toc <- function(state_abbreviation, client_name, product_name) {
  client_id <- resolve_client_id(state_abbreviation, client_name)
  product_id <- resolve_product_id(client_id, product_name, client_name)

  job_id <- get_current_version(product_id)$id

  if (is.null(job_id) || length(job_id) == 0) {
    stop(sprintf(
      "Could not find latest job for product '%s'",
      product_name
    ), call. = FALSE)
  }

  get_codes_toc(job_id, product_id)
}

#' Get all products for a jurisdiction in one step
#' @description Convenience function to get all available products (ordinances)
#' for a jurisdiction given just the state and municipality name.
#' @param state_abbreviation Two-character state code (e.g., "VA")
#' @param client_name Name of the municipality (e.g., "Alexandria")
#' @return A dataframe with all products available for the jurisdiction
#' @export
#'
#' @examples
#' \dontrun{
#' # Get all products for Alexandria, VA
#' products <- get_jurisdiction_products(
#'   state_abbreviation = "VA",
#'   client_name = "Alexandria"
#' )
#' }
get_jurisdiction_products <- function(state_abbreviation, client_name) {
  client_id <- resolve_client_id(state_abbreviation, client_name)

  get_client_products(client_id)
}
