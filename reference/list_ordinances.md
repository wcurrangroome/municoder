# Ordinance-related API functions (historical ordinance versions) Return information about all ordinances of a given type for a given year

Corresponds to, for example:
https://api.municode.com/CoreContent/Ordinances?nodeId=2023&productId=12429

## Usage

``` r
list_ordinances(product_id, node_id = NULL)
```

## Arguments

- product_id:

  A unique code identifying a product (e.g., a zoning ordinance)

- node_id:

  The year for which ordinances are requested

## Value

A dataframe comprising ordinances
