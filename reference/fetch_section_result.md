# Code-related API functions (current ordinance versions) Fetch and reshape the raw CodesContent response for a node

Code-related API functions (current ordinance versions) Fetch and
reshape the raw CodesContent response for a node

## Usage

``` r
fetch_section_result(
  node_id,
  product_id,
  job_id = NULL,
  past_job_id = NULL,
  show_changes = FALSE
)
```

## Arguments

- node_id:

  A unique identifier for a node within the specified product

- product_id:

  A unique identifier for a product

- job_id:

  Optional job identifier; required when `show_changes = TRUE`

- past_job_id:

  Optional prior job to diff against; required when
  `show_changes = TRUE`

- show_changes:

  If `TRUE`, request redline markup comparing `job_id` against
  `past_job_id`

## Value

A one-row tibble with one column per top-level response field
