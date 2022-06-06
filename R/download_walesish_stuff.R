download_walesish_stuff <- function(){
  old_opts <- options(timeout=max(options()$timeout,600))
  on.exit(options(old_opts))

  download.file("https://github.com/stupidpupil/wales_ish_otp_graph/releases/latest/download/r5r_network_dat.zip", "data-raw/r5r_network_dat.zip")
  unzip("data-raw/r5r_network_dat.zip", exdir="data-raw")

  download.file("https://github.com/stupidpupil/wales_ish_otp_graph/releases/latest/download/gtfs_and_osm.zip", "data-raw/gtfs_and_osm.zip")
  unzip("data-raw/gtfs_and_osm.zip", exdir="data-raw")
}