# Ordinance-related API functions (historical ordinance versions) Return information about all ordinances of a given type for a given year

Corresponds to, for example:
https://api.municode.com/CoreContent/Ordinances?nodeId=2023&productId=12429

## Usage

``` r
list_ordinances(node_id = NULL, product_id)
```

## Arguments

- node_id:

  The year for which ordinances are requested. Optional; when omitted
  the response is the top-level index rather than a list of ordinances.

- product_id:

  A unique code identifying a product (e.g., a zoning ordinance)

## Value

A dataframe comprising ordinances. The shape depends on `node_id`: when
the response contains nested list elements (typically when `node_id` is
supplied) each ordinance becomes a row; otherwise the top-level fields
are pivoted into a single row.
