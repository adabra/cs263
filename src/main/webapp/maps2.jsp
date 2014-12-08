<%@ page import="com.google.appengine.api.datastore.DatastoreService"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreService"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory"%>
<%@ page import="com.google.appengine.api.datastore.Entity"%>
<%@ page import="com.google.appengine.api.datastore.FetchOptions"%>
<%@ page import="com.google.appengine.api.datastore.Key"%>
<%@ page import="com.google.appengine.api.datastore.KeyFactory"%>
<%@ page import="com.google.appengine.api.datastore.Query"%>
<%@ page import="com.google.appengine.api.datastore.Query.Filter"%>
<%@ page import="com.google.appengine.api.datastore.Query.FilterOperator"%>
<%@ page import="com.google.appengine.api.datastore.Query.FilterOperator"%>
<%@ page import="cs263project.cs263project.Utils"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="com.google.appengine.api.datastore.GeoPt"%>

<%
		String latString = request.getParameter("lat");
		String lonString = request.getParameter("lon");
		
		if (!Utils.getInstance().isNumeric(latString) 
				|| !Utils.getInstance().isNumeric(lonString)) {
			response.sendRedirect("/");
			return;
		}
		float lat = Float.valueOf(latString);
		float lon = Float.valueOf(lonString);
		float maxLat = lat+0.002f;
		float minLat = lat-0.002f;
		float maxLon = lon+0.002f;
		float minLon = lon-0.002f;
		
		String city = request.getHeader("X-AppEngine-City");
		System.out.println("lat: "+lat+"\nlon: "+lon+"\ncity: "+city);
		if (city==null) {
			city = request.getParameter("city");
		}
		if (city == null) {
			city = "goleta";
		}
		Key cityKey = KeyFactory.createKey("City", city);
		
		
		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

		
		//Filter latMaxFilter = new Query.FilterPredicate(
		//				"lat", 
		//				FilterOperator.GREATER_THAN_OR_EQUAL, 
		//				lat-0.001);
		//Filter latMinFilter = new Query.FilterPredicate(
		//				"lat", 
		//				FilterOperator.LESS_THAN_OR_EQUAL, 
		//				lat+0.001);
		//Filter lonMaxFilter = new Query.FilterPredicate(
		//				"lon", 
		//				FilterOperator.GREATER_THAN_OR_EQUAL, 
		//				lon-0.001);
		//Filter lonMinFilter = new Query.FilterPredicate(
		//				"lon", 
		//				FilterOperator.LESS_THAN_OR_EQUAL, 
		//				lon+0.001);

		//Filter etternavnFilter = new Query.FilterPredicate(
		//				"etternavn",
		//				FilterOperator.EQUAL,
		//				1);

		Query query = new Query("Room", cityKey);
			//.setFilter(lonMinFilter)
			//.setFilter(lonMaxFilter)
			//.setFilter(latMinFilter)
			//.setFilter(latMaxFilter);
			//.setFilter(etternavnFilter);
		List<Entity> rooms = datastore.prepare(query)
				.asList(FetchOptions.Builder.withLimit(500));
		
		List<Entity> reachableRooms = new ArrayList<Entity>();
		GeoPt loc;
		float roomLat;
		float roomLon;
		for (Entity room : rooms) {
			loc = (GeoPt)room.getProperty("location");
			roomLat = loc.getLatitude();
			roomLon = loc.getLongitude();
			if (roomLat>minLat && roomLat<maxLat
					&&roomLon>minLon && roomLon<maxLon) {
				reachableRooms.add(room);
			}
		}
%>

<!DOCTYPE html>
<html>
  <head>
  <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <style type="text/css">
      html, body, #map-canvas { height: 100%; margin: 0; padding: 0;}
    </style>
    <link
	href="http://maxcdn.bootstrapcdn.com/bootswatch/3.3.0/slate/bootstrap.min.css"
	rel="stylesheet">
    <script type="text/javascript"
      src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB-v8pZzztNxgir7bZrMT7bzvUF0X7c4Nc">
    </script>
    
  </head>
  <body>
  <div class="col-lg-6 col-lg-offset-3" style="height:70%; width:50%;">
		<div class="bs-component" style="height:100%; width:100%;">
			<div class="well well-lg" style="overflow: auto; height:100%; width:100%;">
				<div id="map-canvas"></div>
			</div>
		</div>
	</div>
	
	<script type="text/javascript">
    	var rooms;
    	var markers;
    	var infowindow;
      function initialize() {
        var myLatlng = new google.maps.LatLng(<%= lat %>,<%= lon %>);
        var mapOptions = {
          	center: myLatlng,
          	zoom: 15,
          	streetViewControl: false
        };
        var map = new google.maps.Map(document.getElementById('map-canvas'),
            mapOptions);
        
        var marker = new google.maps.Marker({
            position: new google.maps.LatLng(34.436041,-119.830595),
            map: map,
            title:"Hello World!"
            })
        
        rooms = [
                		<%
                			for (int i = 0; i<reachableRooms.size(); i++) {
                		%>
                		{lat: <%= ((GeoPt)reachableRooms.get(i).getProperty("location")).getLatitude() %>,
                		lon: <%= ((GeoPt)reachableRooms.get(i).getProperty("location")).getLongitude() %>,
                		name: "<%= reachableRooms.get(i).getProperty("name") %>" }
                		
                		<%
                		if (i+1<reachableRooms.size()) {
                		%>
                		,
                		<%
                		}
                		}
                		%>
                        ] ;
        console.log("rooms: "+rooms.length);
        
        markers = [];
        for (i = 0; i<rooms.length; i++) {
        	markers[markers.length] = new google.maps.Marker({
                position: new google.maps.LatLng(rooms[i].lat, rooms[i].lon),
                map: map,
                title:rooms[i].name
                })
        }
        console.log("markers: "+markers.length);
        
     
        
        infowindow = new google.maps.InfoWindow({
            content: "HEI"
        	});
        
        var name;
        for (j = 0; j<rooms.length; j++) {
        	name = rooms[j].name;
	        google.maps.event.addListener(markers[j], 'click', function() {
	        	  	infowindow.setContent(name);
	        	    infowindow.open(map,markers[j]);
	          		});      
        }
        console.log("FERDIG");
        
      };
      
        
        
      google.maps.event.addDomListener(window, 'load', initialize);
    </script>
	
  </body>
</html>