run_cadw_vs_rail <- function() {

  download_walesish_stuff()

  cadw_sites <- get_cadw_sites() %>%
    mutate(operator = "cadw")

  nat_mus_sites <- get_national_museum_sites() %>%
    mutate(operator = "national_museum_wales")

  glrs <- get_great_little_railways() |>
    mutate(operator = "great_little_railways")

  sites <- cadw_sites %>%
    bind_rows(nat_mus_sites) |>
    bind_rows(glrs)

  unlink("output/sites.geojson")
  sites %>% sf::write_sf("output/sites.geojson")

  origins <- get_origins()
  unlink("output/origins.geojson")
  origins %>% sf::write_sf("output/origins.geojson")

  generate_ttms(origins, sites)

  write_ttms_as_json()
}
