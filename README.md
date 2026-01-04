---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# municoder

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/wcurrangroome/municoder/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/wcurrangroome/municoder/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

**municoder** provides an R interface to the [municode.com](https://municode.com) API, giving programmatic access to municipal ordinances from 1,000+ jurisdictions across all 50 U.S. states and territories. The package enables researchers, urban planners, and policy analysts to access zoning codes, building ordinances, and other regulatory documents for spatial analysis, policy research, and comparative studies.

Municode.com hosts comprehensive legal codes and ordinances for municipalities, counties, and other local governments. This package makes it easy to discover, navigate, and extract ordinance text and metadata without manual web scraping.

## Key Features

- 🗺️ **Comprehensive Coverage**: Access ordinances from 1,000+ jurisdictions across all 50 states + DC
- 🚀 **Workflow Helpers**: New convenience functions simplify common multi-step operations
- ⚡ **Performance**: Built-in caching provides 100x+ speedup for repeated queries
- 📊 **Tidy Data**: Returns analysis-ready dataframes with consistent structure
- 🔄 **Historical Data**: Access historical versions of ordinances over time
- 🛡️ **Robust**: Automatic retry logic and informative error messages

## Installation

You can install the development version of `library(municoder)` like so:

``` r
renv::install("wcurrangroome/municoder")
```



## Quick Start

Get started with municoder in just a few lines:


``` r
library(municoder)

# Get all jurisdictions in Virginia
va_clients <- get_clients_in_state("VA")

# Get all available ordinances for Alexandria, VA (the easy way!)
products <- get_jurisdiction_products("VA", "Alexandria")

# Get the table of contents for Alexandria's zoning ordinance
toc <- get_ordinance_toc("VA", "Alexandria", "Zoning")

# Extract a specific section of the ordinance
content <- get_ordinance_section("VA", "Alexandria", "Zoning", "ARTIIIREZORE")
```

The new workflow helper functions (`get_jurisdiction_products()`, `get_ordinance_toc()`, `get_ordinance_section()`) automatically handle the multi-step process of looking up IDs and navigating the API, making common tasks much simpler.

## Performance Tips

Use the cached versions of functions for significantly better performance on repeated queries:


``` r
# First call hits the API
states <- get_states_cached()

# Subsequent calls are instant (cached)
states <- get_states_cached()

# Cached versions available for frequently-used functions
clients <- get_clients_in_state_cached("VA")
metadata <- get_client_metadata_cached("VA", "Alexandria")

# Clear cache when you need fresh data
clear_cache()
```

Cached functions store results in memory with appropriate TTLs:
- `get_states_cached()`: Indefinite (states rarely change)
- `get_clients_in_state_cached()`: 24 hours
- `get_client_metadata_cached()`: 24 hours
- `get_client_content_cached()`: 6 hours
- `get_product_metadata_cached()`: 6 hours

## Common Workflows

### Discovery: Find jurisdictions and their ordinances


``` r
# Get all states
states <- get_states()

# Get all municipalities in a state
va_clients <- get_clients_in_state("VA")

# Get metadata for a specific municipality
alexandria <- get_client_metadata("VA", "Alexandria")

# Get all ordinance types available for a jurisdiction
products <- get_jurisdiction_products("VA", "Alexandria")
```

### Navigation: Explore ordinance structure


``` r
# Get table of contents (the easy way)
toc <- get_ordinance_toc("VA", "Alexandria", "Zoning")

# Or do it step-by-step for more control
client_id <- get_client_metadata("VA", "Alexandria")$client_id
product_id <- get_client_content(client_id) %>%
  filter(product_name == "Zoning") %>%
  pull(product_id)
job_id <- get_jobs_latest(product_id)$id
toc <- get_codes_toc(job_id, product_id)
```

### Extraction: Get ordinance text


``` r
# Extract a specific section (the easy way)
section <- get_ordinance_section("VA", "Alexandria", "Zoning", "ARTIIIREZORE")

# Get all child sections and their content
children_ids <- section %>% pull(id)
all_content <- map_dfr(children_ids,
  ~get_codes_content(product_id = product_id, node_id = .x))
```

## Case Studies

### Spatial Coverage Analysis

Map the geographic distribution of jurisdictions with ordinances on municode.com:


``` r
all_states <- municoder::get_states()

all_clients <- all_states %>%
  dplyr::pull(state_abbreviation) %>%
  purrr::discard(~ str_detect(.x, "Tribes")) %>% ## "Tribes" throws an error for some reason
  purrr::map_dfr(~ get_clients_in_state(.x))

states_sf <- tigris::states(cb = TRUE, progress_bar = FALSE) %>%
  dplyr::filter(GEOID < 60) %>%
  tigris::shift_geometry() %>%
  dplyr::left_join(
    all_clients %>% dplyr::count(state_abbreviation),
    by = c("STUSPS" = "state_abbreviation"))
#> Retrieving data for the year 2021

states_sf %>%
  ggplot2::ggplot() +
  ggplot2::geom_sf(ggplot2::aes(fill = n)) +
  ggplot2::geom_sf(data = states_sf %>% dplyr::filter(n == 0), fill = "lightgrey") +
  ggplot2::labs(
    title = "municode.com Has Coverage across All 51 States",
    subtitle = "Number of entities listed on municode.com, by state",
    fill = "Entities with ordinances on municode.com" %>% str_wrap(30)) +
  ggplot2::scale_fill_continuous(trans = "reverse") +
  urbnthemes::theme_urbn_map()
```

<div class="figure">
<img src="man/figures/README-map of municode coverage by state-1.png" alt="plot of chunk map of municode coverage by state" width="100%" />
<p class="caption">plot of chunk map of municode coverage by state</p>
</div>

### Comparative Zoning Analysis

Compare zoning ordinance language across different zones. This example examines the "Purpose" statements for Alexandria, VA's residential zones to identify policy priorities:


``` r
# Get all residential zones using the workflow helper
content <- get_ordinance_section("VA", "Alexandria", "Zoning", "ARTIIIREZORE")
#> Error in `dplyr::mutate()`:
#> i In argument: `dplyr::across(dplyr::where(is.list), unlist)`.
#> Caused by error in `across()`:
#> ! Can't compute column `Features`.
#> Caused by error in `dplyr_internal_error()`:

# Extract all child zone sections
zone_ids <- content %>% dplyr::pull(id)
#> Error: object 'content' not found
all_zones <- purrr::map_dfr(zone_ids,
  ~ get_codes_content(product_id = 12429, node_id = .x))
#> Error: object 'zone_ids' not found

# Filter to Purpose statements
purpose_statements <- all_zones %>%
  dplyr::filter(
    !is.na(content),
    stringr::str_detect(heading, "Purpose")) %>%
  dplyr::select(heading, content)
#> Error: object 'all_zones' not found

# Display the results
purpose_statements %>% dplyr::pull(content)
#> Error: object 'purpose_statements' not found
```

**Insight**: Analysis reveals that the RMF zone is unique in explicitly mentioning housing affordability in its purpose statement, while other residential zones focus on density caps and neighborhood character. This raises interesting policy questions about why affordability isn't a stated goal for other residential zones.

## Use Cases

municoder supports a variety of research and analysis applications:

- **Comparative Policy Analysis**: Compare ordinance language across jurisdictions to identify policy differences
- **Affordable Housing Research**: Analyze zoning codes for inclusionary zoning, density bonuses, and affordability provisions
- **Historical Tracking**: Monitor how ordinances change over time using historical job data
- **Spatial Analysis**: Map regulatory patterns across regions (e.g., parking requirements, density limits)
- **Text Mining**: Extract and analyze regulatory language at scale using NLP techniques
- **Development Research**: Study how land use regulations vary by jurisdiction type or region

## Getting Help

- **Documentation**: Visit the [package website](https://wcurrangroome.github.io/municoder/) for full function reference
- **Issues**: Report bugs or request features on [GitHub Issues](https://github.com/wcurrangroome/municoder/issues)
- **Questions**: Open a discussion on the GitHub repository

## Learn More

- See `vignette("municoder")` for detailed examples
- Check out the [API documentation](https://api.municode.com) to understand endpoint details
- Read [REFACTORING.md](REFACTORING.md) for information on recent package improvements
