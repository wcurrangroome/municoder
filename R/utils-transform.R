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
  result <- df %>%
    tidyr::unnest_wider(Client, names_sep = "_") %>%
    tidyr::unnest_wider(Client_State)

  # Try to unlist list columns, but don't fail if some can't be unlisted
  tryCatch({
    result <- result %>%
      dplyr::mutate(dplyr::across(dplyr::where(is.list), unlist))
  }, error = function(e) {
    # If unlisting fails, just select out any remaining list columns
    result <- result %>%
      dplyr::select(dplyr::where(~ !is.list(.x)))
  })

  return(result)
}

#' Clean HTML content from ordinance text
#' @param content Character vector containing HTML
#' @return Cleaned character vector
#' @keywords internal
clean_html_content <- function(content) {
  content %>%
    stringr::str_replace_all(c(
      "<.*?>" = "",           # Remove HTML tags (non-greedy)
      "\\\n" = "",            # Remove newlines
      "\\&nbsp;" = " ",       # Replace &nbsp; with space
      "\\s+" = " "            # Collapse multiple spaces
    ))
}

#' Convert HTML content to markdown, preserving table structure
#' @param html A character vector of HTML strings
#' @return A character vector of markdown strings
#' @keywords internal
html_to_markdown <- function(html) {
  html %>%
    ## Convert headings
    stringr::str_replace_all("<h1[^>]*>(.*?)</h1>", "\n# \\1\n") %>%
    stringr::str_replace_all("<h2[^>]*>(.*?)</h2>", "\n## \\1\n") %>%
    stringr::str_replace_all("<h3[^>]*>(.*?)</h3>", "\n### \\1\n") %>%
    stringr::str_replace_all("<h4[^>]*>(.*?)</h4>", "\n#### \\1\n") %>%
    stringr::str_replace_all("<h5[^>]*>(.*?)</h5>", "\n##### \\1\n") %>%
    stringr::str_replace_all("<h6[^>]*>(.*?)</h6>", "\n###### \\1\n") %>%
    ## Convert bold/strong
    stringr::str_replace_all("<(b|strong)[^>]*>(.*?)</(b|strong)>", "**\\2**") %>%
    ## Convert italic/em
    stringr::str_replace_all("<(i|em)[^>]*>(.*?)</(i|em)>", "*\\2*") %>%
    ## Convert list items
    stringr::str_replace_all("<li[^>]*>(.*?)</li>", "\n- \\1") %>%
    stringr::str_replace_all("</?[ou]l[^>]*>", "\n") %>%
    ## Convert line breaks and paragraphs
    stringr::str_replace_all("<br\\s*/?>", "\n") %>%
    stringr::str_replace_all("<p[^>]*>", "\n") %>%
    stringr::str_replace_all("</p>", "\n") %>%
    ## Convert tables to markdown tables
    convert_html_tables_to_markdown() %>%
    ## Strip remaining HTML tags
    stringr::str_replace_all("<[^>]+>", "") %>%
    ## Clean up HTML entities
    stringr::str_replace_all("&nbsp;?", " ") %>%
    stringr::str_replace_all("&amp;", "&") %>%
    stringr::str_replace_all("&lt;", "<") %>%
    stringr::str_replace_all("&gt;", ">") %>%
    stringr::str_replace_all("&quot;", "\"") %>%
    ## Collapse excess whitespace
    stringr::str_replace_all("\\n{3,}", "\n\n") %>%
    stringr::str_trim()
}

#' Convert HTML tables within a string to markdown table format
#' @param html A character vector of HTML strings containing tables
#' @return A character vector with HTML tables replaced by markdown tables
#' @keywords internal
convert_html_tables_to_markdown <- function(html) {
  purrr::map_chr(html, function(h) {
    ## Extract each <table>...</table> block
    tables <- stringr::str_extract_all(h, "(?i)<table[^>]*>[\\s\\S]*?</table>")[[1]]

    if (length(tables) == 0) return(h)

    purrr::reduce(tables, function(current_html, tbl) {
      ## Extract rows
      rows <- stringr::str_extract_all(tbl, "(?i)<tr[^>]*>[\\s\\S]*?</tr>")[[1]]

      if (length(rows) == 0) return(current_html)

      md_rows <- purrr::map_chr(rows, function(row) {
        ## Extract header cells or data cells
        cells <- stringr::str_extract_all(row, "(?i)<t[hd][^>]*>[\\s\\S]*?</t[hd]>")[[1]]
        cell_text <- cells %>%
          stringr::str_replace_all("<[^>]+>", "") %>%
          stringr::str_replace_all("\\s+", " ") %>%
          stringr::str_trim()
        stringr::str_c("| ", stringr::str_c(cell_text, collapse = " | "), " |")
      })

      ## Add separator after the first row (header)
      first_row <- md_rows[[1]]
      ncols <- stringr::str_count(first_row, "\\|") - 1
      separator <- stringr::str_c("|", stringr::str_c(rep(" --- |", ncols), collapse = ""))
      md_table <- stringr::str_c(
        c("\n", first_row, separator, md_rows[-1], "\n"),
        collapse = "\n")

      stringr::str_replace(current_html, stringr::coll(tbl), md_table)
    }, .init = h)
  })
}

#' Standard cleanup for client dataframes
#' @param df Client dataframe
#' @return Cleaned dataframe
#' @keywords internal
clean_client_columns <- function(df) {
  df %>%
    dplyr::select(-dplyr::matches("classification|pop_range|library|meetings|advance"))
}
