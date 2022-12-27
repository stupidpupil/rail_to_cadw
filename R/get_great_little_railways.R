get_great_little_railways <- function(){

  frontpage_html <- rvest::read_html("https://www.greatlittletrainsofwales.co.uk/en/")

  glrs <- tibble(
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

  railway_links <- frontpage_html |> rvest::html_nodes(".railway a") |> 
    rvest::html_attr("href") |> purrr::keep(function(x){x |> stringr::str_detect("/railways/")})


  for(link_url in railway_links){

    details <- get_great_little_railway_details(link_url)

    glrs <- glrs %>% add_row(
      id = 3000L + nrow(glrs),
      latitude = details$latitude,
      longitude = details$longitude,

      name = details$name,
      summary = details$summary,
      link_url = link_url,

      cy_name = details$cy_name,
      cy_summary = details$cy_summary,
      cy_link_url = details$cy_link_url,

      image_url = details$image_url,
      any_alerts = FALSE,
      free = FALSE,
      disabled_person_access = FALSE,
      dogs_welcome = FALSE,
      toilets = TRUE,
      accessible_toilets = FALSE,
      baby_changing = FALSE,
      refreshments = FALSE
    )
  }

  return(glrs)
}