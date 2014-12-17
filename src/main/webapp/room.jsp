<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="com.google.appengine.api.channel.ChannelService"%>
<%@ page import="com.google.appengine.api.channel.ChannelServiceFactory"%>
<%@ page import="com.google.appengine.api.datastore.Query"%>
<%@ page import="java.util.List"%>
<%@ page import="com.google.appengine.api.datastore.Entity"%>
<%@ page import="com.google.appengine.api.datastore.Key"%>
<%@ page import="com.google.appengine.api.datastore.KeyFactory"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreService"%>
<%@ page
	import="com.google.appengine.api.datastore.DatastoreServiceFactory"%>
<%@ page import="com.google.appengine.api.datastore.FetchOptions"%>
<%@ page
	import="com.google.appengine.api.blobstore.BlobstoreServiceFactory"%>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService"%>

<%--

This jsp generates the chat room view. You get here via the RoomServlet.
The page consists of 5 main parts:
- The room, city and user name, and a "leave" button
- The list of users currently in the room
- The chat box containing all messages
- The input field for a new text message
- The input and submit button for posting images.

 --%>

<%
//Getting all the required parameters.
String roomname = request.getParameter("roomname");
String cityname = request.getParameter("cityname");
String username = (String)(request.getSession().getAttribute(cityname+":"+roomname));

//Setting up the channel and datastoreservices.
ChannelService channelService = ChannelServiceFactory.getChannelService();
DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
String token = channelService.createChannel(cityname+":"+roomname);
BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

//Query the datastore for a list of users in the room.
Key roomKey = KeyFactory.createKey("Room", roomname);
roomKey = new KeyFactory.Builder("City", cityname).addChild("Room", roomname).getKey();
Query query = new Query("User", roomKey).addSort("name",
		Query.SortDirection.DESCENDING);
List<Entity> users = datastore.prepare(query)
		.asList(FetchOptions.Builder.withLimit(100));
%>

<!DOCTYPE html>
<html>
<head>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<script src='//code.jquery.com/jquery-1.11.1.min.js'></script>
	<script src="/_ah/channel/jsapi"></script>
	<link
		href="http://maxcdn.bootstrapcdn.com/bootswatch/3.3.0/slate/bootstrap.min.css"
		rel="stylesheet">
	<script
		src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
	<script src="http://malsup.github.com/jquery.form.js"></script>
	<link rel="stylesheet" type="text/css" href="/stylesheets/main.css">
	<script type="text/javascript" src="/js/util.js"></script>
	<title><%= roomname %></title>
</head>
<body>
<%-- Roomname, cityname, username and "leave" button --%>
	<div class="col-lg-6 col-lg-offset-3">
		<div class="col-lg-4">
			<b>Room:</b> <span id='roomname'><%= cityname+":"+roomname %></span>
		</div>
		<div class="col-lg-4">
			<b>Nick:</b> <span id='username'><%= username %></span>
		</div>
		<div class="col-lg-4">
			<button class="btn btn-default" onclick="leaveRoom()">
				Leave Room
			</button>
		</div>
	</div>

<%-- List of users in the room --%>
	<div class="col-lg-6 col-lg-offset-3">
		<div class="bs-component">
			<div class="well well-lg" style="height: 20vh; overflow: auto"
				id="users">
				<b>Users:</b><br>
				<ul id="userslist">
				<% 
				String nextname = "";
			    for (Entity user : users) {
					nextname = ((String)(user.getProperty("name"))).replace("<", "&lt;").replace(">", "&gt;").replace("&", "&amp;").replace("\"", "&quot;").trim(); 
				%>
					<li class="col-lg-3" id="<%= nextname %>"> <%= nextname %> </li>
				<% 
			    }
			    %>
			    </ul>
			</div>
		</div>
	</div>

<%-- Chat box containing all messages --%>
	<div class="col-lg-6 col-lg-offset-3">
		<div class="bs-component">
			<div class="well well-lg" style="height: 60vh; overflow: auto"
				id="chatbox">
				<b>Chat:</b><br>
			</div>
		</div>
	</div>

<%-- Input field for text messages --%>	
	<div class="col-lg-6 col-lg-offset-3">
		<input  class='col-lg-11 col-md-11 col-sm-11' type='text' id='userInput' value=''
			onkeydown='if (event.keyCode == 13) send("message", function(){})' />
		<input class='col-lg-1 col-md-1 col-sm-1 btn btn-default' style='padding-top: 2px; padding-bottom: 2px;' type='button' onclick='send("message", function(){})' value='send' />
	</div>

