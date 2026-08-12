# Obtain metadata about a given ordinance over time

Corresponds to, for example:
https://api.municode.com/ordinancesToc?nodeId=2023&productId=12429

## Usage

``` r
get_ordinances_toc(node_id = NULL, product_id)
```

## Arguments

- node_id:

  A unique identifier for a node within the specified product
  (ordinance)

- product_id:

  A unique identifier for a product

## Examples

``` r
if (FALSE) { # \dontrun{
get_ordinances_toc(node_id = 2023, product_id = 12429)
} # }
```
