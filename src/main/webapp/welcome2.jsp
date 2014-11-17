<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Welcome</title>
</head>
<body>
	<% 
	
	String username = request.getParameter("username");
	String roomname = request.getParameter("roomname");

	
	if (request.getAttribute("name_taken")!=null) { 
	%>
		Nickname <%= username %> 
		unavailable in room <%= roomname %>
		<br>
	<%
	}
	else {}
	%>
	
	
	<form action="/join" method="post">
    	Choose nickname:
      	<input type="text" name="username">
      	<input type="submit">
      	<br>
		Choose room:
		<input type="text" name="roomname">
    </form>

</body>
</html>