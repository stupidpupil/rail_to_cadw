generate_ttms <- function(origins, cadw_sites){
  options(java.parameters = "-Xmx6G")
  r5r_core <- r5r::setup_r5("data-raw/r5r_network_dat")

  departure_datetime <- lubridate::today() %>% lubridate::floor_date('week', week_start=1)
  departure_datetime <- departure_datetime + lubridate::days(5) + lubridate::hours(8)
  departure_datetime <- departure_datetime %>% lubridate::force_tz(tzone="Europe/London")

  transit_and_almost_no_walk_ttm <- r5r::travel_time_matrix(r5r_core, 
    origins=origins, destinations=cadw_sites, mode=c("WALK", "TRANSIT"), max_walk_dist=600, max_trip_duration=180L,
    departure_datetime = departure_datetime, time_window = 4*60, percentiles=c(5,20,33,66))

  transit_and_almost_no_walk_ttm %>% saveRDS("data-raw/transit_and_almost_no_walk_ttm.rds")

  transit_and_walk_ttm <- r5r::travel_time_matrix(r5r_core, 
    origins=origins, destinations=cadw_sites, mode=c("WALK", "TRANSIT"), max_walk_dist=3000, max_trip_duration=180L,
    departure_datetime = departure_datetime, time_window = 4*60, percentiles=c(5,20,33,66))

  transit_and_walk_ttm %>% saveRDS("data-raw/transit_and_walk_ttm.rds")

  walk <- r5r::travel_time_matrix(r5r_core, 
    origins=origins, destinations=cadw_sites, mode=c("WALK"), max_trip_duration=3000/(12*1000/60), 
    departure_datetime = departure_datetime, time_window = 4*60, percentiles=c(5,20,33,66))

  walk %>% saveRDS("data-raw/walk_ttm.rds")

  cycle_and_rail_ttm <- r5r::travel_time_matrix(r5r_core, 
    origins=origins, destinations=cadw_sites, mode=c("BICYCLE", "RAIL"), max_bike_dist=9000, max_lts=4, max_trip_duration=180L,
    departure_datetime = departure_datetime, time_window = 4*60, percentiles=c(5,20,33,66))

  cycle_and_rail_ttm %>% saveRDS("data-raw/cycle_and_rail_ttm.rds")

  cycle <- r5r::travel_time_matrix(r5r_core, 
    origins=origins, destinations=cadw_sites, mode=c("BICYCLE"), max_trip_duration=9000/(12*1000/60), max_lts=4,
    departure_datetime = departure_datetime, time_window = 4*60, percentiles=c(5,20,33,66))

  cycle %>% saveRDS("data-raw/cycle_ttm.rds")

  return(TRUE)
}
