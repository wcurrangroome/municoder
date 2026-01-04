# municoder - R Package Overview for AI Assistants

## Package Purpose

`municoder` is an R package that provides a programmatic interface to
the municode.com API, enabling users to access and analyze municipal
ordinances (zoning codes, building codes, etc.) from thousands of U.S.
jurisdictions.

## Key Capabilities

### 1. Geographic Discovery

- **[`get_states()`](https://wcurrangroome.github.io/municoder/reference/get_states.md)**:
  List all states/territories with municode.com coverage
- **`get_states_abbreviation(state_abbreviation)`**: Look up state
  metadata by abbreviation
- **`get_clients_in_state(state_abbreviation)`**: Find all
  municipalities in a state with ordinances on municode.com

### 2. Client/Jurisdiction Metadata

- **`get_client_metadata(state_abbreviation, client_name)`**: Get
  detailed information about a specific municipality
- **`get_client_content(client_id)`**: List all ordinance types
  (products) available for a jurisdiction (e.g., “Zoning”, “Code of
  Ordinances”)

### 3. Ordinance Navigation

- **`get_jobs_latest(product_id)`**: Get the most current version of an
  ordinance
- **`get_jobs_product(product_id)`**: List all historical versions of an
  ordinance
- **`get_codes_toc(job_id, product_id)`**: Get table of contents for an
  ordinance
- **`get_codes_toc_breadcrumb(job_id, node_id, product_id)`**: Get
  ancestor nodes for a specific section
- **`get_codes_toc_children(job_id, node_id, product_id)`**: Get child
  nodes for a specific section

### 4. Content Extraction

- **`get_codes_content(node_id, product_id)`**: Extract full text and
  metadata for specific ordinance sections
- **`get_ordinances_toc(product_id, node_id)`**: Get table of contents
  for ordinances over time
- **`get_ordinances_toc_breadcrumb(product_id, node_id)`**: Navigate
  ordinance hierarchy
- **`get_ordinances_toc_children(product_id, node_id)`**: Get children
  of ordinance nodes
- **`get_core_content_ordinances(product_id, node_id)`**: Get ordinances
  by year

### 5. Product Metadata

- **`get_product_metadata(client_id, product_name)`**: Get detailed
  metadata about a specific product type

## Typical Workflow

``` r
# 1. Find a jurisdiction
clients <- get_clients_in_state("VA")
alexandria_id <- clients %>%
  filter(client_name == "Alexandria") %>%
  pull(client_id)

# 2. List available ordinances
products <- get_client_content(alexandria_id)
zoning_id <- products %>%
  filter(product_name == "Zoning") %>%
  pull(product_id)

# 3. Get current version
job <- get_jobs_latest(product_id = zoning_id)
job_id <- job %>% pull(id)

# 4. Navigate table of contents
toc <- get_codes_toc(job_id = job_id, product_id = zoning_id)

# 5. Extract specific sections
content <- get_codes_content(
  product_id = zoning_id,
  node_id = "ARTIIIREZORE"
)
```

## Key Identifiers

The API uses several types of identifiers that must be obtained
sequentially:

1.  **`state_abbreviation`**: Two-letter state code (e.g., “VA”, “CA”)
2.  **`client_id`**: Unique identifier for a municipality (obtained from
    [`get_clients_in_state()`](https://wcurrangroome.github.io/municoder/reference/get_clients_in_state.md))
3.  **`product_id`**: Unique identifier for an ordinance type (obtained
    from
    [`get_client_content()`](https://wcurrangroome.github.io/municoder/reference/get_client_content.md))
4.  **`job_id`**: Unique identifier for a specific version of an
    ordinance (obtained from
    [`get_jobs_latest()`](https://wcurrangroome.github.io/municoder/reference/get_jobs_latest.md))
5.  **`node_id`**: Unique identifier for a section within an ordinance
    (obtained from
    [`get_codes_toc()`](https://wcurrangroome.github.io/municoder/reference/get_codes_toc.md))

## Data Structure

All functions return tidy dataframes with snake_case column names,
thanks to
[`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html).
The package uses: - `httr2` for API requests - `dplyr` and `tidyr` for
data manipulation - `purrr` for functional programming - `stringr` for
text processing

## Internal Architecture

### Core Helper Functions

- **`build_endpoint(domain, subdomain, parameters)`**: Constructs API
  URLs from components
- **`get_endpoint(endpoint)`**: Executes GET requests and returns JSON
  as R objects

### API Base URL

All endpoints are constructed from: `https://api.municode.com/`

## Use Cases

1.  **Spatial Analysis**: Map ordinance coverage across states/regions
2.  **Comparative Analysis**: Compare ordinance text across
    jurisdictions
3.  **Longitudinal Studies**: Track ordinance changes over time using
    historical jobs
4.  **Text Mining**: Extract and analyze specific regulatory language
    (e.g., density limits, affordable housing provisions)
5.  **Zoning Research**: Analyze residential zone purposes, permitted
    uses, and development standards

## Example from README

The README demonstrates analyzing Alexandria, VA’s residential zoning
“Purpose” statements to identify that the RMF zone is unique in: -
Explicitly mentioning housing affordability - Not capping unit density
in its purpose statement

## Package Metadata

- **Version**: 0.0.0.9000 (development)
- **Author**: Will Curran-Groome
- **License**: MIT
- **Installation**: `renv::install("wcurrangroome/municoder")`
- **Documentation**: <https://wcurrangroome.github.io/municoder/>

## Dependencies

Core dependencies: `cachem`, `dplyr`, `httr2`, `janitor`, `magrittr`,
`memoise`, `purrr`, `rlang`, `stringr`, `tibble`, `tidyr`

## Workflow Helper Functions (NEW)

Three convenience functions simplify common multi-step operations:

- **`get_ordinance_section(state_abbr, client_name, product_name, node_id)`**:
  Get ordinance content in one call
- **`get_ordinance_toc(state_abbr, client_name, product_name)`**: Get
  full table of contents in one call
- **`get_jurisdiction_products(state_abbr, client_name)`**: Get all
  products for a jurisdiction in one call

These functions automatically chain multiple API calls and provide
better error messages.

## Caching Functions (NEW)

Cached versions of frequently-used functions for improved performance:

- **[`get_states_cached()`](https://wcurrangroome.github.io/municoder/reference/get_states_cached.md)**:
  Indefinite cache (states rarely change)
- **`get_clients_in_state_cached(state_abbr)`**: 24-hour cache
- **`get_client_metadata_cached(state_abbr, client_name)`**: 24-hour
  cache
- **`get_client_content_cached(client_id)`**: 6-hour cache
- **`get_product_metadata_cached(client_id, product_name)`**: 6-hour
  cache
- **[`clear_cache()`](https://wcurrangroome.github.io/municoder/reference/clear_cache.md)**:
  Clear all cached data

## Notes for AI Assistants

- The package uses `renv` for dependency management
- README.Rmd generates README.md (edit the .Rmd file, not .md)
- All functions are documented with roxygen2
- The “Tribes” state abbreviation is known to cause errors (see README
  line 51)
- HTML content in ordinance text is stripped and cleaned in
  [`get_codes_content()`](https://wcurrangroome.github.io/municoder/reference/get_codes_content.md)
- **Package structure (RECENTLY REFACTORED)**: The package has been
  modularized into 11 separate R files:
  - `utils-api.R`: API utilities with enhanced error handling
  - `utils-transform.R`: Reusable data transformation helpers
  - `states.R`, `clients.R`, `products.R`, `jobs.R`: Domain-specific
    functions
  - `codes.R`, `ordinances.R`: Content retrieval functions
  - `workflows.R`: High-level workflow helpers (NEW)
  - `cache.R`: Caching layer (NEW)
  - `municoder-package.R`: Package documentation
- See
  [REFACTORING.md](https://wcurrangroome.github.io/municoder/REFACTORING.md)
  for complete details on recent improvements
- Error handling: All API calls include automatic retry logic (up to 3
  attempts) and informative error messages
