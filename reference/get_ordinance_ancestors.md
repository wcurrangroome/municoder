# Get the ancestors of a given node in an ordinance's Table of Contents

Corresponds to, for example:
https://api.municode.com/ordinancesToc/breadcrumb?nodeId=2023&productId=12429

## Usage

``` r
get_ordinance_ancestors(product_id, node_id)
```

## Arguments

- product_id:

  A unique identifier for a product

- node_id:

  A unique identifier for a node within the specified product
  (ordinance)
