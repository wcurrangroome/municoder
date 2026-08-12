# Get the children of a given node in an ordinance's Table of Contents

Corresponds to, for example:
https://api.municode.com/ordinancesToc/children?productId=12429&nodeId=2023

## Usage

``` r
get_ordinance_children(node_id, product_id)
```

## Arguments

- node_id:

  A unique identifier for a node within the specified product
  (ordinance)

- product_id:

  A unique identifier for a product
