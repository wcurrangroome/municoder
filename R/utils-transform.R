#' @title Common data transformation helpers for municode API responses
#' @description Internal functions to standardize data processing across the package
#' @keywords internal

#' Transform a simple list response to a tidy dataframe
#' @param response Raw API response (list)
#' @param primary_key Name of the primary key in the response (default "value")
#' @return A tidy dataframe
#' @keywords internal
transform_list_response <- function(response, primary_key = "value") {
  response %>%
    tibble::enframe() %>%
    tidyr::unnest_wider(!!rlang::sym(primary_key)) %>%
    janitor::clean_names()
}

#' Transform nested State objects in a dataframe
#' @param df Dataframe containing a State column
#' @return Dataframe with State column unnested
#' @keywords internal
transform_nested_state <- function(df) {
  df %>%
    tidyr::unnest_wider(State) %>%
    dplyr::mutate(dplyr::across(dplyr::where(is.list), unlist))
}

#' Transform nested Client objects in a dataframe
#' @param df Dataframe containing Client columns
#' @return Dataframe with Client columns unnested
#' @keywords internal
transform_nested_client <- function(df) {
  df %>%
    tidyr::unnest_wider(Client, names_sep = "_") %>%
    tidyr::unnest_wider(Client_State) %>%
    dplyr::mutate(dplyr::across(dplyr::where(is.list), unlist))
}

#' Clean HTML content from ordinance text
#' @param content Character vector containing HTML
#' @return Cleaned character vector
#' @keywords internal
clean_html_content <- function(content) {
  content %>%
    stringr::str_replace_all(c(
      "<.*>|\\\n|\\&nbsp" = "",
      "\\h+" = " "
    ))
}

#' Standard cleanup for client dataframes
#' @param df Client dataframe
#' @return Cleaned dataframe
#' @keywords internal
clean_client_columns <- function(df) {
  df %>%
    dplyr::select(-dplyr::matches("classification|pop_range|library|meetings|advance"))
}
