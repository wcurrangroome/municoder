# Get text and metadata for a given node within a given ordinance

Corresponds to, for example:
https://api.municode.com/CodesContent?jobId=426172&nodeId=THZOORALVI&productId=12429

## Usage

``` r
get_section_text(
  node_id = NULL,
  product_id,
  job_id = NULL,
  past_job_id = NULL,
  show_changes = FALSE
)
```

## Arguments

- node_id:

  A unique identifier for a node within the specified product
  (ordinance)

- product_id:

  A unique identifier for a product

- job_id:

  Optional job identifier; required when `show_changes = TRUE`

- past_job_id:

  Optional prior job identifier to diff against; required when
  `show_changes = TRUE`

- show_changes:

  If `TRUE`, request a redline comparison of `job_id` against
  `past_job_id`. Note that `get_section_text()` strips HTML, which
  discards the insertion/deletion markup; use
  [`get_section_html()`](https://wcurrangroome.github.io/municoder/reference/get_section_html.md)
  to retain the redline in the `content_html` column.

## Value

A dataframe with the content and metadata pertaining to a specific node
within an ordinance

## Examples

``` r
if (FALSE) { # \dontrun{
get_section_text(node_id = "SUHITA", product_id = "12429")
} # }
```
