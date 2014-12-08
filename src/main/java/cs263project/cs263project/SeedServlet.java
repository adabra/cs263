package cs263project.cs263project;

import java.io.IOException;
import java.util.List;
import java.util.Random;

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

public class SeedServlet extends HttpServlet {


	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException { 
		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
		Key cityKey;
		Entity e;
		String[] cityNames = {"goleta", "goleta", "goleta", "goleta", "santa barbara", "los angeles"};
		String name;
		int[] etternavn = {0,1};
		float[][] cityCoords = {{34.4340633f, -119.8223008f}, {34.433401f,-119.82252f}, {34.433655f,-119.820502f}, {34.415033f, -119.846973f}, {34.4208300f ,-119.6981900f}, {34.0522300f, -118.2436800f}}; 
		for(int i = 0; i < 4; i++) {
			cityKey = KeyFactory.createKey("City", cityNames[i%3]);
			name = cityNames[i%3]+ new Random().nextInt(100) + new Random().nextInt(100);
			e = new Entity("Room", name, cityKey);
			e.setProperty("location", new GeoPt(cityCoords[i%4][0], cityCoords[i%3][1]));
			e.setProperty("name", name);
			datastore.put(e);
		}
		
		cityKey = KeyFactory.createKey("City", "goleta");
		Query query = new Query("Room", cityKey);
		List<Entity> rooms = datastore.prepare(query)
				.asList(FetchOptions.Builder.withLimit(25));
		for (Entity room : rooms) {
			response.getWriter().println(room.getProperty("name"));			
		}
		response.getWriter().println("slutt");
	}
	
	

}
