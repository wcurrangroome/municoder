#' @title Code-related API functions (current ordinance versions)

#' Get text and metadata for a given node within a given ordinance
#' @description Corresponds to, for example: https://api.municode.com/CodesContent?jobId=426172&nodeId=THZOORALVI&productId=12429
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#'
#' @returns A dataframe with the content and metadata pertaining to a specific node within an ordinance
#' @export
#'
#' @examples
#' \dontrun{
#' get_section_text(node_id = "SUHITA", product_id = "12429")
#' }
get_section_text <- function(node_id = NULL, product_id) {
  result <-
    build_endpoint(
      domain = "CodesContent",
      parameters = c(nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider()

  docs <- result %>%
    dplyr::select(Docs) %>%
    tidyr::unnest_longer(Docs) %>%
    tidyr::unnest_wider(Docs) %>%
    janitor::clean_names() %>%
    dplyr::transmute(
      id,
      node_type = "current",
      heading = title,
      content = clean_html_content(content))

  next_node <- result %>%
    dplyr::select(NextNode) %>%
    tidyr::unnest_longer(NextNode)

  if (length(next_node) > 0) {
    next_node <- next_node %>%
      tidyr::pivot_wider(names_from = NextNode_id, values_from = NextNode) %>%
      tidyr::unnest_wider(Data) %>%
      dplyr::mutate(dplyr::across(dplyr::everything(), unlist)) %>%
      janitor::clean_names()
  }

  previous_node <- result %>%
    dplyr::select(PrevNode) %>%
    tidyr::unnest_longer(PrevNode)

  if (length(previous_node) > 0) {
    previous_node <- previous_node %>%
      tidyr::pivot_wider(names_from = PrevNode_id, values_from = PrevNode) %>%
      tidyr::unnest_wider(Data) %>%
      dplyr::mutate(dplyr::across(dplyr::everything(), unlist)) %>%
      janitor::clean_names()
  }

  result <-
    dplyr::bind_rows(
      docs,
      next_node %>% dplyr::mutate(node_type = "next"),
      previous_node %>% dplyr::mutate(node_type = "previous")) %>%
    dplyr::select(id, heading, node_type, content, dplyr::everything())

  return(result)
 }

#' Get the Table of Contents for an ordinance
#' @description Corresponds to, for example: https://api.municode.com/codesToc?jobId=426172&productId=12429
#' @param job_id A unique identifier for a job
#' @param product_id A unique identifier for a product
#'
#' @returns A dataframe with TOC sections and associated metadata
#' @export
#'
#' @examples
#' \dontrun{
#' result <- get_codes_toc(job_id = 426172, product_id = 12429)
#' }
get_codes_toc <- function(job_id, product_id) {
  result <-
    build_endpoint(
      domain = "CodesToc",
      parameters = c(jobId = job_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe()  %>%
    tidyr::pivot_wider() %>%
    dplyr::select(
      toc_id = Id,
      toc_heading = Heading,
      children = Children) %>%
    tidyr::unnest_longer(children) %>%
    tidyr::unnest_wider(children) %>%
    dplyr::mutate(dplyr::across(.cols = c(dplyr::where(is.list), -Data), unlist)) %>%
    janitor::clean_names() %>%
    dplyr::select(-c(data, node_depth, doc_order_id))

  return(result)
}

#' Get raw HTML content and markdown for a given node within a given ordinance
#' @description Identical to `get_section_text()` but preserves the raw HTML in a
#'   `content_html` column instead of stripping tags, and adds a `content_markdown`
#'   column with a markdown conversion. This is critical for extracting data from
#'   sections that contain HTML tables (e.g., dimensional standards).
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#'
#' @returns A dataframe with the raw HTML content and metadata for the specified node.
#'   Columns: `id`, `heading`, `node_type`, `content_html`, `content_markdown`.
#' @export
#'
#' @examples
#' \dontrun{
#' get_section_html(node_id = "SUHITA", product_id = "12429")
#' }
get_section_html <- function(node_id = NULL, product_id) {
  result <-
    build_endpoint(
      domain = "CodesContent",
      parameters = c(nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider()

  docs <- result %>%
    dplyr::select(Docs) %>%
    tidyr::unnest_longer(Docs) %>%
    tidyr::unnest_wider(Docs) %>%
    janitor::clean_names() %>%
    dplyr::transmute(
      id,
      node_type = "current",
      heading = title,
      content_html = content,
      content_markdown = html_to_markdown(content))

  return(docs)
}

#' Get information about a given node's ancestor(s)
#' @description Corresponds to, for example: https://api.municode.com/codesToc/breadcrumb?jobId=426172&nodeId=THZOORALVI&productId=12429
#' @param job_id A unique identifier for a job
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#'
#' @export
get_section_ancestors <- function(job_id, node_id, product_id) {
  result <-
    build_endpoint(
      domain = "codesToc",
      subdomain = "breadcrumb",
      parameters = c(jobId = job_id, nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    tidyr::unnest_longer(Node) %>%
    tidyr::unnest_longer(Ancestors) %>%
    tidyr::unnest_wider(Ancestors, names_sep = "_") %>%
    janitor::clean_names() %>%
    dplyr::select(
      node,
      id = node_id,
      ancestor_id = ancestors_id)

  return(result)
}

#' Get information about a given node's children
#' @description Corresponds to, for example: https://api.municode.com/codesToc/children?jobId=426172&nodeId=ARTIGERE&productId=12429
#' @param job_id A unique identifier for a job
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#'
#' @export
#' @examples
#' \dontrun{
#' get_section_children(job_id = 426172, node_id = "ARTIGERE", product_id = 12429)
#' }
get_section_children <- function(job_id, node_id, product_id) {
  result <-
    build_endpoint(
      domain = "codesToc",
      subdomain = "children",
      parameters = c(jobId = job_id, nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::unnest_wider(value) %>%
    tidyr::unnest_wider(Data) %>%
    janitor::clean_names()

  return(result)
}
