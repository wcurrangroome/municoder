#' Build an API endpoint URL
#' @param domain The first component of the API endpoint after base api.municode.com/
#' @param subdomain The second component of the API endpoint
#' @param parameters Named vector of parameter-value pairs
#' @return Complete API endpoint URL
#' @keywords internal
build_endpoint <- function(domain, subdomain = NULL, parameters = NULL) {
  path_parts <- c(domain, subdomain)
  path_parts <- path_parts[!is.na(path_parts)]

  ## httr2 percent-encodes path segments and query values, so callers never
  ## need to pre-encode (e.g. client or product names containing spaces).
  ## rlang::exec() splices the variable-length path parts and parameters in,
  ## since req_url_path_append() does not itself support dynamic dots.
  request <- rlang::exec(
    httr2::req_url_path_append,
    httr2::request("https://api.municode.com/"),
    !!!as.list(path_parts))

  if (!is.null(parameters)) {
    parameters <- parameters[!is.na(parameters)]
    if (length(parameters) > 0) {
      request <- rlang::exec(httr2::req_url_query, request, !!!as.list(parameters))
    }
  }

  request$url
}

#' Send a GET request to a municode API endpoint
#' @param endpoint An API endpoint URL
#' @param max_retries Maximum number of retry attempts (default 3)
#' @return Parsed JSON response
#' @keywords internal
get_endpoint <- function(endpoint, max_retries = 3) {
  fail <- function(e) {
    stop(sprintf(
      "Failed to fetch from Municode API.\nEndpoint: %s\nError: %s",
      endpoint, conditionMessage(e)
    ), call. = FALSE)
  }

  ## Connection-level failures (DNS, timeout, refused) and non-JSON bodies are
  ## wrapped via fail(); a genuine HTTP status error is reported separately so
  ## the status code is surfaced rather than buried in a generic message.
  response <- tryCatch(
    endpoint %>%
      httr2::request() %>%
      httr2::req_timeout(30) %>%
      httr2::req_retry(
        max_tries = max_retries,
        is_transient = function(resp) httr2::resp_status(resp) %in% c(429L, 500L, 502L, 503L, 504L)) %>%
      httr2::req_error(is_error = function(resp) FALSE) %>%
      httr2::req_perform(),
    error = fail)

  if (httr2::resp_is_error(response)) {
    stop(sprintf(
      "Municode API request failed (HTTP %d).\nEndpoint: %s",
      httr2::resp_status(response), endpoint
    ), call. = FALSE)
  }

  parsed <- tryCatch(httr2::resp_body_json(response), error = fail)

  if (is.null(parsed)) {
    warning(sprintf(
      "Municode API returned an empty response for endpoint: %s",
      endpoint
    ), call. = FALSE)
  }

  parsed
}
