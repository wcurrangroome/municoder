
<!-- README.md is generated from README.Rmd. Please edit that file -->

# municoder

<!-- badges: start -->
<!-- badges: end -->

The goal of municoder is to allow users to programmatically navigate the
municode.com API, including all of the ordinances hosted therein.

## Installation

You can install the development version of `library(municoder)` like so:

``` r
renv::install("wcurrangroome/municoder")
```

Check the spatial coverage of municode.com-listed ordinances

``` r
all_states = municoder::get_states()

all_clients = all_states %>%
  dplyr::pull(state_abbreviation) %>%
  purrr::discard(~ str_detect(.x, "Tribes")) %>% ## "Tribes" throws an error for some reason
  purrr::map_dfr(~ get_clients_in_state(.x))

states_sf = tigris::states(cb = TRUE, progress_bar = FALSE) %>%
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

<img src="man/figures/README-map of municode coverage by state-1.png" width="100%" />
Explore an ordinance’s table of contents (TOC):

``` r
## this gives us the client_id
alexandria_client_id = all_clients %>%
  dplyr::filter(state_name == "Virginia", client_name == "Alexandria") %>%
  dplyr::pull(client_id)

## this gives us `product_name`s and associated `product_id`s
alexandria_zoning_product_id = municoder::get_client_content(alexandria_client_id) %>%
  dplyr::filter(product_name == "Zoning") %>%
  dplyr::pull(product_id)

alexandria_zoning_job_id = municoder::get_jobs_latest(product_id = alexandria_zoning_product_id) %>%
  dplyr::pull(id)

## this gives us `id`s for each primary component of the zoning ordinance
municoder::get_codes_toc(
  job_id = alexandria_zoning_job_id, 
  product_id = alexandria_zoning_product_id)
#> # A tibble: 17 × 7
#>    toc_id toc_heading id             heading     has_children parent_id children
#>    <chr>  <chr>       <chr>          <chr>       <lgl>        <chr>     <lgl>   
#>  1 12429  Zoning      THZOORALVI     THE ZONING… FALSE        12429     NA      
#>  2 12429  Zoning      SUHITA         Supplement… FALSE        12429     NA      
#>  3 12429  Zoning      ARTIGERE       ARTICLE I.… TRUE         12429     NA      
#>  4 12429  Zoning      ARTIIDE        ARTICLE II… TRUE         12429     NA      
#>  5 12429  Zoning      ARTIIIREZORE   ARTICLE II… TRUE         12429     NA      
#>  6 12429  Zoning      ARTIVCOOFINZO  ARTICLE IV… TRUE         12429     NA      
#>  7 12429  Zoning      ARTVMIUSZO     ARTICLE V.… TRUE         12429     NA      
#>  8 12429  Zoning      ARTVISPOVZO    ARTICLE VI… TRUE         12429     NA      
#>  9 12429  Zoning      ARTVIISUZORE   ARTICLE VI… TRUE         12429     NA      
#> 10 12429  Zoning      ARTVIIIOREPALO ARTICLE VI… TRUE         12429     NA      
#> 11 12429  Zoning      ARTIXSI        ARTICLE IX… TRUE         12429     NA      
#> 12 12429  Zoning      ARTXHIDIBU     ARTICLE X.… TRUE         12429     NA      
#> 13 12429  Zoning      ARTXIDEAPPR    ARTICLE XI… TRUE         12429     NA      
#> 14 12429  Zoning      ARTXIINONO     ARTICLE XI… TRUE         12429     NA      
#> 15 12429  Zoning      ARTXIIIENMA    ARTICLE XI… TRUE         12429     NA      
#> 16 12429  Zoning      APXAZOMAAM     APPENDIX A… FALSE        12429     NA      
#> 17 12429  Zoning      TAAM           TABLE OF A… FALSE        12429     NA
```

And finally pull out the text for individual sections of an ordinance.

We can see that the “Purpose” statements for each of Alexandria’s
residential zones tell us quite a bit about the rationale for each zone.
For example, we might notice that the RMF zone is the only zone with a
“Purpose” statement that refers to housing affordability–raising the
question why Alexandria’s other zones aren’t also designed to further
housing affordability–and that is also the only zone with a “Purpose”
that does not explicitly refer to a cap on unit density.

``` r
municoder::get_codes_content(
    product_id = alexandria_zoning_product_id, 
    node_id = "ARTIIIREZORE") %>%
  dplyr::pull(id) %>%
  purrr::map_dfr(~ get_codes_content(product_id = alexandria_zoning_product_id, node_id = .x)) %>%
  dplyr::filter(
    !is.na(content),
    stringr::str_detect(heading, "Purpose")) %>%
  dplyr::pull(content)
