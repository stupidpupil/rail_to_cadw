get_great_little_railway_details <- function(glr_url){

  message("Fetching details for ", glr_url)
  glr_html <- rvest::read_html(glr_url)

  ret <- list()

  ret$name <- glr_html |> rvest::html_node("h1.h2") |> rvest::html_text2() |> tidy_some_text()
  ret$summary <- glr_html |> rvest::html_node(".introduction") |> rvest::html_text2() |> tidy_some_text()
  ret$link_url <- glr_url

  ret$image_url <- glr_html |> rvest::html_nodes("style") |> rvest::html_text() |> 
    stringr::str_extract_all("'https://.+?/img/uploads/railways/.+?/_featuredImageSmall/.+'") |> unlist() |> first() |>
    stringr::str_sub(2,-2)

  ret$cy_link_url <- glr_html |> rvest::html_element("a[hreflang=\"cy-GB\"]") |> rvest::html_attr("href")

  ret$postcode <- glr_html |> rvest::html_nodes("p.h2") |> rvest::html_text2() |> 
    stringr::str_extract_all("[A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2}") |> unlist() |> first()

  if(!is.na(ret$cy_link_url)){
    details_in_welsh <- get_great_little_railway_details(ret$cy_link_url)

    ret$cy_name <- details_in_welsh$name
    ret$cy_summary <- details_in_welsh$summary

    postcode_details <- PostcodesioR::postcode_lookup(ret$postcode)

    ret$latitude <- postcode_details[1, 'latitude']
    ret$longitude <- postcode_details[1, 'longitude']  

  }


  return(ret)
}