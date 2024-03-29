write_ttms_as_json <- function(output_path = "output/ttm.json"){

  # This tries to improve compressibility
  munge_travel_time = function(tt){
    return(case_when(
      tt < 10 ~ 9,
      TRUE ~ 5L*ceiling(tt/5)
    ))
  }


  ttms <- tibble()

  for(ttm_path in Sys.glob("data-raw/*_ttm.rds")){
    ttms <- ttms %>% bind_rows(
      readRDS(ttm_path) %>%
      mutate(path = basename(ttm_path)) %>%
      rename(frm = from_id, to = to_id, lo = travel_time_p05, hi = travel_time_p66) %>% 
      mutate(lo = munge_travel_time(lo), hi = munge_travel_time(hi)) %>%  
      select(frm, to, lo, hi, path)
    )
  }


  ttms <- ttms %>% 
    filter(!is.na(lo), lo < 120L) %>%
    group_by(frm, to) %>%
    group_modify(function(x, key) {

      #
      # This tries to remove (approximately) redundant combinations of travel times
      #

      if(any(x[x$path == 'walk_ttm.rds',][['lo']] <= x[x$path == 'transit_and_walk_ttm.rds',][['lo']] + 5)){
        x <- x[x$path != 'transit_and_walk_ttm.rds',]
      }

      if(any(x[x$path == 'walk_ttm.rds',][['lo']] <= x[x$path == 'transit_and_almost_no_walk_ttm.rds',][['lo']] + 10)){
        x <- x[x$path != 'transit_and_almost_no_walk_ttm.rds',]
      }

      if(any(x[x$path == 'transit_and_almost_no_walk_ttm.rds',][['lo']] <= x[x$path == 'transit_and_walk_ttm.rds',][['lo']] + 10)){
        x <- x[x$path != 'transit_and_walk_ttm.rds',]
      }

      if(any(x[x$path == 'cycle_ttm.rds',][['lo']] <= x[x$path == 'cycle_and_rail_ttm.rds',][['lo']] + 5)){
        x <- x[x$path != 'cycle_and_rail_ttm.rds',]
      }

      if(any(x[x$path == 'walk_ttm.rds',][['lo']] <= x[x$path == 'cycle_ttm.rds',][['lo']] + 5)){
        x <- x[x$path != 'cycle_ttm.rds',]
      }


      return(x)
    }) %>%
    mutate(
      m = case_when(
        path == 'cycle_ttm.rds' ~ 'c',
        path == 'cycle_and_rail_ttm.rds' ~ 'cr',
        path == 'walk_ttm.rds' ~ 'ww',
        path == 'transit_and_almost_no_walk_ttm.rds' ~ 'tw',
        path == 'transit_and_walk_ttm.rds' ~ 'tww'
      )
    ) %>%
    select(-path) %>%
    filter(!is.na(lo)) %>%
    group_by(frm) %>% 
    group_nest() %>% 
    mutate(data = map(data, ~.x %>% group_by(to) %>% group_nest()))

    unlink("output/ttm.json")
    ttms %>% jsonlite::write_json("output/ttm.json")
}
