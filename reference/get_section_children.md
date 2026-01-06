# Get information about a given node's children

Corresponds to, for example:
https://api.municode.com/codesToc/children?jobId=426172&nodeId=ARTIGERE&productId=12429

## Usage

``` r
get_section_children(job_id, node_id, product_id)
```

## Arguments

- job_id:

  A unique identifier for a job

- node_id:

  A unique identifier for a node within the specified product
  (ordinance)

- product_id:

  A unique identifier for a product

## Examples

``` r
if (FALSE) { # \dontrun{
get_section_children(job_id = 426172, node_id = "ARTIGERE", product_id = 12429)
} # }
```
