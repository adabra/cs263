package cs263project.cs263project;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;

public class RoomServlet extends HttpServlet{

	@Override
	public void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		
		boolean invalidNames = false;
		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

		String roomname = request.getParameter("roomname").trim();
		String username = request.getParameter("username").trim();
		System.out.println("USERNAME"+username);
		Key roomKey = KeyFactory.createKey("Room", roomname);
		
		//Check roomname validity
		if (!Utils.getInstance().isValidName(roomname)){
			request.setAttribute("invalid_roomname", Boolean.TRUE);
			invalidNames = true;
		}
		//Check username validity
		if (!Utils.getInstance().isValidName(username)){
			request.setAttribute("invalid_username", Boolean.TRUE);
			invalidNames = true;
		}
		if (invalidNames) {
			request.getRequestDispatcher("/welcome.jsp").
			forward(request, response);
			return;
		}
		
		//Check if room exists
		Query query = new Query("Room", roomKey);
		if (datastore.prepare(query).asSingleEntity() == null) {
			//New room
			Entity room = new Entity("Room", roomKey);
			room.setProperty("name", roomname);
			datastore.put(room);
			
		}	
		
		query = new Query("User", roomKey).addSort("name",
				Query.SortDirection.ASCENDING);
		List<Entity> users = datastore.prepare(query)
				.asList(FetchOptions.Builder.withLimit(100));
		boolean nameTaken = false;
		for (Entity e : users) {
			if (((String)e.getProperty("name")).equals(username)) {
				nameTaken = true;
				break;
			}
			
		}
		
		if (nameTaken) {
			request.setAttribute("name_taken", Boolean.TRUE);
			request.getRequestDispatcher("/welcome.jsp").
			forward(request, response);
			//response.sendRedirect("/welcome.jsp?roomname="+roomname+"&username="+username);
		}
		else {
			Entity user = new Entity("User", username, roomKey);
			user.setProperty("name", username);
			datastore.put(user);
			request.getSession().setAttribute(roomname, username);
			//response.setAttribute("users", users);
			response.sendRedirect("/room/"+roomname);
			
//			query = new Query("User", roomKey).setFilter(
//					new Query.FilterPredicate("name", FilterOperator.EQUAL, username));
//			String usernameResult = (String) datastore.prepare(query).asList(
//					FetchOptions.Builder.withLimit(1)).get(0).getProperty("name");
//			response.getWriter().println("Roomname: "+roomname+"\nUsername: "+usernameResult);
//			response.getWriter().println("Users in chat:");
//			users.add(0, user);
//			for (Entity e : users) {
//				response.getWriter().println(((String)e.getProperty("name")));
//			}
		}
		
		/*	
		String chatroomName = req.getParameter("chatroomName");
	    Key chatroomKey = KeyFactory.createKey("Chatroom", chatroomName);
	    String content = req.getParameter("content");
	    Date date = new Date();
	    Entity message = new Entity("Message", chatroomKey);
	    message.setProperty("user", user);
	    message.setProperty("date", date);
	    message.setProperty("content", content);

	    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	    datastore.put(message);*/

	}
	
	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		String roomname = request.getPathInfo().substring(1);
		if (roomname.endsWith("/")) {
			roomname = roomname.substring(0, roomname.length()-1);
		}
		if (request.getSession().getAttribute(roomname)!=null) {
			request.getRequestDispatcher("/room.jsp?roomname="+roomname).forward(request, response);
		}
		else {
			response.sendRedirect("/");
		}
	}
	
}