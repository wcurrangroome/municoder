#' @title API utility functions for municode.com
#' @description Internal functions for building endpoints and making API calls
#' @keywords internal

#' Build an API endpoint URL
#' @param domain The first component of the API endpoint after base api.municode.com/
#' @param subdomain The second component of the API endpoint
#' @param parameters Named vector of parameter-value pairs
#' @return Complete API endpoint URL
#' @keywords internal
build_endpoint <- function(domain, subdomain = NULL, parameters = NULL) {
  # Build base URL
  base_url <- "https://api.municode.com/"

  # Build path
  path_parts <- c(domain, subdomain)
  path <- paste(stats::na.omit(path_parts), collapse = "/")

  # Combine base and path
  url <- paste0(base_url, path)

  # Add query parameters if provided
  if (!is.null(parameters)) {
    # Remove NULL parameters
    parameters <- parameters[!sapply(parameters, is.null)]
    parameters <- parameters[!is.na(parameters)]

    if (length(parameters) > 0) {
      params_str <- paste(
        names(parameters),
        sapply(parameters, as.character),
        sep = "=",
        collapse = "&"
      )
      url <- paste0(url, "?", params_str)
    }
  }

  return(url)
}

#' Send a GET request to a municode API endpoint
#' @param endpoint An API endpoint URL
#' @param max_retries Maximum number of retry attempts (default 3)
#' @return Parsed JSON response
#' @keywords internal
get_endpoint <- function(endpoint, max_retries = 3) {
  tryCatch({
    result <- endpoint %>%
      httr2::request() %>%
      httr2::req_retry(max_tries = max_retries) %>%
      httr2::req_error(is_error = function(resp) FALSE) %>%
      httr2::req_perform()

    # Check for HTTP errors
    if (httr2::resp_is_error(result)) {
      status <- httr2::resp_status(result)
      stop(sprintf(
        "Municode API request failed (HTTP %d).\nEndpoint: %s",
        status, endpoint
      ), call. = FALSE)
    }

    # Parse JSON response
    parsed <- httr2::resp_body_json(result)

    # Validate response
    if (is.null(parsed)) {
      warning(sprintf(
        "API returned NULL response for endpoint: %s",
        endpoint
      ), call. = FALSE)
    }

    return(parsed)

  }, error = function(e) {
    stop(sprintf(
      "Failed to fetch from Municode API.\nEndpoint: %s\nError: %s",
      endpoint, conditionMessage(e)
    ), call. = FALSE)
  })
}
