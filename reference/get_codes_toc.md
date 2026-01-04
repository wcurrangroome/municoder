# Get the Table of Contents for an ordinance

Corresponds to, for example:
https://api.municode.com/codesToc?jobId=426172&productId=12429

## Usage

``` r
get_codes_toc(job_id, product_id)
```

## Arguments

- job_id:

  A unique identifier for a job

- product_id:

  A unique identifier for a product

## Value

A dataframe with TOC sections and associated metadata

## Examples

``` r
if (FALSE) { # \dontrun{
result <- get_codes_toc(job_id = 426172, product_id = 12429)
} # }
```
