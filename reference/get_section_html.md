# Get raw HTML content and markdown for a given node within a given ordinance

Identical to
[`get_section_text()`](https://wcurrangroome.github.io/municoder/reference/get_section_text.md)
but preserves the raw HTML in a `content_html` column instead of
stripping tags, and adds a `content_markdown` column with a markdown
conversion. This is critical for extracting data from sections that
contain HTML tables (e.g., dimensional standards).

## Usage

``` r
get_section_html(node_id = NULL, product_id)
```

## Arguments

- node_id:

  A unique identifier for a node within the specified product
  (ordinance)

- product_id:

  A unique identifier for a product

## Value

A dataframe with the raw HTML content and metadata for the specified
node. Columns: `id`, `heading`, `node_type`, `content_html`,
`content_markdown`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_section_html(node_id = "SUHITA", product_id = "12429")
} # }
```
