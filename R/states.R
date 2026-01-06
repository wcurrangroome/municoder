#' @title State-related API functions

#' Return metadata about states (and similar) as used by municode
#' @description Corresponds to: https://api.municode.com/States/
#' @returns A dataframe with three columns: `state_id`, `state_name`, `state_abbreviation.`
#' @export
get_states <- function() {
  result <-
    build_endpoint("States") %>%
    get_endpoint() %>%
    transform_list_response() %>%
    dplyr::select(-name)

  return(result)
}

#' Look up state metadata given a state abbreviation
#' @description Corresponds to (for example): https://api.municode.com/States/abbr?stateAbbr=ak
#' @param state_abbreviation A two-character state abbreviation
#'
#' @returns A dataframe with three columns: `state_id`, `state_name`, `state_abbreviation.`
#' @export
get_state_by_abbreviation <- function(state_abbreviation) {
  result <-
    build_endpoint(
      domain = "States",
      subdomain = "abbr",
      parameters = c(stateAbbr = state_abbreviation)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    dplyr::mutate(value = unlist(value)) %>%
    tidyr::pivot_wider() %>%
    janitor::clean_names()

  return(result)
}
