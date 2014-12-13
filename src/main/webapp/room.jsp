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

<%
String roomname = request.getParameter("roomname");
String cityname = request.getParameter("cityname");
String username = (String)(request.getSession().getAttribute(cityname+":"+roomname));

System.out.println("IN ROOM.JSP:\nroomname: "+roomname+"\ncityname: "+cityname+"\nusername: "+username);

ChannelService channelService = ChannelServiceFactory.getChannelService();
DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
String token = channelService.createChannel(cityname+":"+roomname);
BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

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
	<div class="col-lg-6 col-lg-offset-3">
		<div class="col-lg-4">
			<b>Room:</b> <span id='roomname'><%= cityname+":"+roomname %></span>
		</div>
		<div class="col-lg-4">
			<b>Nick:</b> <span id='username'><%= username %></span>
		</div>
		<div class="col-lg-4">
			<button class="btn btn-default" onclick="leaveRoom();window.location.replace('/')">
				Leave Room
			</button>
		</div>
	</div>

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

	<div class="col-lg-6 col-lg-offset-3">
		<div class="bs-component">
			<div class="well well-lg" style="height: 60vh; overflow: auto"
				id="chatbox">
				<b>Chat:</b><br>
			</div>
		</div>
	</div>
	
	<div class="col-lg-6 col-lg-offset-3">
		<input  class='col-lg-11 col-md-11 col-sm-11' type='text' id='userInput' value=''
			onkeydown='if (event.keyCode == 13) send("message")' />
		<input class='col-lg-1 col-md-1 col-sm-1 btn btn-default' style='padding-top: 2px; padding-bottom: 2px;' type='button' onclick='send("message")' value='send' />
	</div>

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
    var token ="<%=token %>";

	channel=new	goog.appengine.Channel('<%=token%>');    
    socket=channel.open();
	var chatbox=document.getElementById('chatbox');	
	socket.onopen=function() { 
		//chatbox.innerHTML +="Channel opened<br>";
		send("join")
		};
		
    socket.onmessage=function(message){
    	var messageObject = JSON && JSON.parse(message.data) || $.parseJSON(message.data);
    	messageObject.username = messageObject.username.trim();
    	
    	if (messageObject.type!= "image") {
    		messageObject.content = escapeHtml(messageObject.content);    		
    	}
    	if (messageObject.type == "chat" || messageObject.type == "image") {
			chatbox.innerHTML +="["+messageObject.time+"] "+
								"["+messageObject.username+"] "+
								messageObject.content+"<br>";
			chatbox.scrollTop = chatbox.scrollHeight;    		
    	}
    	else if (messageObject.type == "blob") {
    		console.log("BLOB");    		
    		if (messageObject.username == document.getElementById('username').innerHTML.trim()) {
    			var url = messageObject.content;
    			console.log("url: "+url)
				var form = document.getElementById('upload_file');
				form.setAttribute('action', url);  
				console.log("done");
    		}
    	}
    	else if (messageObject.type == "leave") {
    		document.getElementById(messageObject.username).remove();
    		chatbox.innerHTML +="["+messageObject.time+"] "+
    							messageObject.username+" has left the room.<br>";
			chatbox.scrollTop = chatbox.scrollHeight;
    	}
    	else if (messageObject.type == "join" && document.getElementById('username').innerHTML != messageObject.username) {
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
 
    function send(type) {
    	var userInput = document.getElementById('userInput').value;
    	var roomName = document.getElementById('roomname').innerHTML;
		
    	var xhr = new XMLHttpRequest();
    	xhr.open('POST', "/channel/"+type+"?message="+userInput+"&roomname="+roomName, true);
    	xhr.send();
    	document.getElementById('userInput').value = '';
    };
    
    function leaveRoom() {
    	send("leave");
    };
    
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