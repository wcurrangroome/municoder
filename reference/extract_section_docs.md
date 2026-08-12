# Extract the Docs payload (id, title, content) from a CodesContent response

Extract the Docs payload (id, title, content) from a CodesContent
response

## Usage

``` r
extract_section_docs(result)
```

## Arguments

- result:

  A reshaped CodesContent response from
  [`fetch_section_result()`](https://wcurrangroome.github.io/municoder/reference/fetch_section_result.md)

## Value

A tibble with cleaned `id`, `title`, and `content` columns