<%-- Image upload buttons --%>
	<div class='col-lg-6 col-lg-offset-3'>
		<div class="well bs-component" style="height: 10vh">		
			<form class="form-horizontal"
				id="upload_file"
				action="<%=blobstoreService.createUploadUrl("/channel/image/?roomname="+cityname+":"+roomname)%>"
				method="post" enctype="multipart/form-data">
				<div class="col-lg-3">
					<input type="file" name="file" style="color: white" accept="image/*">
				</div>
				<div class="col-lg-3 col-lg-offset-2">
					<input type="button" style="padding-top: 2px; padding-bottom: 2px;" class="btn btn-primary" name="submit" value="Submit">
				</div>
			</form>
		</div>
	</div>

	

	<script>
	//Setting up the client side channel
    var token ="<%=token %>";

	channel=new	goog.appengine.Channel('<%=token%>');    
    socket=channel.open();
	var chatbox=document.getElementById('chatbox');	
	
	//Callback function performed on opening of socket.
	//Sends a "join" message to the server.
	socket.onopen=function() { 
		send("join", function(){})
		};
	
	//Callback function performed on receiving a message.
	//Parses the json object, decodes the message and performs
	//the appropriate actions.
    socket.onmessage=function(message){
    	var messageObject = JSON && JSON.parse(message.data) || $.parseJSON(message.data);
    	messageObject.username = messageObject.username.trim();
    	
    	if (messageObject.type!= "image") {
 			//Escape special html characters if message is not an image.
    		messageObject.content = escapeHtml(messageObject.content);    		
    	}
    	if (messageObject.type == "chat" || messageObject.type == "image") {
    		//Display the message in the chat box with time and username
			chatbox.innerHTML +="["+messageObject.time+"] "+
								"["+messageObject.username+"] "+
								messageObject.content+"<br>";
			chatbox.scrollTop = chatbox.scrollHeight;    		
    	}
    	else if (messageObject.type == "blob") {
    		//Update the correct user's blobstore URL after he has uploaded an image.
    		if (messageObject.username == document.getElementById('username').innerHTML.trim()) {
    			var url = messageObject.content;
				var form = document.getElementById('upload_file');
				form.setAttribute('action', url);  
    		}
    	}
    	else if (messageObject.type == "leave") {
    		//Remove user from list of users, and
    		//display a "user left" message in the chat box.
    		document.getElementById(messageObject.username).remove();
    		chatbox.innerHTML +="["+messageObject.time+"] "+
    							messageObject.username+" has left the room.<br>";
			chatbox.scrollTop = chatbox.scrollHeight;
    	}
    	else if (messageObject.type == "join" && document.getElementById('username').innerHTML != messageObject.username) {
    		//Add user to list of users, and
    		//display a "user entered" message in the chat box.
    		var ul = document.getElementById("userslist");
    		var li = document.createElement("li");
    		li.appendChild(document.createTextNode(messageObject.username));
    		li.setAttribute("id",messageObject.username);
    		li.setAttribute("class","col-lg-3 col-lg-offset-0")
    		ul.appendChild(li);
    		chatbox.innerHTML +="["+messageObject.time+"] "+
    							messageObject.username+" has entered the room.<br>";
			chatbox.scrollTop = chatbox.scrollHeight;
    	}
    };
    
    socket.onerror = function() {  
		chatbox.innerHTML += "Channel error<br>";
    };
    socket.onclose = function() {  
		chatbox.innerHTML += "Channel closed<br>";
    };        
 
	//Function for sending messages to the server using ajax.
    function send(type, onreadystate) {
    	var userInput = document.getElementById('userInput').value;
    	var roomName = document.getElementById('roomname').innerHTML;
		
    	var xhr = new XMLHttpRequest();
    	xhr.onreadystatechange = onreadystate;
    	xhr.open('POST', "/channel/"+type+"?message="+userInput+"&roomname="+roomName, true);
    	xhr.send();
    	document.getElementById('userInput').value = '';
    };
    
    //Function called when this user leaves the room.
    //Don't redirect the user until a response is received
    //to make sure the channel stays open long enough for
    //the server to execute the appropriate actions.
    function leaveRoom() {
    	send("leave", function () {window.location.replace('/')});
    };
    
    //jQuery functions used to upload image to blobstore.
    $('#upload_file').submit(function() { 
	    var options = { 
	        clearForm: true        // clear all form fields after successful submit 
	    }; 
	    $(this).ajaxSubmit(options);
	    return false; 
	});
	
	$('[name=submit]').click(function(){
	    $('#upload_file').submit();        
	});
    </script>

</body>
</html>