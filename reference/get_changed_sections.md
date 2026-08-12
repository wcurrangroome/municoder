# List the sections that changed in a given version of an ordinance

Corresponds to, for example:
https://api.municode.com/CodesChangedDocs?jobId=494092&productId=15441
Returns the set of sections (nodes) that were added or amended in the
specified job relative to the preceding version. Useful for tracking
ordinance changes over time; pair with
[`get_version_history()`](https://wcurrangroome.github.io/municoder/reference/get_version_history.md)
to walk versions and
[`get_section_html()`](https://wcurrangroome.github.io/municoder/reference/get_section_html.md)
(with `show_changes = TRUE`) to retrieve the redline for each changed
node.

## Usage

``` r
get_changed_sections(job_id, product_id)
```

## Arguments

- job_id:

  A unique identifier for a job

- product_id:

  A unique identifier for a product

## Value

A dataframe with one row per changed section and the columns `node_id`,
`title`, `compare_status` (an undocumented change-type code), and
`ancestor_path` (the node's breadcrumb, titles joined by `" > "`).
Returns a zero-row dataframe when the version introduced no changes.

## Examples

``` r
if (FALSE) { # \dontrun{
get_changed_sections(job_id = 494092, product_id = 15441)
} # }
```
