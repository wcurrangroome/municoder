#' @importFrom magrittr %>%

#' @title A helper function to build an API endpoint
#' @param domain The first component of the API endpoint after base api.municode.com/
#' @param subdomain The second component of the API endpoint after api.municode.com/domain
#' @param parameters Named vector of parameter-value pairs passed to configure the API endpoint
build_endpoint = function(domain, subdomain = NULL, parameters = NULL) {

  if (is.null(subdomain) & is.null(parameters)) {
    endpoint = stringr::str_c("https://api.municode.com/", domain) }

  if (!is.null(parameters)) {
    params_names = names(parameters)
    params_values = parameters %>% as.character()
    params = purrr::map_chr(
      1:length(parameters),
      ~ stringr::str_c(params_names[.x], "=", params_values[.x])) %>%
      stringr::str_c(collapse = "&") }

  if (is.null(subdomain) & !is.null(parameters)) {
    endpoint = stringr::str_c(
      "https://api.municode.com/", domain, "?", params) }

  if (!is.null(subdomain) & is.null(parameters)) {
    endpoint = stringr::str_c(
      "https://api.municode.com/", domain, "/", subdomain) }

  if (!is.null(subdomain) & !is.null(parameters)) {
    endpoint = stringr::str_c(
      "https://api.municode.com/", domain, "/", subdomain, "?", params) }

  return(endpoint)
}

#' @title A helper function to send a GET request to an API endpoint
#' @param endpoint An API endpoint
get_endpoint = function(endpoint) {
  result = endpoint %>%
    httr2::request() %>%
    httr2::req_perform() %>%
    httr2::resp_body_json()

  return(result)
}

#' @title Return metadata about states (and similar) as used by municode
#' @description Corresponds to: https://api.municode.com/States/
#' @returns A dataframe with three columns: `state_id`, `state_name`, `state_abbreviation.`
#' @export
get_states = function() {
  result =
    build_endpoint("States") %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::unnest_wider(value) %>%
    janitor::clean_names() %>%
    dplyr::select(-name)

  return(result)
}

