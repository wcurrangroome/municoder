# Look up state metadata given a state abbreviation

Corresponds to (for example):
https://api.municode.com/States/abbr?stateAbbr=ak

## Usage

``` r
get_state_by_abbreviation(state_abbreviation)
```

## Arguments

- state_abbreviation:

  A two-character state abbreviation

## Value

A dataframe with three columns: `state_id`, `state_name`,
`state_abbreviation.`
