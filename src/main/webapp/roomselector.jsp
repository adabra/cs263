<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreService"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory"%>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ page import="com.google.appengine.api.datastore.Entity"%>
<%@ page import="com.google.appengine.api.datastore.FetchOptions"%>
<%@ page import="java.util.List" %>
<%@ page import="com.google.appengine.api.datastore.Key"%>
<%@ page import="com.google.appengine.api.datastore.KeyFactory"%>
<%@ page import="com.google.appengine.api.datastore.Query"%>
<%@ page import="com.google.appengine.api.datastore.Query.Filter"%>
<%@ page import="com.google.appengine.api.datastore.Query.FilterOperator"%>
<%@ page import="cs263project.cs263project.Validator"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="com.google.appengine.api.datastore.GeoPt"%>

<%--

This jsp renders the room selection page to the user.
The page consists of 4 main parts:
- An input field for choosing a user name.
- An input field for creating a new room.
- A list of existing rooms within the user's range.
- A map displaying the rooms in the user's city,
  and the range within the user can join rooms.
 --%>

<%
		String latString = request.getParameter("lat");
		String lonString = request.getParameter("lon");
		
		//validate request parameters.
		if (latString == null
				|| lonString == null
				|| !Validator.isNumeric(latString) 
				|| !Validator.isNumeric(lonString)) {
			response.sendRedirect("/");
			return;
		}
		
		float lat = Float.valueOf(latString);
		float lon = Float.valueOf(lonString);
		
		//validate paramter ranges.
		if (!Validator.isValidLatitude(lat) || !Validator.isValidLongitude(lon)) {
			response.sendRedirect("/");
			return;
		}
		
		//Calculate user's range.
		float maxLat = lat+0.002f;
		float minLat = lat-0.002f;
		float maxLon = lon+0.002f;
		float minLon = lon-0.002f;
		
		//Decide user's city.
		String city = request.getHeader("X-AppEngine-City");
		System.out.println("lat: "+lat+"\nlon: "+lon+"\ncity: "+city);
		if (city == null) {
			city = "no-city";
		}
		
		//Get all rooms in user's city from the datastore.
		Key cityKey = KeyFactory.createKey("City", city);
		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
		Query query = new Query("Room", cityKey);
		List<Entity> rooms = datastore.prepare(query)
				.asList(FetchOptions.Builder.withLimit(500));
	
		//Find all the rooms within the user's range.
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
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link
	href="http://maxcdn.bootstrapcdn.com/bootswatch/3.3.0/slate/bootstrap.min.css"
	rel="stylesheet">
	<link rel="stylesheet" type="text/css" href="/stylesheets/main.css">
	<script type="text/javascript"
      src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB-v8pZzztNxgir7bZrMT7bzvUF0X7c4Nc">
    </script>
    <style type="text/css">
      html, body, #map-canvas { height: 100%; margin: 0; padding: 0;}
    </style>
