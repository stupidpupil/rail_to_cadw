get_cadw_site_details <- function(cadw_site_url){

  message("Fetching details for ", cadw_site_url)
  cadw_site_html <- rvest::read_html(cadw_site_url)

  ret <- list()

  ret$name <- cadw_site_html %>% rvest::html_element(".banner__title") %>% rvest::html_text2() %>% tidy_some_text()
  ret$summary <- cadw_site_html %>% rvest::html_element(".lead") %>% rvest::html_text2() %>% tidy_some_text()
  ret$link_url <- cadw_site_url

  language_link_url <- cadw_site_html %>% rvest::html_element(".language-link:not(.is-active)")

  if(language_link_url %>% rvest::html_attr("hreflang") == "cy"){
    ret$cy_link_url <- language_link_url %>% rvest::html_attr("href")
    details_in_welsh <- get_cadw_site_details(ret$cy_link_url)

    ret$cy_name <- details_in_welsh$name
    ret$cy_summary <- details_in_welsh$summary
    ret$cy_facilities <- details_in_welsh$facilities
    ret$cy_alerts <- details_in_welsh$alerts
  }

  ret$alerts <- cadw_site_html %>% rvest::html_elements(".alert-warning") %>% rvest::html_text2()
  ret$facilities <- cadw_site_html %>% rvest::html_elements(".facility") %>% rvest::html_attr("title") %>% tidy_some_text()

  # TODO - improve reliability of this
  ret$free <- all(
    cadw_site_html %>% 
    rvest::html_elements(".price__standard") %>% 
    rvest::html_text() %>% 
    stringr::str_detect("\\b(Free|Am ddim)\\b"))

  return(ret)
}