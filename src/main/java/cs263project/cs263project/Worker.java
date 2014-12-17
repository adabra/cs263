package cs263project.cs263project;

import java.io.IOException;
import java.util.logging.Level;

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
import com.google.appengine.api.memcache.ErrorHandlers;
import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;

/**
 * This worker class handles tasks put in the taskqueue by the RoomRestApi class,
 * creating a new chat room as requested by a user via a json api call.
 *
 */

public class Worker extends HttpServlet {
	
	/**
	 * Create a new chat room
	 */
 protected void doPost(HttpServletRequest request, HttpServletResponse response)
         throws ServletException, IOException {
	 String city = request.getParameter("city");
	 String roomname = request.getParameter("roomname");
	 float latitude = Float.valueOf(request.getParameter("latitude"));
	 float longitude = Float.valueOf(request.getParameter("longitude"));
	 GeoPt location = new GeoPt(latitude, longitude);
 	 	 
    //Build entity
	Key cityKey = KeyFactory.createKey("City", city);
	Entity room = new Entity("Room", roomname, cityKey);
	room.setProperty("name", roomname);
	room.setProperty("location", location);
	room.setProperty("city", city);
	room.setProperty("nr_of_users", new Integer(0));
	//Put in memcache
	String key = city+":"+roomname;
	MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
	syncCache.setErrorHandler(ErrorHandlers.getConsistentLogAndContinue(Level.INFO));
	syncCache.put(key, room);
	//Save to datastore
	DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	datastore.put(room);
 }
}

