package cs263project.cs263project;


import java.util.Calendar;
import java.util.Scanner;
import java.util.logging.Level;

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
		
		
//		String key = "1";
//		byte[] value;
//		MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
//	    syncCache.setErrorHandler(ErrorHandlers.getConsistentLogAndContinue(Level.INFO));
//	    value = (byte[]) syncCache.get(key); // read from cache
//	    if (value == null) {
//	      // get value from other source
//	      // ........
//
//	      syncCache.put(key, value); // populate cache
//	    }

		
	}
	
}
