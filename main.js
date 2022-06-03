var ttm;
var cadw_sites;
var origins;

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

  var ret = "https://www.traveline.cymru/journey-planner-results/?search=1&&maxWalkDistanceMetres=3000"

  ret = ret + "&from=" + origin_name.replaceAll(" ", "+")

  ret = ret + "&to=" + dest_name.replaceAll(" ", "+")

  ret = ret + "&time=" + time_for_traveline_cymru_url()

  ret = ret + "&date=" + moment().unix()

  ret = ret + "&timeMode=LeaveAfter&maxChanges=fewest&walkSpeed=3&maxWalkDistanceMetresRestricted="


  return(ret)
}

station_selected = function(e){
  var station_id = $('#station_select').val();

  var dest_cont = $('#destinations_container')
  dest_cont.empty()

  var ttm_row = ttm.find(function(x){return(x.frm == station_id)})

  var station_details = origins.find(function(x){return(x.properties.id == station_id)})

  var sort_order_for_destination = function (dest) {
    var p2s = dest.data.map(function(x){return(x.p2)})
    return(Math.min(...p2s))
  }

  var destinations = ttm_row.data.sort(function(a,b){
    return(sort_order_for_destination(a)-sort_order_for_destination(b))
  });


  $(".filter_checkbox").each(function(i, e){
    console.log(e.name)

    if(e.checked){
      destinations = destinations.filter(function(d){ //Horrendously inefficient
        var site_details = cadw_sites.find(function(cs){return(cs.id == d.to)})
        return(site_details[e.name])
      })
    }
  })

  destinations = destinations.map(function(x){
    var site_details = cadw_sites.find(function(cs){return(cs.id == x.to)})

    var ttm_descs = x.data.sort(function(a,b){return(a.p2-b.p2)})
    var ttm_descs = ttm_descs.map(description_for_ttm_entry).map(function(x){return("<p>"+x+"</p>")}).join("")
    
    dest_cont.append(
      "<div>" +
      "<img src='"+ site_details.image_url + "'>" +
      "<h2><a target='_blank' href='"+site_details.link_url+"'>" + site_details.name + "</a></h2>" +
      "<p class='summary'>" + site_details.summary + ". " + (site_details.free ? "<span class='free'>Free.</span>" : "") + "</p>" +
      (site_details.any_alerts ? "<p class='alerts'><a target='_blank' href='" + site_details.link_url + "''>Visitor alerts</a></p>" : "") +
      ttm_descs +
      "<a class='google_maps_link' target='_blank' href='https://www.google.com/maps/dir/?api=1&travelmode=transit&origin=" + 
        station_details.geometry.coordinates[1] + "," + station_details.geometry.coordinates[0] +"&destination=" +
        site_details.coordinates[1] + "," + site_details.coordinates[0] + "'>Plan journey on Google Maps</a>" +
      //"<a class='traveline_link' target='_blank' href='" + traveline_cymru_url(station_details.properties.name, site_details.name) + "'>Plan journey on Traveline Cymru</a>" +
      "</div>"
    )

  })

}

$(function(){

  var req1 = $.getJSON("origins.geojson?220603T1220", function (origins_data) {
    var station_select = $("#station_select")


    origins = origins_data.features;

    origins.forEach(function(x){
      station_select.append("<option value='"+x.properties.id+"'>" + x.properties.name + "</option>")
    })

    $("#origin_form").on('change', station_selected)

  });

  var req2 = $.getJSON("cadw_sites.geojson?220603T1320", function (cadw_sites_data) {
    cadw_sites = cadw_sites_data.features.map(function(x){return({...(x.properties), ...(x.geometry)})})
  });


  var req3 = $.getJSON("ttm.json?220603T1220", function (ttm_data) {
    ttm = ttm_data
  });

  $.when(req1.done(), req2.done(), req3.done()).then(function(){
    $("#origin_form select").attr('disabled', false)
    $("#origin_form input").attr('disabled', false)
  })

})