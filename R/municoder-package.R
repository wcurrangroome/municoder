#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom magrittr %>%
#' @importFrom rlang .data
## usethis namespace: end
NULL

# Global variables used in dplyr/tidyr pipelines to avoid R CMD CHECK notes
utils::globalVariables(c(
  ".", "Ancestors", "Children", "Client", "Client_State", "ContentType", "Data",
  "Docs", "Heading", "Id", "NextNode", "NextNode_id", "Node", "PrevNode", "PrevNode_id",
  "Product", "ProductClient", "ProductContentType", "ProductFeatures", "State",
  "ancestor_id", "ancestors", "ancestors_id", "children", "client_classification_id",
  "client_id", "client_name", "client_pop_range_id", "client_show_advance_sheet",
  "codes", "content", "data", "doc_order_id", "docs_content", "heading", "id",
  "name", "node", "node_depth", "node_id", "node_type", "product_id", "product_name",
  "state_abbreviation", "state_name", "title", "value"
))
