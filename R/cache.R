#' @title Cached versions of API functions for improved performance

# Create package environment for cache storage
.municoder_cache <- new.env(parent = emptyenv())

#' Get states with caching
#' @description Cached version of get_states(). States rarely change, so results are cached indefinitely.
#' @returns A dataframe with three columns: `state_id`, `state_name`, `state_abbreviation.`
#' @export
get_states_cached <- function() {
  if (!exists(".get_states_cached", envir = .municoder_cache)) {
    assign(".get_states_cached", memoise::memoise(get_states), envir = .municoder_cache)
  }
  get(".get_states_cached", envir = .municoder_cache)()
}

#' Get clients in a state with caching
#' @description Cached version of get_clients_in_state(). Results are cached for 24 hours.
#' @param state_abbreviation A two-character state code
#' @returns A dataframe of clients
#' @export
get_clients_in_state_cached <- function(state_abbreviation) {
  if (!exists(".get_clients_in_state_cached", envir = .municoder_cache)) {
    assign(
      ".get_clients_in_state_cached",
      memoise::memoise(get_clients_in_state, cache = cachem::cache_mem(max_age = 86400)),
      envir = .municoder_cache
    )
  }
  get(".get_clients_in_state_cached", envir = .municoder_cache)(state_abbreviation)
}

#' Get client metadata with caching
#' @description Cached version of get_client_metadata(). Results are cached for 24 hours.
#' @param state_abbreviation A two-character state code
#' @param client_name The name of a given client
#' @returns A dataframe of metadata about the specified client
#' @export
get_client_metadata_cached <- function(state_abbreviation, client_name) {
  if (!exists(".get_client_metadata_cached", envir = .municoder_cache)) {
    assign(
      ".get_client_metadata_cached",
      memoise::memoise(get_client_metadata, cache = cachem::cache_mem(max_age = 86400)),
      envir = .municoder_cache
    )
  }
  get(".get_client_metadata_cached", envir = .municoder_cache)(state_abbreviation, client_name)
}

#' Get client content with caching
#' @description Cached version of get_client_content(). Results are cached for 6 hours.
#' @param client_id A code corresponding to a given client
#' @returns A dataframe with metadata about each product for a client
#' @export
get_client_content_cached <- function(client_id) {
  if (!exists(".get_client_content_cached", envir = .municoder_cache)) {
    assign(
      ".get_client_content_cached",
      memoise::memoise(get_client_content, cache = cachem::cache_mem(max_age = 21600)),
      envir = .municoder_cache
    )
  }
  get(".get_client_content_cached", envir = .municoder_cache)(client_id)
}

#' Get product metadata with caching
#' @description Cached version of get_product_metadata(). Results are cached for 6 hours.
#' @param client_id A unique identifier for a client
#' @param product_name The name of a product type
#' @export
get_product_metadata_cached <- function(client_id, product_name) {
  if (!exists(".get_product_metadata_cached", envir = .municoder_cache)) {
    assign(
      ".get_product_metadata_cached",
      memoise::memoise(get_product_metadata, cache = cachem::cache_mem(max_age = 21600)),
      envir = .municoder_cache
    )
  }
  get(".get_product_metadata_cached", envir = .municoder_cache)(client_id, product_name)
}

#' Clear all cached API results
#' @description Clears all cached results from the *_cached() functions.
#' Useful when you need fresh data or want to free up memory.
#' @export
#'
#' @examples
#' \dontrun{
#' # Clear all cached data
#' clear_cache()
#' }
clear_cache <- function() {
  if (exists(".get_states_cached", envir = .municoder_cache)) {
    memoise::forget(get(".get_states_cached", envir = .municoder_cache))
  }
  if (exists(".get_clients_in_state_cached", envir = .municoder_cache)) {
    memoise::forget(get(".get_clients_in_state_cached", envir = .municoder_cache))
  }
  if (exists(".get_client_metadata_cached", envir = .municoder_cache)) {
    memoise::forget(get(".get_client_metadata_cached", envir = .municoder_cache))
  }
  if (exists(".get_client_content_cached", envir = .municoder_cache)) {
    memoise::forget(get(".get_client_content_cached", envir = .municoder_cache))
  }
  if (exists(".get_product_metadata_cached", envir = .municoder_cache)) {
    memoise::forget(get(".get_product_metadata_cached", envir = .municoder_cache))
  }
  message("Cache cleared successfully")
  invisible(NULL)
}
