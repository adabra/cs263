package cs263project.cs263project;


import java.util.Calendar;
import java.util.Scanner;
import java.util.logging.Level;

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.memcache.ErrorHandlers;
import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.google.gson.Gson;

public class Test {

	
	public static void main(String[] args) {
		Gson gson = new Gson();
		String roomname = "Room1";
		String username = "hotgrl18";
		String content = "tazt priv?";
		String time = ""+Calendar.getInstance().get(Calendar.HOUR_OF_DAY) + ":" +  Calendar.getInstance().get(Calendar.MINUTE);
		Message msg = new Message("CHAT_MESSAGE", username, content, time);
		System.out.println(gson.toJson(msg));
		String in = " ";
		Scanner s = new Scanner(System.in);
		while ((in=s.nextLine()) != "end") {
			System.out.println(Validator.isValidCityName(in));			
		}
		
		
		//Try getting room from memcache
		String key = "roomname";
		MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
	    syncCache.setErrorHandler(ErrorHandlers.getConsistentLogAndContinue(Level.INFO));
	    Entity roomEntity = (Entity) syncCache.get(key); // read from cache
	    if (roomEntity == null) {
	      // Entity not in cache, get value from other source
	      

	      syncCache.put(key, roomEntity); // populate cache
	    }

		
	}
	
}
