tidy_some_text <- function(some_text){
  some_text %>%
    stringr::str_squish() %>%
    stringr::str_replace("\\.$", "")
}