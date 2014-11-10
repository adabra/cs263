<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.channel.ChannelService" %>
<%@ page import="com.google.appengine.api.channel.ChannelServiceFactory" %>


<%

ChannelService channelService = ChannelServiceFactory.getChannelService();
String token = channelService.createChannel("logger");

%>

<!DOCTYPE html>
<html>
    <head>
        <script src='//code.jquery.com/jquery-1.7.2.min.js'></script>
        <script src="/_ah/channel/jsapi"></script>
        <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.0/js/bootstrap.min.js"></script>
    </head>
    <body>
    <input type='text' id='username' value ='' /><br>
    <textarea rows='4' cols='50' id='chatbox' style='color: white; background-color: darkgrey' readonly></textarea>
    <br>
    <input type='text' id='userInput' value='' />
    <input type='button' onclick='send()' value='send'/>
    <script>
    var token ="<%=token %>";

	channel = new goog.appengine.Channel('<%=token%>');    
    socket = channel.open();
    var textarea = document.getElementById('chatbox');
		
	socket.onopen = function() { 
		textarea.innerHTML += "\nChannel opened";
		};
    socket.onmessage = function(message) { 
		textarea.innerHTML += "\n"+message.data;
		textarea.scrollTop = textarea.scrollHeight;
    };
    socket.onerror = function() {  
		textarea.innerHTML += "\nChannel error";
    };
    socket.onclose = function() {  
		textarea.innerHTML += "\nChannel closed";
    };        
 
    function send() {
    	var userInput = document.getElementById('userInput').value;
    	var userName = document.getElementById('username').value;
		var date = new Date();
		
		var message = '['+date.getHours()+':'+date.getMinutes()+']['
						+userName+']: '+userInput;
    	var xhr = new XMLHttpRequest();
    	xhr.open('POST', "/test?message="+message, true);
    	xhr.send();
    };
    </script>

    </body>
</html>