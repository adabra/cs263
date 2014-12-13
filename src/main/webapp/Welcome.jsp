<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" type="text/css" href="/stylesheets/main.css">
<link
	href="http://maxcdn.bootstrapcdn.com/bootswatch/3.3.0/slate/bootstrap.min.css"
	rel="stylesheet">
<title>localchat</title>
</head>
<body>  
    
    <div class="col-lg-6 col-lg-offset-3">
			<div class="bs-component">
				<div class="well well-lg" style="height: 50vh; overflow: auto;">
    				<h1>localchat</h1>
    				<h3>Tell us your location to start using localchat</h3>
					<button class="btn btn-default" onclick="getLocation()">Send location</button>
    			</div>
    		</div>
  	</div>
	
	
	<p id="demo"></p>
        
	<script>
	var x = document.getElementById("demo");
	
	function getLocation() {
	    if (navigator.geolocation) {
	        navigator.geolocation.getCurrentPosition(showPosition, showError);
	    } else { 
	        x.innerHTML = "Geolocation is not supported by this browser.";
	    }
	}
	
	function showPosition(position) {
	    //window.location = "/roomfinder?lat="+position.coords.latitude+"&lon="+position.coords.longitude;
		window.location = "/roomselector.jsp?lat="+position.coords.latitude+"&lon="+position.coords.longitude;
	}
	
	function showError(error) {
	    switch(error.code) {
	        case error.PERMISSION_DENIED:
	            x.innerHTML = "User denied the request for Geolocation."
	            break;
	        case error.POSITION_UNAVAILABLE:
	            x.innerHTML = "Location information is unavailable."
	            break;
	        case error.TIMEOUT:
	            x.innerHTML = "The request to get user location timed out."
	            break;
	        case error.UNKNOWN_ERROR:
	            x.innerHTML = "An unknown error occurred."
	            break;
	    
	    }
	}
	</script>

</body>
</html>