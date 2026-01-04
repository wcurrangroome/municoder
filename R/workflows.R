#' @title Workflow helper functions for common multi-step operations

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
  # Step 1: Get client metadata
  client_meta <- get_client_metadata(state_abbreviation, client_name)
  client_id <- client_meta$client_id

  if (is.null(client_id) || length(client_id) == 0) {
    stop(sprintf(
      "Could not find client '%s' in state '%s'",
      client_name, state_abbreviation
    ), call. = FALSE)
  }

  # Step 2: Get product metadata
  product_meta <- get_product_metadata(client_id, product_name)
  product_id <- product_meta$product_id

  if (is.null(product_id) || length(product_id) == 0) {
    stop(sprintf(
      "Could not find product '%s' for client '%s'",
      product_name, client_name
    ), call. = FALSE)
  }

  # Step 3: Get content
  content <- get_codes_content(node_id, product_id)

  return(content)
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
  # Step 1: Get client metadata
  client_meta <- get_client_metadata(state_abbreviation, client_name)
  client_id <- client_meta$client_id

  if (is.null(client_id) || length(client_id) == 0) {
    stop(sprintf(
      "Could not find client '%s' in state '%s'",
      client_name, state_abbreviation
    ), call. = FALSE)
  }

  # Step 2: Get product metadata
  product_meta <- get_product_metadata(client_id, product_name)
  product_id <- product_meta$product_id

  if (is.null(product_id) || length(product_id) == 0) {
    stop(sprintf(
      "Could not find product '%s' for client '%s'",
      product_name, client_name
    ), call. = FALSE)
  }

  # Step 3: Get latest job
  job <- get_jobs_latest(product_id)
  job_id <- job$id

  if (is.null(job_id) || length(job_id) == 0) {
    stop(sprintf(
      "Could not find latest job for product '%s'",
      product_name
    ), call. = FALSE)
  }

  # Step 4: Get table of contents
  toc <- get_codes_toc(job_id, product_id)

  return(toc)
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
  # Get client metadata
  client_meta <- get_client_metadata(state_abbreviation, client_name)
  client_id <- client_meta$client_id

  if (is.null(client_id) || length(client_id) == 0) {
    stop(sprintf(
      "Could not find client '%s' in state '%s'",
      client_name, state_abbreviation
    ), call. = FALSE)
  }

  # Get products
  products <- get_client_content(client_id)

  return(products)
}
