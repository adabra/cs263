package cs263project.cs263project;

import java.io.IOException;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

public class JoinServlet extends HttpServlet{

	@Override
	public void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws IOException {
		
		String roomname = request.getParameter("roomname");
		//Key roomKey = KeyFactory.createKey("Room", roomname);
		String username = request.getParameter("username");
		//Key userKey = KeyFactory.createKey("User", username);
		
		//DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	
		
			
		/*	
		String guestbookName = request.getParameter("guestbookName");
	    Key guestbookKey = KeyFactory.createKey("Guestbook", guestbookName);
	    String content = req.getParameter("content");
	    Date date = new Date();
	    Entity greeting = new Entity("Greeting", guestbookKey);
	    greeting.setProperty("user", user);
	    greeting.setProperty("date", date);
	    greeting.setProperty("content", content);

	    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	    datastore.put(greeting);*/

	    response.getWriter().println("Roomname: "+roomname+"\nUsername: "+username);
	}
	
}
