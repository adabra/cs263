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
<title>audchat: <%= roomname %></title>
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
    	var type = message.data.substring(0,3);
    	var content = message.data.substring(3).trim();
    	if (type!= "ima") {
    		content = escapeHtml(content);    		
    	}
    	if (type == "cha") {
			chatbox.innerHTML +=content+"<br>";
			chatbox.scrollTop = chatbox.scrollHeight;    		
    	}
    	else if (type == "ima") {
    		chatbox.innerHTML +=content+"<br>";
			chatbox.scrollTop = chatbox.scrollHeight;
    	}
    	else if (type == "blo") {
    		console.log("BLO");
    		var separator = content.indexOf(";");
    		console.log("separator: "+separator);
    		var name = content.substring(0,separator);
    		console.log("name: "+name);
    		console.log("username: "+document.getElementById('username').innerHTML);
    		console.log(name == document.getElementById('username').innerHTML);
    		if (name == document.getElementById('username').innerHTML.trim()) {
    			var url = content.substring(separator+1);
    			console.log("url: "+url)
				var form = document.getElementById('upload_file');
				form.setAttribute('action', url);  
				console.log("done");
    		}
    	}
    	else if (type == "lea") {
    		document.getElementById(content).remove();
    		chatbox.innerHTML +=content+" has left the room.<br>";
			chatbox.scrollTop = chatbox.scrollHeight;
    	}
    	else if (type == "joi" && document.getElementById('username').innerHTML != content) {
    		var ul = document.getElementById("userslist");
    		var li = document.createElement("li");
    		li.appendChild(document.createTextNode(content));
    		li.setAttribute("id",content);
    		li.setAttribute("class","col-lg-3 col-lg-offset-0")
    		ul.appendChild(li);
    		chatbox.innerHTML +=content+" has entered the room.<br>";
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