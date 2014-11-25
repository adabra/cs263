<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreService"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory"%>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ page import="com.google.appengine.api.datastore.Entity"%>
<%@ page import="com.google.appengine.api.datastore.FetchOptions"%>
<%@ page import="java.util.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="/stylesheets/main.css">
<link
	href="http://maxcdn.bootstrapcdn.com/bootswatch/3.3.0/slate/bootstrap.min.css"
	rel="stylesheet">
<title>Welcome</title>
</head>
<body>
	<% 
	DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	Query query = new Query("Room").addSort("name",
			Query.SortDirection.DESCENDING);
	List<Entity> rooms = datastore.prepare(query)
			.asList(FetchOptions.Builder.withLimit(100));
	
	
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
      	<%
		if (request.getAttribute("invalid_username")!=null){
		%>
		Only letters a-z and numbers 0-9 in user names.	
		<%	
		}
		%>
      	<br>
		Choose room:
		<input type="text" name="roomname" id="roomname">
		<%
		if (request.getAttribute("invalid_roomname")!=null){
		%>
		Only letters a-z and numbers 0-9 in room names.	
		<%	
		}
		%>
		<br>
		<input type="submit" value="Join">
    </form>
    
    <div class="col-lg-6">
		<div class="bs-component">
			<div class="well well-lg" style="height: 20vh; overflow: auto"
				id="users">
				<% 
			    for (Entity room : rooms) {
				%>
				<%= 
					//((String)(room.getProperty("name"))).replace("<", "&lt;").replace(">", "&gt;").replace("&", "&amp;").replace("\"", "&quot;")
					room.getProperty("name")
				%>
				<br>
				<% 
			    }
			    %>
			</div>
		</div>
	</div>
    
    

</body>
</html>