# Obtain metadata about a given ordinance over time

Corresponds to, for example:
https://api.municode.com/ordinancesToc?nodeId=2023&productId=12429

## Usage

``` r
get_ordinances_toc(product_id, node_id = NA)
```

## Arguments

- product_id:

  A unique identifier for a product

- node_id:

  A unique identifier for a node within the specified product
  (ordinance)

## Examples

``` r
if (FALSE) { # \dontrun{
get_ordinances_toc(node_id = 2023, product_id = 12429)
} # }
```
