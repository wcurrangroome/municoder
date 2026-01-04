# Product-related API functions Get metadata about a specified product

Corresponds to, for example:
https://api.municode.com/Products/name?clientId=12053&productName=code+of+ordinances

## Usage

``` r
get_product_metadata(client_id, product_name)
```

## Arguments

- client_id:

  A unique identifier for a client

- product_name:

  The name of a product type, e.g., "Code of Ordinances"

## Examples

``` r
if (FALSE) { # \dontrun{
get_product_metadata(client_id = 12053, product_name = "Code of Ordinances")
} # }
```
