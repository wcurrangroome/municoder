# Get the full table of contents tree for an ordinance in a single request

Corresponds to, for example:
https://api.municode.com/codesToc/fullTree?jobId=494092&nodeId=15441&productId=15441
Unlike
[`get_section_children()`](https://wcurrangroome.github.io/municoder/reference/get_section_children.md),
which returns one level of the hierarchy per call, this returns the
entire nested tree beneath `node_id` in a single request and flattens it
to a tidy dataframe (one row per node). Per-node amendment flags are
included.

## Usage

``` r
get_codes_tree(job_id, node_id, product_id)
```

## Arguments

- job_id:

  A unique identifier for a job

- node_id:

  A node to use as the root of the returned tree. Pass the `product_id`
  to retrieve the whole code.

- product_id:

  A unique identifier for a product

## Value

A dataframe with one row per node and the columns `id`, `heading`,
`node_depth`, `parent_id`, `doc_order_id`, `has_children`, `node_key`,
`is_updated`, `is_amended`, `has_amended_descendant`, `compare_status`,
and `doc_type`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_codes_tree(job_id = 494092, node_id = 15441, product_id = 15441)
} # }
```
