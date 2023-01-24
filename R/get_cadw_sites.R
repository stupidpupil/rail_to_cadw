  get_cadw_sites <- function(head_n){
  map_page <- rvest::read_html("https://cadw.gov.wales/visit/places-to-visit/find-a-place-to-visit/map")

  geo_loc_elements <- map_page %>% rvest::html_elements(".monuments-map .geolocation-location")

  cadw_sites <- tibble(
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
    refreshments = logical(0)
  )

  if(!missing(head_n)){
    geo_loc_elements <- geo_loc_elements %>% head(head_n)
  }

  for(el in geo_loc_elements){

    link_url <- rvest::html_elements(el, ".teaser__link") %>% rvest::html_attr("href")
    details <- get_cadw_site_details(link_url)

    cadw_sites <- cadw_sites %>% add_row(
      id = rvest::html_attr(el, "data-views-row-index") %>% as.integer(),
      latitude = rvest::html_attr(el, "data-lat") %>% as.double(),
      longitude = rvest::html_attr(el, "data-lng") %>% as.double(),

      name = details$name,
      summary = details$summary,
      link_url = link_url,

      cy_name = details$cy_name,
      cy_summary = details$cy_summary,
      cy_link_url = details$cy_link_url,

      image_url = paste0("https://cadw.gov.wales/", rvest::html_elements(el, ".teaser__image img") %>% rvest::html_attr("src")),
      any_alerts = (length(details$alerts) > 0),
      free = details$free,
      disabled_person_access = any(details$facilities == "Access guide"), #TODO: Investigate this properly
      dogs_welcome = any(details$facilities == "Dogs welcome"),
      toilets = any(details$facilities == "Toilets"),
      accessible_toilets = any(details$facilities == "Accessible toilets"),
      baby_changing = any(details$facilities == "Baby changing"),
      refreshments = any(details$facilities == "Refreshments")
    )
  }


  open_sites_link_urls <- rvest::read_html("https://cadw.gov.wales/visit/places-to-visit/find-a-place-to-visit/map?open_or_closed=1") %>%
    rvest::html_elements(".teaser__link") %>% rvest::html_attr("href")

  cadw_sites$open <- cadw_sites$link_url %in% open_sites_link_urls

  cadw_sites <- cadw_sites %>%
    mutate(
      summary = if_else(stringr::str_length(summary) > 0, summary, NA_character_),
      cy_summary = if_else(stringr::str_length(summary) > 0, summary, NA_character_)
    )

  cadw_sites <- cadw_sites %>% sf::st_as_sf(coords=c("longitude","latitude"), crs=4326)


  # A series of dubious sensechecks, based on the data
  # as of 6th June

  if(missing(head_n)){
    stopifnot(cadw_sites %>% nrow() > 100)
    stopifnot(cadw_sites %>% nrow() < 200)

    stopifnot(cadw_sites$open %>% sum() > 40)
    stopifnot(cadw_sites$open %>% sum() < cadw_sites %>% nrow())

    stopifnot(cadw_sites$free %>% sum() > 80)
    stopifnot(cadw_sites$free %>% sum() < 120)

    stopifnot(cadw_sites$toilets %>% sum() > 20)
    stopifnot(cadw_sites$toilets %>% sum() < 80)

    stopifnot(cadw_sites$dogs_welcome %>% sum() > 40)
    stopifnot(cadw_sites$dogs_welcome %>% sum() < 100)

    stopifnot(cadw_sites$disabled_person_access %>% sum() > 15)
    stopifnot(cadw_sites$disabled_person_access %>% sum() < 100)
  }

  return(cadw_sites)
}

