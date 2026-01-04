# Get all products for a jurisdiction in one step

Convenience function to get all available products (ordinances) for a
jurisdiction given just the state and municipality name.

## Usage

``` r
get_jurisdiction_products(state_abbreviation, client_name)
```

## Arguments

- state_abbreviation:

  Two-character state code (e.g., "VA")

- client_name:

  Name of the municipality (e.g., "Alexandria")

## Value

A dataframe with all products available for the jurisdiction

## Examples

``` r
if (FALSE) { # \dontrun{
# Get all products for Alexandria, VA
products <- get_jurisdiction_products(
  state_abbreviation = "VA",
  client_name = "Alexandria"
)
} # }
```
