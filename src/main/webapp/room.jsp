<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.channel.ChannelService" %>
<%@ page import="com.google.appengine.api.channel.ChannelServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.appengine.api.datastore.Entity"%>
<%@ page import="com.google.appengine.api.datastore.Key"%>
<%@ page import="com.google.appengine.api.datastore.KeyFactory"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreService"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory"%>
<%@ page import="com.google.appengine.api.datastore.FetchOptions"%>

<%
String roomname = request.getParameter("roomname");
String username = (String)(request.getSession().getAttribute("username"));
ChannelService channelService = ChannelServiceFactory.getChannelService();
DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
String token = channelService.createChannel(roomname);

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
        <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.0/js/bootstrap.min.js"></script>
        <link rel="stylesheet" type="text/css" href="/stylesheets/main.css">
        <title><%= roomname %></title>
    </head>
    <body>
    Room: 
    <h1 id='roomname'><%= roomname %></h1>
    Nick: 
    <div><%= username %></div><br>
    <div id='chatbox'></div>
    <div id='users'>
    <% 
    for (Entity user : users) {
	%>
	<%= 
	user.getProperty("name") 
	%>
	<br>
    <% 
    }
    %>
    </div>
   
    <br>
    <input type='text' id='userInput' value='' onkeydown='if (event.keyCode == 13) send()' />
    <input type='button' onclick='send()' value='send'/>
    
    <script>
    var token ="<%=token %>";

	channel = new goog.appengine.Channel('<%=token%>');    
    socket = channel.open();
    var chatbox = document.getElementById('chatbox');
		
	socket.onopen = function() { 
		chatbox.innerHTML += "Channel opened<br>";
		};
    socket.onmessage = function(message) { 
		chatbox.innerHTML += message.data+"<br>";
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