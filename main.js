var ttm;
var cadw_sites;
var origins;

format_minutes = function(minutes){
  if(minutes < 10){
    return("less than 10")
  }

  return(minutes)
}

description_for_ttm_entry = function(ttme){

 var ret = ""

 ret = ret + format_minutes(ttme.lo)

 if(ttme.hi && ttme.hi != ttme.lo){
  ret = ret + " - " + ttme.hi + " minutes"
 }else{
  if(ttme.hi === undefined){
    ret = ret + " minutes or more"
  }else{
    ret = ret + " minutes"
  }
 }

 switch(ttme.m){
  case 'tw':
    ret = ret + " by public transport"
    break;
  case 'tww':
    ret = ret + " by public transport and walking"
    break;
  case 'ww':
    ret = ret + " by walking"
    break;
  case 'cr':
    ret = ret + " by train and cycling"
    break
  case 'c':
    ret = ret + " by cycling"
    break;
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
    var lows = dest.data.map(function(x){return(x.lo)})
    return(Math.min(...lows))
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

    var ttm_descs = x.data.sort(function(a,b){return(a.lo-b.lo)})
    var ttm_descs = ttm_descs.map(description_for_ttm_entry).map(function(x){return("<p>"+x+"</p>")}).join("")
    
    dest_cont.append(
      "<div>" +
      "<img src='"+ site_details.image_url + "'>" +
      "<h2><a target='_blank' href='"+site_details.link_url+"'>" + site_details.name + "</a></h2>" +
      
      "<p class='summary'>" + 
        (site_details.summary ? site_details.summary + ". " : "") + 
        (site_details.free ? "<span class='free'>Free admission.</span>" : "") + 
      "</p>" +

      (site_details.any_alerts ? "<p class='alerts'><a target='_blank' href='" + site_details.link_url + "''>View visitor notices for this site</a></p>" : "") +
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

  var req1 = $.getJSON("origins.geojson?220606T1350", function (origins_data) {
    var station_select = $("#station_select")


    origins = origins_data.features;

    origins.forEach(function(x){
      station_select.append("<option value='"+x.properties.id+"'>" + x.properties.name + "</option>")
    })

    $("#origin_form").on('change', station_selected)

  });

  var req2 = $.getJSON("cadw_sites.geojson?220613T1300", function (cadw_sites_data) {
    cadw_sites = cadw_sites_data.features.map(function(x){return({...(x.properties), ...(x.geometry)})})
  });


  var req3 = $.getJSON("ttm.json?220606T1350", function (ttm_data) {
    ttm = ttm_data
  });

  $.when(req1.done(), req2.done(), req3.done()).then(function(){
    $("#origin_form select").attr('disabled', false)
    $("#origin_form input").attr('disabled', false)
  })

})