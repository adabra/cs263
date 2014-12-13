package cs263project.cs263project;

import com.google.appengine.api.datastore.GeoPt;

public class RoomData {

	public String name;
	public String city;
	public GeoPt location;
	
	public String toString() {
		return city+","+name+","+location;
	}
}
