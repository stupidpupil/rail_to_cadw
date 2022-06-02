library(tidyverse)

readRDS("cycle_and_rail_ttm.rds") %>% 
	mutate(m = "cr") %>%
	bind_rows(
		readRDS("transit_and_walk_ttm.rds") %>% 
		mutate(m = "t")
	) %>%
	rename(frm = fromId, to = toId, p2 = travel_time_p020, p5 = travel_time_p050, p8=travel_time_p080) %>% 
	filter(!is.na(p2)) %>%
	group_by(frm) %>% 
	group_nest() %>% 
	mutate(data = map(data, ~.x %>% group_by(to) %>% group_nest())) %>%
	jsonlite::write_json("ttm.json")



rail_stations <- gtfstools::read_gtfs("merged.walesish.gtfs.zip") %>%
	gtfstools::convert_stops_to_sf() %>%
	filter(stop_name %>% str_detect("Rail Station")) %>%
	mutate(id=stop_id)
