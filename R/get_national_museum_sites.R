get_national_museum_sites <- function(){
  start_url <- "https://museum.wales/cardiff/visit/location/"
  start_html <- rvest::read_html(start_url)

  js_block <- start_html %>% rvest::html_element("script:contains('{\"markers\":')") %>% rvest::html_text()

  markers_block <- js_block %>% stringr::str_extract("\\{\"markers\":.+\\}")

  markers <- markers_block %>% jsonlite::parse_json() %>% (function(x){x$markers})()

  nat_mus_sites <- tibble(
    id = integer(0),
    latitude = double(0),
    longitude = double(0),

    name = character(0),
    summary = character(0),
    link_url = character(0),

    cy_name = character(0),
    cy_summary = character(0),
    cy_link_url = character(0),

    image_url = character(0),
    any_alerts = logical(0),
    free = logical(0),
    disabled_person_access = logical(0),
    dogs_welcome = logical(0),
    toilets = logical(0),
    accessible_toilets = logical(0),
    baby_changing = logical(0),
    refreshments = logical(0),

    open = logical(0)
  )


  for(el in markers){

    link_url <- paste0("https://museum.wales/", el$shortname)
    details <- get_national_museum_site_details(link_url)

    nat_mus_sites <- nat_mus_sites %>% add_row(
      id = 1000L + (el$id %>% as.integer()),
      latitude = el$latitude %>% as.double(),
      longitude = el$longitude %>% as.double(),

      name = details$name,
      summary = details$summary,
      link_url = link_url,

      cy_name = details$cy_name,
      cy_summary = details$cy_summary,
      cy_link_url = details$cy_link_url,

      image_url = details$image_url,
      any_alerts = (length(details$alerts) > 0),
      free = details$free,
      disabled_person_access = any(details$facilities == "Disabled person access"),
      dogs_welcome = any(details$facilities == "Dogs welcome"),
      toilets = any(details$facilities == "Toilets"),
      accessible_toilets = any(details$facilities == "Accessible toilets"),
      baby_changing = any(details$facilities == "Baby changing"),
      refreshments = any(details$facilities == "Refreshments")
    )
  }

  nat_mus_sites$open <- TRUE # Bad

  nat_mus_sites <- nat_mus_sites %>%
    mutate(
      summary = if_else(stringr::str_length(summary) > 0, summary, NA_character_),
      cy_summary = if_else(stringr::str_length(summary) > 0, summary, NA_character_)
    )

  nat_mus_sites <- nat_mus_sites %>% sf::st_as_sf(coords=c("longitude","latitude"), crs=4326)

  return(nat_mus_sites)
}