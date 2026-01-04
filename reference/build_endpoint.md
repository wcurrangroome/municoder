# API utility functions for municode.com

Internal functions for building endpoints and making API calls

## Usage

``` r
build_endpoint(domain, subdomain = NULL, parameters = NULL)
```

## Arguments

- domain:

  The first component of the API endpoint after base api.municode.com/

- subdomain:

  The second component of the API endpoint

- parameters:

  Named vector of parameter-value pairs

## Value

Complete API endpoint URL
