# Obtain metadata for a jurisdiction's regulatory documents hosted on Municode

Corresponds to, for example:
https://api.municode.com/ClientContent/12053

## Usage

``` r
get_client_content(client_id)
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
get_client_content(980) ## Alexandria, VA
} # }
```
