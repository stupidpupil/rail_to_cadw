library(tidyverse)

cadw_sites <- sf::st_read("cadw_sites.geojson")

rail_stations <- gtfstools::read_gtfs("merged.walesish.gtfs.zip") %>%
	gtfstools::convert_stops_to_sf() %>%
	filter(stop_name %>% str_detect("Rail Station")) %>%
	mutate(id=stop_id)


options(java.parameters = "-Xmx6G")
r5r_core <- r5r::setup_r5(".")

transit_and_walk_ttm <- r5r::travel_time_matrix(r5r_core, 
	origins=rail_stations, destinations=cadw_sites, mode=c("WALK", "TRANSIT"), max_walk_dist=3000, 
	departure_datetime = lubridate::ymd_hms("2022-06-04T07:00:00"), time_window = 7*60, percentiles=c(20,50,80))

transit_and_walk_ttm %>% saveRDS("transit_and_walk_ttm.rds")

cycle_and_rail_ttm <- r5r::travel_time_matrix(r5r_core, 
	origins=rail_stations, destinations=cadw_sites, mode=c("BICYCLE", "RAIL"), max_walk_dist=3000, max_lts=4,
	departure_datetime = lubridate::ymd_hms("2022-06-04T07:00:00"), time_window = 7*60, percentiles=c(20,50,80))

cycle_and_rail_ttm %>% saveRDS("cycle_and_rail_ttm.rds")
