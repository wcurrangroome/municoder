# Obtain products available for a jurisdiction

Corresponds to, for example:
https://api.municode.com/ClientContent/12053

## Usage

``` r
get_client_products(client_id)
```

## Arguments

- client_id:

  A code corresponding to a given client; this can be obtained from
  [`get_clients_in_state()`](https://wcurrangroome.github.io/municoder/reference/get_clients_in_state.md)

## Value

A dataframe with metadata about each product for a client (e.g., code of
ordinances, zoning, etc.)

## Examples

``` r
if (FALSE) { # \dontrun{
get_client_products(980) ## Alexandria, VA
} # }
```
