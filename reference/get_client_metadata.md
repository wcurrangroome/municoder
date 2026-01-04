# Client-related API functions Returns metadata about a given client

Corresponds to, for example:
https://api.municode.com/Clients/name?stateAbbr=VA&clientName=Alexandria

## Usage

``` r
get_client_metadata(state_abbreviation, client_name)
```

## Arguments

- state_abbreviation:

  A two-character state code

- client_name:

  The name of a given client

## Value

A dataframe of metadata about the specified client

## Examples

``` r
if (FALSE) { # \dontrun{
get_client_metadata("VA", "Alexandria")
} # }
```
