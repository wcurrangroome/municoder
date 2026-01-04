# Common data transformation helpers for municode API responses

Internal functions to standardize data processing across the package

## Usage

``` r
transform_list_response(response, primary_key = "value")
```

## Arguments

- response:

  Raw API response (list)

- primary_key:

  Name of the primary key in the response (default "value")

## Value

A tidy dataframe