#>  [1] " The R-20 zone is established to provide and maintain land areas for low density residential neighborhoods of single-unit, two-unit, and multi-unit up to four units dwellings on 20,000 square foot lots. Nonresidential uses of a noncommercial nature which are related to, supportive of and customarily found in a residential neighborhood are also permitted. "                
#>  [2] " The R-12 zone is established to provide and maintain land areas for low density residential neighborhoods of single-unit, two-unit, and multi-unit up to four units dwellings on 12,000 square foot lots. Nonresidential uses of a noncommercial nature which are related to, supportive of and customarily found in a residential neighborhood are also permitted. "                
#>  [3] " The R-8 zone is established to provide and maintain land areas for low density residential neighborhoods of single-unit, two-unit, and multi-unit up to four units dwellings on 8,000 square foot lots. Nonresidential uses of a noncommercial nature which are related to, supportive of and customarily found in a residential neighborhood are also permitted. "                  
#>  [4] " The R-5 zone is established to provide and maintain land areas for low density residential neighborhoods of single-unit, two-unit, and multi-unit up to four units dwellings on 5,000 square foot lots. Nonresidential uses of a noncommercial nature which are related to, supportive of and customarily found in a residential neighborhood are also permitted. "                  
#>  [5] " The R-2-5 zone is established to provide and maintain land areas for low density residential neighborhoods of single-unit, two-unit, and multi-unit up to four units dwellings on 5,000 square foot lots. Nonresidential uses of a noncommercial nature which are related to, supportive of and customarily found in a residential neighborhood are also permitted. "                
#>  [6] " The RA zone is established to provide and maintain land areas for medium density residential neighborhoods in which apartments predominate and in which single-unit, two-unit and townhouse development is permitted. Nonresidential uses of a noncommercial nature which are related to, supportive of and customarily found in such residential neighborhoods are also permitted. "
#>  [7] " The RB zone is established to provide and maintain land areas for medium density residential neighborhoods in which single-unit, two-unit, and townhouse dwellings are permitted. Nonresidential uses of a noncommercial nature which are related to, supportive of and customarily found in such residential neighborhoods are also permitted. "                                    
#>  [8] " The RCX zone is established to provide and maintain land areas for medium density apartment buildings and to permit limited commercial uses in such structures. Nonresidential uses of a noncommercial nature which are related to, supportive of and customarily found in such residential neighborhoods are also permitted. "                                                      
#>  [9] " The RC zone is established to provide and maintain land areas for high density apartment buildings and to permit limited commercial uses in such structures. Nonresidential uses of a noncommercial nature which are related to, supportive of and customarily found in such residential neighborhoods are also permitted. "                                                         
#> [10] " The RM zone is established to provide and maintain land areas for medium density residential neighborhoods of single-unit, two-unit and townhouse dwellings. Nonresidential uses of a noncommercial nature which are related to, supportive of and customarily found in such residential neighborhoods are also permitted. "                                                         
#> [11] " The RS zone is established to provide land areas for low to medium density townhouse development of approximately 15 units per acre which may be appropriate for infill sites in proximity to neighborhoods of single-family detached homes. "                                                                                                                                       
#> [12] " The RT zone is established to provide land areas for low density residential townhouse development at approximately nine units per acre which may be appropriate for infill sites in proximity to neighborhoods of low density single-unit, two-unit, and multi-unit up to four units dwellings. "                                                                                   
#> [13] " The RMF zone is established to provide land areas for multi-unit residential development and to enhance or preserve long-term affordability of housing. The zone would also permit limited neighborhood-serving commercial uses. "
```
