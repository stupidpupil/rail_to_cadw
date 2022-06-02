library(tidyverse)

map_page <- rvest::read_html("https://cadw.gov.wales/visit/places-to-visit/find-a-place-to-visit/map")

geo_loc_elements <- map_page %>% rvest::html_elements(".monuments-map .geolocation-location")

cadw_sites <- tibble(
  id = integer(0),
  latitude = double(0),
  longitude = double(0),
  name = character(0),
  summary = character(0),
  link_url = character(0),
  image_url = character(0)
)

for(el in geo_loc_elements){
  cadw_sites <- cadw_sites %>% add_row(
    id = rvest::html_attr(el, "data-views-row-index") %>% as.integer(),
    latitude = rvest::html_attr(el, "data-lat") %>% as.double(),
    longitude = rvest::html_attr(el, "data-lng") %>% as.double(),
    name = rvest::html_elements(el, ".teaser__link") %>% rvest::html_text() %>% stringr::str_trim(),
    summary = rvest::html_elements(el, ".teaser__summary") %>% rvest::html_text() %>% stringr::str_trim(),
    link_url = rvest::html_elements(el, ".teaser__link") %>% rvest::html_attr("href"),
    image_url = paste0("https://cadw.gov.wales/", rvest::html_elements(el, ".teaser__image img") %>% rvest::html_attr("src"))
  )
}

cadw_sites <- cadw_sites %>% sf::st_as_sf(coords=c("longitude","latitude"), crs=4326)

unlink("cadw_sites.geojson")
cadw_sites %>% sf::write_sf("cadw_sites.geojson")
