# Get full table of contents for an ordinance in one step

Convenience function that retrieves the complete table of contents for
an ordinance given just the jurisdiction and product name.

## Usage

``` r
get_ordinance_toc(state_abbreviation, client_name, product_name)
```

## Arguments

- state_abbreviation:

  Two-character state code (e.g., "VA")

- client_name:

  Name of the municipality (e.g., "Alexandria")

- product_name:

  Name of the product (e.g., "Zoning", "Code of Ordinances")

## Value

A dataframe with the table of contents

## Examples

``` r
if (FALSE) { # \dontrun{
# Get table of contents for Alexandria's zoning ordinance
toc <- get_ordinance_toc(
  state_abbreviation = "VA",
  client_name = "Alexandria",
  product_name = "Zoning"
)
} # }
```
