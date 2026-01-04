# Workflow helper functions for common multi-step operations Get ordinance section content in one step

Convenience function that chains together multiple API calls to retrieve
ordinance section content given just the jurisdiction, product name, and
node ID.

## Usage

``` r
get_ordinance_section(state_abbreviation, client_name, product_name, node_id)
```

## Arguments

- state_abbreviation:

  Two-character state code (e.g., "VA")

- client_name:

  Name of the municipality (e.g., "Alexandria")

- product_name:

  Name of the product (e.g., "Zoning", "Code of Ordinances")

- node_id:

  Unique identifier for the section within the ordinance

## Value

A dataframe with the content and metadata for the specified section

## Examples

``` r
if (FALSE) { # \dontrun{
# Get a section from Alexandria's zoning ordinance
content <- get_ordinance_section(
  state_abbreviation = "VA",
  client_name = "Alexandria",
  product_name = "Zoning",
  node_id = "ARTIIIREZORE"
)
} # }
```
