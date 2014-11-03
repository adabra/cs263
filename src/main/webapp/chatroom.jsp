<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="com.google.appengine.api.users.User"%>
<%@ page import="com.google.appengine.api.users.UserService"%>
<%@ page import="com.google.appengine.api.users.UserServiceFactory"%>
<%@ page import="java.util.List"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreService"%>
<%@ page
	import="com.google.appengine.api.datastore.DatastoreServiceFactory"%>
<%@ page import="com.google.appengine.api.datastore.Entity"%>
<%@ page import="com.google.appengine.api.datastore.FetchOptions"%>
<%@ page import="com.google.appengine.api.datastore.Key"%>
<%@ page import="com.google.appengine.api.datastore.KeyFactory"%>
<%@ page import="com.google.appengine.api.datastore.Query"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<html>
<head>
<link href="//maxcdn.bootstrapcdn.com/bootswatch/3.2.0/cyborg/bootstrap.min.css" rel="stylesheet">
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.0/js/bootstrap.min.js"></script>
</head>

<body>
<div class="container">
	<%
		String chatroomName = request.getParameter("chatroomName");
		if (chatroomName == null) {
			chatroomName = "default";
		}
		pageContext.setAttribute("chatroomName", chatroomName);
		UserService userService = UserServiceFactory.getUserService();
		User user = userService.getCurrentUser();
		if (user != null) {
			pageContext.setAttribute("user", user);
	%>

	<p>
		Hello, ${fn:escapeXml(user.nickname)}! (You can <a
			href="<%=userService.createLogoutURL(request.getRequestURI())%>">sign
			out</a>.)
	</p>
	<%
		} else {
	%>
	<p>
		Hello! <a
			href="<%=userService.createLoginURL(request.getRequestURI())%>">Sign
			in</a> to include your name with messages you post.
	</p>
	<%
		}
	%>

	<%
		DatastoreService datastore = DatastoreServiceFactory
				.getDatastoreService();
		Key chatroomKey = KeyFactory.createKey("Chatroom", chatroomName);
		// Run an ancestor query to ensure we see the most up-to-date
		// view of the Messagess belonging to the selected Chatroom.
		Query query = new Query("Message", chatroomKey).addSort("date",
				Query.SortDirection.DESCENDING);
		List<Entity> messages = datastore.prepare(query).asList(
				FetchOptions.Builder.withLimit(5));
		if (messages.isEmpty()) {
	%>
	<p>Chatroom '${fn:escapeXml(chatroomName)}' has no messages.</p>
	<%
		} else {
	%>
	<p>Messages in Chatroom '${fn:escapeXml(chatroomName)}'.</p>
	<%
		for (Entity message : messages) {
				pageContext.setAttribute("message_content",
						message.getProperty("content"));
				if (message.getProperty("user") == null) {
	%>
	<p>An anonymous person wrote:</p>
	<%
		} else {
					pageContext.setAttribute("message_user",
							message.getProperty("user"));
	%>
	<p>
		<b>${fn:escapeXml(message_user.nickname)}</b> wrote:
	</p>
	<%
		}
	%>
	<blockquote>${fn:escapeXml(message_content)}</blockquote>
	<%
		}
		}
	%>

	<form action="/submit" method="post">
		<div>
			<textarea name="content" rows="3" cols="60"></textarea>
		</div>
		<div>
			<input class="btn btn-success" type="submit" value="Post Message" />
		</div>
		<input type="hidden" name="chatroomName"
			value="${fn:escapeXml(chatroomName)}" />
	</form>
	<form action="/chatroom.jsp" method="get">
		<div>
			<input type="text" name="chatroomName"
				value="${fn:escapeXml(chatroomName)}" />
		</div>
		<div>
			<input class= "btn btn-success" type="submit" value="Switch Chatroom" />
		</div>
	</form>
</div>
</body>
</html>