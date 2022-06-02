var ttm;
var cadw_sites;
var stations;

description_for_ttm_entry = function(ttme){

 var ret = ""

 ret = ret + ttme.p2

 if(ttme.p8 && ttme.p8 != ttme.p2){
  ret = ret + " - " + ttme.p8 + " minutes"
 }else{
  ret = ret + " minutes"
 }

 if(ttme.m == "t"){
  ret = ret + " by public transport and walking"
 }else{
  ret = ret + " by train and cycling"
 }

 return(ret)
}


time_for_traveline_cymru_url = function(){
  var now = moment()

  var hour = now.hour()
  var minute = now.minute()

  var minute = Math.ceil(minute/15)*15

  if(minute == 60){
    hour = hour + 1
    minute = 0
  }

  return(hour.toString().padStart(2,"0") + "%3A" + minute.toString().padStart(2,"0"))
}


traveline_cymru_url = function(origin_name, dest_name){

  var ret = "https://www.traveline.cymru/journey-planner-results/?search=1&&maxWalkDistanceMetres=1000"

  ret = ret + "&from=" + origin_name.replaceAll(" ", "+")

  ret = ret + "&to=" + dest_name.replaceAll(" ", "+")

  ret = ret + "&time=" + time_for_traveline_cymru_url()

  ret = ret + "&date=" + moment().unix()

  ret = ret + "&timeMode=LeaveAfter&maxChanges=fewest&walkSpeed=4&maxWalkDistanceMetresRestricted="


  return(ret)
}

station_selected = function(e){
  var station_id = e.target.value;

  var dest_cont = $('#destinations_container')
  dest_cont.empty()

  var ttm_row = ttm.find(function(x){return(x.frm == station_id)})

  var station_details = stations.find(function(x){return(x.properties.stop_id == station_id)})


  var sort_order_for_destination = function (dest) {
    var p2s = dest.data.map(function(x){return(x.p2)})
    return(Math.min(...p2s))
  }

  var destinations = ttm_row.data.sort(function(a,b){
    return(sort_order_for_destination(a)-sort_order_for_destination(b))
  });

  destinations = destinations.map(function(x){
    var site_details = cadw_sites.find(function(cs){return(cs.id == x.to)})

    var ttm_descs = x.data.sort(function(a,b){return(a.p2-b.p2)})
    var ttm_descs = ttm_descs.map(description_for_ttm_entry).map(function(x){return("<p>"+x+"</p>")}).join("")

    console.log(site_details)

   dest_cont.append(
    "<div>" +
    "<img src='"+ site_details.image_url + "'>" +
    "<h2><a target='_blank' href='"+site_details.link_url+"'>" + site_details.name + "</a></h2>" +
    "<p class='summary'>" + site_details.summary + "</p>" +
    ttm_descs +
    "<a target='_blank' href='" + traveline_cymru_url(station_details.properties.stop_name, site_details.name) + "'>Plan journey on Traveline Cymru</a>" +
    "</div>"
    )

  })

}

$(function(){

  $.getJSON("rail_stations.geojson", function (rail_stations) {
    var station_select = $("#station_select")


    stations = rail_stations.features;

    stations.forEach(function(x){
      station_select.append("<option value='"+x.properties.id+"'>" + x.properties.stop_name + "</option>")
    })

    station_select.on('change', station_selected)

  });

  $.getJSON("cadw_sites.geojson", function (cadw_sites_data) {
    cadw_sites = cadw_sites_data.features.map(function(x){return({...(x.properties), ...(x.geometry)})})
  });


  $.getJSON("ttm.json", function (ttm_data) {
    ttm = ttm_data
  });


})