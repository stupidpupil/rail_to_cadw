get_national_museum_site_details <- function(national_museum_url){
 
  message("Fetching details for ", national_museum_url)
  national_museum_html <- rvest::read_html(national_museum_url)

  ret <- list()

  ret$name <- national_museum_html %>% rvest::html_element(".site_area_title") %>% rvest::html_text2() %>% tidy_some_text()
  ret$link_url <- national_museum_url

  ret$image_url <- national_museum_html %>% rvest::html_element("meta[property=\"og:image:secure_url\"]") %>% rvest::html_attr("content")


  if(is.na(ret$image_url)){
    ret$image_url <- national_museum_html %>% rvest::html_element("meta[property=\"og:image\"]") %>% rvest::html_attr("content")
  }

  ret$image_url <- ret$image_url %>%
    rvest::url_absolute(national_museum_url)


  ret$cy_link_url <- national_museum_html %>% rvest::html_element(".language_switch a") %>% rvest::html_attr("href") %>%
    stringr::str_replace("^(https?:)?//", "https://") 

  ret$cy_name <- rvest::read_html(ret$cy_link_url) %>% rvest::html_element(".site_area_title") %>% rvest::html_text2() %>% tidy_some_text()


  about_url <- paste0(national_museum_url, "/about")
  about_html <- rvest::read_html(about_url)

  ret$summary <- about_html %>% rvest::html_element(".slab h3") %>% rvest::html_text2() %>% tidy_some_text()

  cy_about_url <- about_html %>% rvest::html_element(".language_switch a") %>% rvest::html_attr("href") %>%
    stringr::str_replace("^(https?:)?//", "https://")

  ret$cy_summary <- rvest::read_html(cy_about_url) %>% rvest::html_element(".slab h3") %>% rvest::html_text2() %>% tidy_some_text()

  visit_url <- paste0(national_museum_url, "/visit")
  visit_html <- rvest::read_html(visit_url)

  visit_text <- visit_html %>% rvest::html_text()

  ret$free <- visit_text %>% stringr::str_detect(regex("(free to enter|admission is free|free admission|free visit)", ignore_case=TRUE))

  ret$facilities <- character(0)

  # This is rubbish

  if(visit_text %>% stringr::str_detect("(restaurant|cafe|café)")){
    ret$facilities <- c(ret$facilities, "refreshments")
  }

  #if(visit_text %>% stringr::str_detect("baby changing")){
  #  ret$facilities <- c(ret$facilities, "baby_changing")
  #}

  # Assume all NMW sites have toilets
  #if(visit_text %>% stringr::str_detect("toilets")){
    ret$facilities <- c(ret$facilities, "toilets")
  #}


  return(ret)
}