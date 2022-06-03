library(tidyverse)

readRDS("cycle_and_rail_ttm.rds") %>% 
	mutate(m = "cr") %>%
	bind_rows(
		readRDS("transit_and_walk_ttm.rds") %>% 
		mutate(m = "t")
	) %>%
	rename(frm = fromId, to = toId, lo = travel_time_p005, hi = travel_time_p066) %>% 
	select(frm, to, lo, hi, m) %>%
	filter(!is.na(lo)) %>%
	group_by(frm) %>% 
	group_nest() %>% 
	mutate(data = map(data, ~.x %>% group_by(to) %>% group_nest())) %>%
	jsonlite::write_json("ttm.json")
