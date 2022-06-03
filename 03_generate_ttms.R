library(tidyverse)

cadw_sites <- sf::st_read("cadw_sites.geojson")

origins <- sf::st_read("origins.geojson")

options(java.parameters = "-Xmx6G")
r5r_core <- r5r::setup_r5(".")

transit_and_almost_no_walk_ttm <- r5r::travel_time_matrix(r5r_core, 
	origins=origins, destinations=cadw_sites, mode=c("WALK", "TRANSIT"), max_walk_dist=1000, 
	departure_datetime = lubridate::ymd_hms("2022-06-04T07:00:00"), time_window = 4*60, percentiles=c(20,50,80))

transit_and_almost_no_walk_ttm %>% saveRDS("transit_and_almost_no_walk_ttm.rds")

transit_and_walk_ttm <- r5r::travel_time_matrix(r5r_core, 
	origins=origins, destinations=cadw_sites, mode=c("WALK", "TRANSIT"), max_walk_dist=3000, 
	departure_datetime = lubridate::ymd_hms("2022-06-04T07:00:00"), time_window = 4*60, percentiles=c(20,50,80))

transit_and_walk_ttm %>% saveRDS("transit_and_walk_ttm.rds")

cycle_and_rail_ttm <- r5r::travel_time_matrix(r5r_core, 
	origins=origins, destinations=cadw_sites, mode=c("BICYCLE", "RAIL"), max_walk_dist=3000, max_lts=4,
	departure_datetime = lubridate::ymd_hms("2022-06-04T07:00:00"), time_window = 4*60, percentiles=c(20,50,80))

cycle_and_rail_ttm %>% saveRDS("cycle_and_rail_ttm.rds")
