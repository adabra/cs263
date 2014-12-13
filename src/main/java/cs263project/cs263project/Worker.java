package cs263project.cs263project;

import java.io.IOException;
import java.util.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.GeoPt;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;


public class Worker extends HttpServlet {
 protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws ServletException, IOException {
	 String city = request.getParameter("city");
	 String roomname = request.getParameter("roomname");
	 float latitude = Float.valueOf(request.getParameter("latitude"));
	 float longitude = Float.valueOf(request.getParameter("longitude"));
	 GeoPt location = new GeoPt(latitude, longitude);
 
	 System.out.println("\n\nWORK WORK\n\n");
	 
    //Save room to datastore
	DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	Key cityKey = KeyFactory.createKey("City", city);
	Entity room = new Entity("Room", roomname, cityKey);
	room.setProperty("name", roomname);
	room.setProperty("location", location);
	room.setProperty("city", city);
	room.setProperty("nr_of_users", new Integer(0));
	datastore.put(room);
 }
}

