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
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterOperator;


public class RoomfinderServlet extends HttpServlet {

	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		String latString = request.getParameter("lat");
		String lonString = request.getParameter("lon");
		
		
		if (!Utils.getInstance().isNumeric(latString) 
				|| !Utils.getInstance().isNumeric(lonString)) {
			response.sendRedirect("/");
			return;
		}
		float lat = Float.valueOf(latString);
		float lon = Float.valueOf(lonString);
		String city = request.getHeader("X-AppEngine-City");
		System.out.println("lat: "+lat+"\nlon: "+lon+"\ncity: "+city);
		if (city==null) {
			city = request.getParameter("city");
		}
		if (city == null) {
			city = "stormwind";
		}
		Key cityKey = KeyFactory.createKey("City", city);
		
		
		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

		
		Filter latMaxFilter = new Query.FilterPredicate(
						"maxlat", 
						FilterOperator.GREATER_THAN_OR_EQUAL, 
						lat);
		Filter latMinFilter = new Query.FilterPredicate(
						"minlat", 
						FilterOperator.LESS_THAN_OR_EQUAL, 
						lat);
		Filter lonMaxFilter = new Query.FilterPredicate(
						"maxlon", 
						FilterOperator.GREATER_THAN_OR_EQUAL, 
						lon);
		Filter lonMinFilter = new Query.FilterPredicate(
						"minlon", 
						FilterOperator.LESS_THAN_OR_EQUAL, 
						lon);
		
/*
		Filter latLonFilter = CompositeFilterOperator.and(
				latMaxFilter, 
				latMinFilter, 
				lonMaxFilter, 
				lonMinFilter);
*/
		
		
		//Query query = new Query("Room", cityKey).setFilter(latLonFilter);
		Query query = new Query("Room", cityKey)
			.setFilter(lonMinFilter)
			.setFilter(lonMaxFilter)
			.setFilter(latMinFilter)
			.setFilter(latMaxFilter);
		List<Entity> rooms = datastore.prepare(query)
				.asList(FetchOptions.Builder.withLimit(25));
		for (Entity room : rooms) {
			response.getWriter().println(room.getProperty("name"));			
		}
		response.getWriter().println("slutt");
	}
}
