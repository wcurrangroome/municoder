# Get client metadata with caching

Cached version of get_client_metadata(). Results are cached for 24
hours.

## Usage

``` r
get_client_metadata_cached(state_abbreviation, client_name)
```

## Arguments

- state_abbreviation:

  A two-character state code

- client_name:

  The name of a given client

## Value

A dataframe of metadata about the specified client
