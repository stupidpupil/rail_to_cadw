library(tidyverse)

rail_stations <- gtfstools::read_gtfs("merged.walesish.gtfs.zip") %>%
	gtfstools::convert_stops_to_sf() %>%
	filter(stop_name %>% str_detect(".+ (Rail|Bus) Station$")) %>%
	mutate(id=stop_id)

rail_stations <- rail_stations %>% group_by(stop_name) %>%
	arrange(stringr::str_length(stop_id)) %>%
	slice_head(n = 1)

rail_stations <- rail_stations %>%
	rename(name = stop_name) %>%
	select(name, id)

towns_and_cities <- osmextract::oe_read("walesish.osm.pbf", layer="points", vectortranslate_options = 
	c("-select", "osm_id, place, name", "-where", "place IN ('town', 'city')")) %>%
	mutate(id = paste0("osm", row_number())) %>%
	select(id, name)

origins <- rail_stations %>% bind_rows(towns_and_cities) %>% arrange(name)

unlink("origins.geojson")
origins %>% sf::write_sf("origins.geojson")
