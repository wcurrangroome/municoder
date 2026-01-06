# Code-related API functions (current ordinance versions) Get text and metadata for a given node within a given ordinance

Corresponds to, for example:
https://api.municode.com/CodesContent?jobId=426172&nodeId=THZOORALVI&productId=12429

## Usage

``` r
get_section_text(node_id = NULL, product_id)
```

## Arguments

- node_id:

  A unique identifier for a node within the specified product
  (ordinance)

- product_id:

  A unique identifier for a product

## Value

A dataframe with the content and metadata pertaining to a specific node
within an ordinance

## Examples

``` r
if (FALSE) { # \dontrun{
get_section_text(node_id = "SUHITA", product_id = "12429")
} # }
```
