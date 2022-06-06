run_cadw_vs_rail <- function() {

  download_walesish_stuff()

  cadw_sites <- get_cadw_sites()
  unlink("output/cadw_sites.geojson")
  cadw_sites %>% sf::write_sf("output/cadw_sites.geojson")

  origins <- get_origins()
  unlink("output/origins.geojson")
  origins %>% sf::write_sf("output/origins.geojson")

  generate_ttms(origins, cadw_sites)

  write_ttms_as_json()
}