#' @title Look up state metadata given a state abbreviation
#' @description Corresponds to (for example): https://api.municode.com/States/abbr?stateAbbr=ak
#' @param state_abbreviation A two-character state abbreviation
#'
#' @returns A dataframe with three columns: `state_id`, `state_name`, `state_abbreviation.`
#' @export
get_states_abbreviation = function(state_abbreviation) {
  result =
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

#' @title Return information about all ordinances of a given type (e.g., zoning) for a given year
#' @description Corresponds to, for example: https://api.municode.com/CoreContent/Ordinances?nodeId=2023&productId=12429
#' @param product_id A unique code identifying a product (e.g., a zoning ordinance)
#' @param node_id The year for which ordinances are requested
#'
#' @returns A dataframe comprising ordinances
#' @export
get_core_content_ordinances = function(product_id, node_id = NULL) {
  if (is.null(node_id)) {
    endpoint = build_endpoint(
      domain = "CoreContent",
      subdomain = "Ordinances",
      parameters = c(productId = product_id)) }
  if (!is.null(node_id)) {
    endpoint = build_endpoint(
      domain = "CoreContent",
      subdomain = "Ordinances",
      parameters = c(productId = product_id, nodeId = node_id)) }

  result = endpoint %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::unnest_longer(value) %>%
    tidyr::unnest_wider(value) %>%
    janitor::clean_names()

  return(result)
}

#' @title Returns metadata about a given client
#' @description Corresponds to, for example: https://api.municode.com/Clients/name?stateAbbr=VA&clientName=Alexandria
#' @param state_abbreviation A two-character state code
#' @param client_name The name of a given client
#'
#' @returns A dataframe of metadata about the specified client
#' @export
#'
#' @examples
#' get_client_metadata("VA", "Alexandria")
get_client_metadata = function(state_abbreviation, client_name) {
  result =
    build_endpoint(
      domain = "Clients",
      subdomain = "name",
      parameters = c(stateAbbr = state_abbreviation, clientName = client_name)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    tidyr::unnest_wider(State) %>%
    dplyr::mutate(dplyr::across(dplyr::where(is.list), unlist)) %>%
    janitor::clean_names()

  return(result)
}

#' @title Return metadata for all Municode clients in a given state
#' @description Corresponds to, for example: https://api.municode.com/Clients/stateAbbr?stateAbbr=VA
#' @param state_abbreviation A two-character state code
#'
#' @returns A dataframe of clients
#' @export
#'
#' @examples
#' get_clients_in_state("VA")
get_clients_in_state = function(state_abbreviation) {
  result =
    build_endpoint(
      domain = "Clients",
      subdomain = "stateAbbr",
      parameters = c(stateAbbr = state_abbreviation)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::unnest_wider(value) %>%
    tidyr::unnest_wider(State) %>%
    janitor::clean_names() %>%
    dplyr::select(-dplyr::matches("classification|pop_range|library|meetings|advance"))

  return(result)
}

#' @title Obtain metadata for a jurisdiction's regulatory documents hosted on Municode
#' @description Corresponds to, for example: https://api.municode.com/ClientContent/12053
#' @param client_id A code corresponding to a given client; this can be obtained from `get_clients_in_state()`
#'
#' @returns A dataframe with metadata about each product for a client (e.g., code of ordinances, zoning, etc.)
#' @export
#'
#' @examples
#' get_client_content(980) ## Alexandria, VA
get_client_content = function(client_id) {
  result =
    build_endpoint(
      domain = "ClientContent") %>%
      stringr::str_c("/", client_id) %>%
    get_endpoint()  %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    ## selecting only codes; not including "features" nor "munidocs" in the returned data
    dplyr::select(codes) %>%
    tidyr::unnest_longer(codes) %>%
    tidyr::unnest_wider(codes) %>%
    janitor::clean_names()

  return(result)
}

#' @title Get text and metadata for a given node within a given ordinance
#' @description Corresponds to, for example: https://api.municode.com/CodesContent?jobId=426172&nodeId=THZOORALVI&productId=12429
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#'
#' @returns A dataframe with the content and metadata pertaining to a specific node within an ordinance
#' @export
#'
#' @examples
#' get_codes_content(node_id = "SUHITA", product_id = "12429")
get_codes_content = function(node_id = NULL, product_id) {
  result =
    build_endpoint(
      domain = "CodesContent",
      parameters = c(nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider()

  docs = result %>%
    dplyr::select(Docs) %>%
    tidyr::unnest_longer(Docs) %>%
    tidyr::unnest_wider(Docs) %>%
    janitor::clean_names() %>%
    dplyr::transmute(
      id,
      node_type = "current",
      heading = title,
      content = content %>%
        stringr::str_replace_all(c(
          "<.*>|\\\n|\\&nbsp" = "",
          "\\h+" = " ")))

  next_node = result %>%
    dplyr::select(NextNode) %>%
    tidyr::unnest_longer(NextNode)

  if (length(next_node) > 0) {
    next_node = next_node %>%
      tidyr::pivot_wider(names_from = NextNode_id, values_from = NextNode) %>%
      tidyr::unnest_wider(Data) %>%
      dplyr::mutate(dplyr::across(dplyr::everything(), unlist)) %>%
      janitor::clean_names() }

  previous_node = result %>%
    dplyr::select(PrevNode) %>%
    tidyr::unnest_longer(PrevNode)

  if (length(previous_node) > 0) {
    previous_node = previous_node %>%
      tidyr::pivot_wider(names_from = PrevNode_id, values_from = PrevNode) %>%
      tidyr::unnest_wider(Data) %>%
      dplyr::mutate(dplyr::across(dplyr::everything(), unlist)) %>%
      janitor::clean_names() }

  result =
    dplyr::bind_rows(
      docs,
      next_node %>% dplyr::mutate(node_type = "next"),
      previous_node %>% dplyr::mutate(node_type = "previous")) %>%
    dplyr::select(id, heading, node_type, content, dplyr::everything())

  return(result)
 }

#' @title Get the Table of Contents for an ordinance
#' @description Corresponds to, for example: https://api.municode.com/codesToc?jobId=426172&productId=12429
#' @param job_id A unique identifier for a job
#' @param product_id A unique identifier for a product
#'
#' @returns A dataframe with TOC sections and associated metadata
#' @export
#'
#' @examples
#' result = get_codes_toc(job_id = 426172, product_id = 12429)
get_codes_toc = function(job_id, product_id) {
  result =
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

#' @title Get information about a given node's ancestor(s)
#' @description Corresponds to, for example: https://api.municode.com/codesToc/breadcrumb?jobId=426172&nodeId=THZOORALVI&productId=12429
#' @param job_id A unique identifier for a job
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#'
#' @export
get_codes_toc_breadcrumb = function(job_id, node_id, product_id) {
  result =
    build_endpoint(
      domain = "codesToc",
      subdomain = "breadcrumb",
      parameters = c(jobId = job_id, nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    result %>%
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

#' @title Get information about a given node's children
#' @description Corresponds to, for example: https://api.municode.com/codesToc/children?jobId=426172&nodeId=ARTIGERE&productId=12429
#' @param job_id A unique identifier for a job
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @param product_id A unique identifier for a product
#'
#' @export
#' @examples get_codes_toc_children(job_id = 426172, node_id = "ARTIGERE", product_id = 12429)
get_codes_toc_children = function(job_id, node_id, product_id) {
  result =
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

#' @title Obtain metadata about a given ordinance over time
#' @description Corresponds to, for example: https://api.municode.com/ordinancesToc?nodeId=2023&productId=12429
#' @param product_id A unique identifier for a product
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#'
#' @export
#'
#' @examples
#' get_ordinances_toc(node_id = 2023, product_id = 12429)
get_ordinances_toc = function(product_id, node_id = NA) {
  result =
    build_endpoint(
      domain = "ordinancesToc",
      parameters = c(nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    janitor::clean_names() %>%
    tidyr::unnest_wider(data) %>%
    dplyr::mutate(dplyr::across(.cols = -children, unlist))

  return(result)
}

#' @title Get the ancestors of a given node in an ordinance's Table of Contents
#' Corresponds to, for example: https://api.municode.com/ordinancesToc/breadcrumb?nodeId=2023&productId=12429
#' @param product_id A unique identifier for a product
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#'
#' @export
get_ordinances_toc_breadcrumb = function(product_id, node_id) {
  result_ordinances_toc_breadcrumb =
    build_endpoint(
      domain = "ordinancesToc",
      subdomain = "breadcrumb",
      parameters = c(nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    tidyr::unnest_wider(Node) %>%
    tidyr::unnest_longer(Ancestors) %>%
    tidyr::unnest_longer(Ancestors) %>%
    janitor::clean_names() %>%
    dplyr::select(id, ancestors, ancestors_id)

  return(result)
}

#' @title Get the children of a given node in an ordinance's Table of Contents
#' @description Corresponds to, for example: https://api.municode.com/ordinancesToc/children?productId=12429&nodeId=2023
#' @param product_id A unique identifier for a product
#' @param node_id A unique identifier for a node within the specified product (ordinance)
#' @export
get_ordinances_toc_children = function(product_id, node_id) {
  result =
    build_endpoint(
      domain = "ordinancesToc",
      subdomain = "children",
      parameters = c(nodeId = node_id, productId = product_id)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::unnest_wider(value) %>%
    tidyr::unnest_wider(Data)

  return(result)
}

#' @title Returns data on all jobs for a given product (e.g., all historical versions of the zoning ordinance)
#' @description Corresponds to, for example: https://api.municode.com/Jobs/product/12429
#' @param product_id A unique identifier for a product
#'
#' @export
get_jobs_product = function(product_id) {
  result =
    build_endpoint(
      domain = "Jobs",
      subdomain = "product") %>%
    stringr::str_c("/", product_id) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::unnest_wider(value) %>%
    janitor::clean_names()
}

#' @title This returns data on the most recent job (e.g., the current zoning ordinance, reflecting amendments)
#' @description Corresponds to, for example: https://api.municode.com/Jobs/latest/12429
#' @param product_id A unique identifier for a product
#' @export
get_jobs_latest = function(product_id) {
  result =
    build_endpoint(
      domain = "Jobs",
      subdomain = "latest") %>%
    stringr::str_c("/", product_id) %>%
    get_endpoint() %>%
    tibble::enframe()  %>%
    tidyr::pivot_wider() %>%
    tidyr::unnest_wider(Product, names_sep = "") %>%
    tidyr::unnest_wider(ProductContentType, names_sep = "_") %>%
    tidyr::unnest_wider(ProductFeatures) %>%
    tidyr::unnest_wider(ProductClient) %>%
    tidyr::unnest_wider(State) %>%
    janitor::clean_names() %>%
    dplyr::mutate(dplyr::across(.cols = dplyr::where(is.list), unlist))

  return(result)
}

#' @title Get metadata about a specified product
#' @description Corresponds to, for example: https://api.municode.com/Products/name?clientId=12053&productName=code+of+ordinances
#' @param client_id A unique identifier for a client
#' @param product_name The name of a product type, e.g., "Code of Ordinances"
#' @export
#'
#' @examples
#' get_product_metadata(client_id = 12053, product_name = "Code of Ordinances")
get_product_metadata = function(client_id, product_name) {
  product_name = product_name %>%
    stringr::str_replace_all(" ", "+") %>%
    stringr::str_to_lower()
  result =
    build_endpoint(
      domain = "Products",
      subdomain = "name",
      parameters = c(clientId = client_id, productName = product_name)) %>%
    get_endpoint() %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    tidyr::unnest_wider(ContentType) %>%
    tidyr::unnest_wider(Client, names_sep = "_") %>%
    tidyr::unnest_wider(Client_State) %>%
    janitor::clean_names() %>%
    dplyr::select(
      product_id,
      product_name,
      dplyr::matches("client")) %>%
    dplyr::select(-c(client_pop_range_id, client_classification_id, client_show_advance_sheet, dplyr::matches("client_library|meetings"))) %>%
    dplyr::rename_with(~ stringr::str_replace_all(.x, "client_client", "client")) %>%
    dplyr::mutate(dplyr::across(dplyr::where(is.list), unlist))
}

utils::globalVariables(c(
  ".", "docs_content", "Children", "Client", "Client_State", "ContentType", "Data",
  "Docs", "Heading", "Id", "NextNode", "NextNode_id", "PrevNode", "PrevNode_id",
  "Product", "ProductClient", "ProductContentType", "ProductFeatures", "State",
  "children", "client_classification_id", "client_pop_range_id", "client_show_advance_sheet",
  "codes", "content", "data", "doc_order_id", "heading", "id", "name", "node_depth",
  "node_type", "product_id", "title", "value", "Ancestors", "result", "Node", "node",
  "ancestors_id"))
