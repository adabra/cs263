package cs263project.cs263project;

import static com.google.appengine.api.taskqueue.TaskOptions.Builder.withUrl;

import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

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
import com.google.appengine.api.taskqueue.Queue;
import com.google.appengine.api.taskqueue.QueueFactory;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;


@Path("/room")
public class RoomRestApi {

	DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	
	/**
	 * Get room
	 * 
	 * @param roomname The name of the room
	 * @param city The name of the city
	 * @return
	 */
    @GET
    @Path("/{city}/{roomname}")
    @Produces(MediaType.APPLICATION_JSON)
    public String getRoomInCityWithName(
    		@PathParam("roomname") String roomname,
    		@PathParam("city") String city) {
    	
    	//Try getting room from memcache
		String key = city+":"+roomname;
		MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
	    syncCache.setErrorHandler(ErrorHandlers.getConsistentLogAndContinue(Level.INFO));
	    Entity roomEntity = (Entity) syncCache.get(key); // read from cache
	    if (roomEntity != null) {
	    	System.out.println(city+":"+roomname+" found in memcache!");
	    }
	    if (roomEntity == null) {
	    	System.out.println(city+":"+roomname+" not in memcache, checking datastore");
	      // Entity not in cache, try datastore
	    	Key roomKey = new KeyFactory.Builder("City", city).
	    			addChild("Room", roomname).getKey();
	    	Query query = new Query("Room", roomKey);
	    	roomEntity = datastore.prepare(query).asSingleEntity();
	    	if (roomEntity==null) {
	    		return "";
	    	}
	      syncCache.put(key, roomEntity); // populate cache
	    }
    	
        return new Gson().toJson(roomEntity.getProperties());
    }
    
    /**
     * Get all rooms in city
     * 
     * @param city The name of the city
     * @return All rooms in city
     */
    @GET
    @Path("/{city}")
    @Produces(MediaType.APPLICATION_JSON)
    public String getRoomsInCity(
    		@PathParam("city") String city) {
    	city = city.toLowerCase();
    	Key cityKey = KeyFactory.createKey("City", city);
    	Query query = new Query("Room", cityKey);

		List<Entity> entities = datastore.prepare(query)
				.asList(FetchOptions.Builder.withDefaults());
    	
		List<Map<String, Object>> rooms = new ArrayList<Map<String, Object>>();
		for (Entity entity : entities) {
			rooms.add(entity.getProperties());
		}
    	
        return new Gson().toJson(rooms);
    }
    
    
    /**
     * Create a new room in city
     * @param city The name of the city
     * @return
     */
    @POST
    @Path("/{city}")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createNewRoomInCity(
    		String body,
    		@PathParam("city") String city) {
    	RoomData roomData;
    	try {
    		roomData = new Gson().fromJson(body, RoomData.class);
    		System.out.println(roomData);
    	}
    	catch (JsonSyntaxException e) {
    		return Response.status(Status.BAD_REQUEST).build();
    	}
    	//Validate the input data
    	//Check roomname validity
		if (!Validator.isValidName(roomData.name.trim())
				|| !Validator.isValidCityName(city.trim())) {
			return Response.status(Status.BAD_REQUEST).build();
		}
		
		//Check lat/lon ranges
		if (!Validator.isValidLatitude(roomData.location.getLatitude()) 
				|| !Validator.isValidLongitude(roomData.location.getLongitude()) ) {
			return Response.status(Status.BAD_REQUEST).build();
		}
    	
    	//Check if there is already a room with the given name in the given city
    	Key roomKey = new KeyFactory.Builder("City", city).
    			addChild("Room", roomData.name).getKey();
    	Query query = new Query("Room", roomKey);
    	Entity entity = datastore.prepare(query).asSingleEntity();
    	if (entity!=null) {
    		//Room already exists
    		return Response.notModified().build();
    	}
    	else {
    		// Send the task of saving the room to datastore to the task queue.
    		Queue queue = QueueFactory.getDefaultQueue();
    	    queue.add(withUrl("/worker")
    	    		.param("city", city)
    	    		.param("roomname", roomData.name)
    	    		.param("latitude", String.valueOf(roomData.location.getLatitude()))
    	    		.param("longitude", String.valueOf(roomData.location.getLongitude())));
    	    
			
    		try {
				return Response.created(URI.create("/rest/room/"+URLEncoder.encode(city, "UTF-8")+"/"+roomData.name)).build();
			} catch (UnsupportedEncodingException e) {
				return Response.created(URI.create("/")).build();
			}
    	}
    }
    
    
}
