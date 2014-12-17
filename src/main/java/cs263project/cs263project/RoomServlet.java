package cs263project.cs263project;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;
import java.util.logging.Level;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.GeoPt;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.memcache.ErrorHandlers;
import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;

/**
 * This class handles requests to join or create chat rooms. 
 * Validates user and room names.
 * Mapped to the /room URL.
 *
 */

public class RoomServlet extends HttpServlet{

	/**
	 * Post requests to /room represents a request to either create a new room
	 * or join an existing one.
	 */
	@Override
	public void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		
		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
		
		boolean invalidNames = false;
		String roomname = request.getParameter("roomname").trim();
		String username = request.getParameter("username").trim();
		float lat = Float.valueOf(request.getParameter("lat"));
		float lon = Float.valueOf(request.getParameter("lon"));
		String city = request.getHeader("X-AppEngine-City");
		if (city==null) {
			city = request.getParameter("city");
		}
		if (city == null) {
			city = "no-city";
		}
		
		//Check roomname validity
		if (!Validator.isValidName(roomname)){
			request.setAttribute("invalid_roomname", Boolean.TRUE);
			invalidNames = true;
		}
		//Check username validity
		if (!Validator.isValidName(username)){
			request.setAttribute("invalid_username", Boolean.TRUE);
			invalidNames = true;
		}
		if (invalidNames) {
			request.getRequestDispatcher("/roomselector.jsp?lat="+lat+"&lon="+lon).
			forward(request, response);
			return;
		}
		
		//Check if room exists in memcache
		String key = city+":"+roomname;
		MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
	    syncCache.setErrorHandler(ErrorHandlers.getConsistentLogAndContinue(Level.INFO));
	    Entity roomEntity = (Entity) syncCache.get(key); // read from cache
	    Query query;
	    Key roomKey = new KeyFactory.Builder("City", city).
	    		addChild("Room", roomname).getKey();
	    if (roomEntity == null) {
			//Check if room exists in datastore
			query = new Query("Room", roomKey);
			roomEntity = datastore.prepare(query).asSingleEntity();
			if (roomEntity == null) {
				//Room not found in memcache or datastore, it's a new room
				Key cityKey = KeyFactory.createKey("City", city);
				roomEntity = new Entity("Room", roomname, cityKey);
				roomEntity.setProperty("name", roomname);
				roomEntity.setProperty("location", new GeoPt(lat, lon));
				roomEntity.setProperty("city", city);
				roomEntity.setProperty("nr_of_users", new Integer(0));
				
			}
	    }
		
		//Check if the room is within the user's range (useful when the
	    //user joins an existing room.
		float maxLat = lat+0.002f;
		float minLat = lat-0.002f;
		float maxLon = lon+0.002f;
		float minLon = lon-0.002f;
		
		GeoPt loc = (GeoPt)roomEntity.getProperty("location");
		float roomLat = loc.getLatitude();
		float roomLon = loc.getLongitude();
		if (!(roomLat>minLat && roomLat<maxLat
				&&roomLon>minLon && roomLon<maxLon)) {
			request.setAttribute("Out_of_range", Boolean.TRUE);
			request.getRequestDispatcher("/roomselector.jsp?lat="+lat+"&lon="+lon).
			forward(request, response);
			return;
		}
		
		//Check if the name enterd by the user is already in use
		//in the room.
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
			request.getRequestDispatcher("/roomselector.jsp?lat="+lat+"&lon="+lon).
			forward(request, response);
		}
		else {
			//Create user
			Entity user = new Entity("User", username, roomKey);
			user.setProperty("name", username);
			//Save user to datastore
			datastore.put(user);
			System.out.println("\n\n\nNUMBEROFUSERSBEFORE: "+roomEntity.getProperty("nr_of_users").toString()+"\n\n\n");
			roomEntity.setProperty("nr_of_users", Integer.parseInt(roomEntity.getProperty("nr_of_users").toString())+1);
			System.out.println("NUMBEROFUSERSAFTER: "+roomEntity.getProperty("nr_of_users").toString()+"\n\n\n");
			//Put or update room in memcache
			syncCache.put(key, roomEntity);
			//Save room to datastore
			datastore.put(roomEntity);
			request.getSession().setAttribute(city+":"+roomname, username);
			response.sendRedirect("/room/"+city+"/"+roomname);
		}	
	}
	
	/**
	 * If the user navigates away from the room without pressing the "leave"
	 * button, he/she can get back in the room by entering the proper URL
	 * in the browser navigation bar. If the user is not in the room, he/she
	 * will not be able to join, and redirected to / instead.
	 */
	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		//Break roomname into city and room
		String[] cityAndRoom = request.getPathInfo().substring(1).split("/");
		String cityname = cityAndRoom[0];
		String roomname = cityAndRoom[1];
		
		if (roomname.endsWith("/")) {
			roomname = roomname.substring(0, roomname.length()-1);
		}
		if (request.getSession().getAttribute(cityname+":"+roomname)!=null) {
			request.getRequestDispatcher("/room.jsp?cityname="+ URLEncoder.encode(cityname, "UTF-8")+"&roomname="+roomname).forward(request, response);
		}
		else {
			response.sendRedirect("/");
		}
	}
	
}
