package cs263project.cs263project;

import com.google.appengine.api.datastore.GeoPt;

/**
 * This simple class holds data belonging to a specific chat
 * room. Used to make sending and receiving json data easier.
 *
 */

public class RoomData {

	public String name;
	public String city;
	public GeoPt location;
	
	public String toString() {
		return city+","+name+","+location;
	}
}
