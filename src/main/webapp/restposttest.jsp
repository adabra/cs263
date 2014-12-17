<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<%--
This jsp is used to generate an input form that can be used to perform post
requests to the REST API, creating new chat rooms by sending the server json
formatted data.
 --%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script src='//code.jquery.com/jquery-1.11.1.min.js'></script>
<title>Test posting to rest API</title>
</head>
<body>


    <input type="text" id="cityname" value="cityname" name="cityname" />
    <input type="text" id="roomname" value="roomname" name="roomname" />
    <input type="text" id="lat" value="lat" name="lat" />
    <input type="text" id="lon" value="lon" name="lon" />

	<input class='col-lg-1 col-md-1 col-sm-1 btn btn-default' 
	style='padding-top: 2px; padding-bottom: 2px;' 
	type='button' onclick='send()' value='send' />

	<script type="text/javascript">
		function send() {
			console.log("in send()");
			var cityname = document.getElementById('cityname').value;
			var roomname = document.getElementById('roomname').value;
			var lat = document.getElementById('lat').value;
			var lon = document.getElementById('lon').value;
			console.log(cityname);
			console.log(roomname);
			console.log(lat);
			console.log(lon);
			
			var xhr = new XMLHttpRequest();
			console.log(xhr);
			xhr.open('POST', "/rest/room/"+cityname, true);
			console.log("etter open");
			xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
			console.log("etter setreqheader");
			xhr.send("{'city':'"+cityname+"';'name':'"+roomname+"';'location':{'latitude':"+lat+";'longitude':"+lon+"}}");
			console.log("etter send");
		};
	</script>
</body>
</html>