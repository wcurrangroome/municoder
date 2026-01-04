# Return metadata for all Municode clients in a given state

Corresponds to, for example:
https://api.municode.com/Clients/stateAbbr?stateAbbr=VA

## Usage

``` r
get_clients_in_state(state_abbreviation)
```

## Arguments

- state_abbreviation:

  A two-character state code

## Value

A dataframe of clients

## Examples

``` r
if (FALSE) { # \dontrun{
get_clients_in_state("VA")
} # }
```
