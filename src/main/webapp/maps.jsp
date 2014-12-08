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

<%
		String latString = request.getParameter("lat");
		String lonString = request.getParameter("lon");
		
		if (!Utils.getInstance().isNumeric(latString) 
				|| !Utils.getInstance().isNumeric(lonString)) {
			response.sendRedirect("/");
			return;
		}
		double lat = Double.valueOf(latString);
		double lon = Double.valueOf(lonString);
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

		
		Filter latMaxFilter = new Query.FilterPredicate(
						"maxlat", 
						FilterOperator.GREATER_THAN_OR_EQUAL, 
						lat);
		Filter latMinFilter = new Query.FilterPredicate(
						"minlat", 
						FilterOperator.LESS_THAN_OR_EQUAL, 
						lat);
		Filter lonMaxFilter = new Query.FilterPredicate(
						"maxlon", 
						FilterOperator.GREATER_THAN_OR_EQUAL, 
						lon);
		Filter lonMinFilter = new Query.FilterPredicate(
						"minlon", 
						FilterOperator.LESS_THAN_OR_EQUAL, 
						lon);

		Filter etternavnFilter = new Query.FilterPredicate(
						"etternavn",
						FilterOperator.EQUAL,
						1);

		Query query = new Query("Room", cityKey)
			.setFilter(lonMinFilter)
			.setFilter(lonMaxFilter)
			.setFilter(latMinFilter)
			.setFilter(latMaxFilter);
			//.setFilter(etternavnFilter);
		List<Entity> rooms = datastore.prepare(query)
				.asList(FetchOptions.Builder.withLimit(25));
%>

<!DOCTYPE html>
<html>
  <head>
    <style type="text/css">
      html, body, #map-canvas { height: 100%; margin: 0; padding: 0;}
    </style>
    <script type="text/javascript"
      src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB-v8pZzztNxgir7bZrMT7bzvUF0X7c4Nc">
    </script>
    <script type="text/javascript">
      function initialize() {
        var myLatlng = new google.maps.LatLng(<%= lat %>,<%= lon %>);
        var mapOptions = {
          	center: myLatlng,
          	zoom: 13
        };
        var map = new google.maps.Map(document.getElementById('map-canvas'),
            mapOptions);
        var marker = new google.maps.Marker({
            position: myLatlng,
            map: map,
            title:"Hello World!"
        });
        var rectangles = [
                  		<%
                  			for (int i = 0; i<rooms.size(); i++) {
                  		%>
                  		
                  		new google.maps.Rectangle({
                              strokeColor: '#FF0000',
                              strokeOpacity: 0.8,
                              strokeWeight: 2,
                              fillColor: '#FF0000',
                              fillOpacity: 0.35,
                              map: map,
                              title: "<%= rooms.get(i).getProperty("name")%>",
                              bounds: new google.maps.LatLngBounds(
                                new google.maps.LatLng(<%=rooms.get(i).getProperty("minlat")%>, <%=rooms.get(i).getProperty("minlon")%>),
                                new google.maps.LatLng(<%=rooms.get(i).getProperty("maxlat")%>, <%=rooms.get(i).getProperty("maxlon")%>))
                            })
                  		
                  		<%
                  		if (i+1<rooms.size()) {
                  		%>
                  		,
                  		<%
                  		}
                  		}
                  		%>
                          ] 
      }
      google.maps.event.addDomListener(window, 'load', initialize);
    </script>
  </head>
  <body>
<div id="map-canvas"></div>
  </body>
</html>