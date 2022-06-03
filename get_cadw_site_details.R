get_cadw_site_details <- function(cadw_site_url){

  message("Fetching details for ", cadw_site_url)
  cadw_site_html <- rvest::read_html(cadw_site_url)

  ret <- list()

  ret$alerts <- cadw_site_html %>% rvest::html_elements(".alert-warning") %>% rvest::html_text2()
  ret$facilities <- cadw_site_html %>% rvest::html_elements(".facility") %>% rvest::html_attr("title") %>% stringr::str_trim()


  # TODO - improve reliability of this
  ret$free <- all(
    cadw_site_html %>% 
    rvest::html_elements(".price__standard") %>% 
    rvest::html_text() %>% 
    stringr::str_trim() == "Free")

  return(ret)
}