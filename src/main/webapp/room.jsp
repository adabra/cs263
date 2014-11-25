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
String username = (String)(request.getSession().getAttribute("username"));
ChannelService channelService = ChannelServiceFactory.getChannelService();
DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
String token = channelService.createChannel(roomname);
BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

Key roomKey = KeyFactory.createKey("Room", roomname);
Query query = new Query("User", roomKey).addSort("name",
		Query.SortDirection.DESCENDING);
List<Entity> users = datastore.prepare(query)
		.asList(FetchOptions.Builder.withLimit(100));
%>

<!DOCTYPE html>
<html>
<head>
<script src='//code.jquery.com/jquery-1.7.2.min.js'></script>
<script src="/_ah/channel/jsapi"></script>
<link
	href="http://maxcdn.bootstrapcdn.com/bootswatch/3.3.0/slate/bootstrap.min.css"
	rel="stylesheet">
<script
	src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
<link rel="stylesheet" type="text/css" href="/stylesheets/main.css">
<script type="text/javascript" src="/js/util.js"></script>
<title><%= roomname %></title>
</head>
<body>
	<div class="col-lg-6 col-lg-offset-3">
		<div class="col-lg-4">
			<b>Room:</b> <span id='roomname'><%= roomname %></span>
		</div>
		<div class="col-lg-4">
			<b>Nick:</b> <%= username %>
		</div>
	</div>

	<div class="col-lg-6 col-lg-offset-3">
		<div class="bs-component">
			<div class="well well-lg" style="height: 20vh; overflow: auto"
				id="users">
				<b>Users:</b><br>
				<% 
			    for (Entity user : users) {
				%>
				<%= 
						((String)(user.getProperty("name"))).replace("<", "&lt;").replace(">", "&gt;").replace("&", "&amp;").replace("\"", "&quot;") 
					%>
				<br>
				<% 
			    }
			    %>
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
			onkeydown='if (event.keyCode == 13) send()' />
		<input class='col-lg-1 col-md-1 col-sm-1' type='button' onclick='send()' value='send' />
	</div>

	<div class='col-lg-6 col-lg-offset-3'>
		<div class="well bs-component" style="height: 20vh">
			<form class="form-horizontal"
				action="<%=blobstoreService.createUploadUrl("/upload")%>"
				method="post" enctype="multipart/form-data">
				<fieldset>
					<b>Upload image to gallery</b>
					<br>
					<div class="form-group">
						<label for="inputTitle" class="col-lg-2 control-label">Title</label>
						<div class="col-lg-10">
							<input type="text" class="form-control" id="inputTitle"
								placeholder="Title">
						</div>
					</div>
					<div class="form-group">
						<label for="inputFile" class="col-lg-2 control-label">File</label>
						<div class="col-lg-10">
							<input type="file" id="inputFile" placeholder="File" name="image"
								style="color: white">
						</div>
						<div class="form-group">
							<div class="col-lg-10 col-lg-offset-10">
								<button type="submit" class="btn btn-primary">Submit</button>
							</div>
						</div>
					</div>
				</fieldset>
			</form>
		</div>
	</div>

	<script>
    var token ="<%=token %>";

	channel=new	goog.appengine.Channel('<%=token%>');    
    socket=channel.open();
	var chatbox=document.getElementById('chatbox');	
	socket.onopen=function() { 
		chatbox.innerHTML +="Channel opened<br>";
		};
    socket.onmessage=function(message){ 
		chatbox.innerHTML +=escapeHtml(message.data)+"<br>";
		chatbox.scrollTop = chatbox.scrollHeight;
    };
    socket.onerror = function() {  
		chatbox.innerHTML += "Channel error<br>";
    };
    socket.onclose = function() {  
		chatbox.innerHTML += "Channel closed<br>";
    };        
 
    function send() {
    	var userInput = document.getElementById('userInput').value;
    	var roomName = document.getElementById('roomname').innerHTML;
		
    	var xhr = new XMLHttpRequest();
    	xhr.open('POST', "/test?message="+userInput+"&roomname="+roomName, true);
    	xhr.send();
    	document.getElementById('userInput').value = '';
    };
    
    </script>

</body>
</html>