<title>localchat</title>
</head>
<body>
	<% 
	//Get parameters
	String username = request.getParameter("username");
	String roomname = request.getParameter("roomname");

	//Provide feedback on invalid input if necessary.
	if (request.getAttribute("name_taken")!=null) { 
	%>
		Nickname <%= username %> 
		unavailable in room <%= roomname %>
		<br>
	<%
	}
	else if(request.getAttribute("out_of_range")!=null) {
	%>
		Room <%= roomname  %> 
		out of range
	<%
	}
	%>
	
	<%-- Input fields for user name and room name if creating new room --%>
	<form action="/room" method="post" id="joinform">
		<div class="col-lg-3 col-lg-offset-3">
			<div class="bs-component">
				<div class="well well-lg" style="height: 10vh; overflow: auto; padding: 10px; ">
			      	<input type="text" name="username" id="username" placeholder="Choose nickname">
			      	<%
					if (request.getAttribute("invalid_username")!=null){
					%>
					<br>
					Only letters a-z and numbers 0-9 in user names.	
					<%	
					}
					%>
					<input type="hidden" name="lat" value="<%= latString %>">
					<input type="hidden" name="lon" value="<%= lonString %>">	
			   </div>
			</div>
		</div>
		
		<div class="col-lg-3">
			<div class="bs-component">
				<div class="well well-lg" style="height: 10vh; overflow: auto">
					<input type="text" name="roomname" id="roomname" placeholder="Create new room">
					<input type="submit" value="Create" class="btn btn-default">
					<%
					if (request.getAttribute("invalid_roomname")!=null){
					%>
					<br>
					Only letters a-z and numbers 0-9 in room names.	
					<%	
					}
					%>				
				</div>
			</div>
		</div>
	</form>
    
    <%-- List of rooms within the user's range. User clicks a list item to join the room --%>
    <div class="col-lg-6 col-lg-offset-3">
		<div class="bs-component">
			<div class="well well-lg" style="height: 20vh; overflow: auto">
				<b>Rooms in range, click to join:</b><br>
				<ul id="roomslist">
				<% 
				String nextname = "";
			    for (Entity room : reachableRooms) {
					nextname =   (String)room.getProperty("name");
				%>
					<li class="col-lg-3" id="<%= nextname %>"><linkbutton onclick="submitForm('<%= nextname %>')"> <%= nextname %> </linkbutton></li>
				<% 
			    }
			    %>
			    </ul>
			</div>
		</div>
	</div>
	
	<%-- Map showing the rooms in the user's city, and the range of the user --%>
	<div class="col-lg-6 col-lg-offset-3" style="height:70%;">
		<div class="bs-component" style="height:100%; width:100%;">
			<div class="well well-lg" style="overflow: auto; height:100%; width:100%;">
				<b>Rooms in your area, red rectangle indicating your range</b>
				<div id="map-canvas"></div>
			</div>
		</div>
	</div>
	
	<%-- Javascript for Google Maps functionality --%>
	<script type="text/javascript">
    	var rooms;
    	var markers;
    	var infowindow;
    
    <%-- Initialize the map object--%>
      function initialize() {
        var myLatlng = new google.maps.LatLng(<%= lat %>,<%= lon %>);
        var mapOptions = {
          	center: myLatlng,
          	zoom: 15,
          	streetViewControl: false
        };
        var map = new google.maps.Map(document.getElementById('map-canvas'),
            mapOptions);
        
        <%-- Draw a red rectangle representing the user's range --%>
        new google.maps.Rectangle({
            strokeColor: '#FF0000',
            strokeOpacity: 0.8,
            strokeWeight: 2,
            fillColor: '#FF0000',
            fillOpacity: 0.35,
            map: map,
            title: "User",
            bounds: new google.maps.LatLngBounds(
              new google.maps.LatLng(<%=lat-0.002%>, <%=lon-0.002%>),
              new google.maps.LatLng(<%=lat+0.002%>, <%=lon+0.002%>))
          });
        
        <%-- An array of rooms needed to generate markers on the map --%>
        rooms = [
                		<%
                			for (int i = 0; i<rooms.size(); i++) {
                		%>
                		{lat: <%= ((GeoPt)rooms.get(i).getProperty("location")).getLatitude() %>,
                		lon: <%= ((GeoPt)rooms.get(i).getProperty("location")).getLongitude() %>,
                		name: "<%= rooms.get(i).getProperty("name") %>" }
                		<%
                		if (i+1<rooms.size()) {
                		%>
                		,
                		<%
                		}
                		}
                		%>
                        ] ;
        
        <%-- An array of markers to be placed on the map, representing rooms --%>
        markers = [];
        for (i = 0; i<rooms.length; i++) {
        	markers[markers.length] = new google.maps.Marker({
                position: new google.maps.LatLng(rooms[i].lat, rooms[i].lon),
                map: map,
                title:rooms[i].name
                })
        }
      };
       
      google.maps.event.addDomListener(window, 'load', initialize);
      
      <%-- Function for submitting form when user clicks a room name --%>
      function submitForm(roomname) {
    	  document.getElementById("roomname").value= roomname;
    	  document.getElementById("joinform").submit();
      }
      
    </script>
</body>
</html>