package cs263project.cs263project;

import java.io.IOException;
import java.util.Calendar;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.channel.ChannelMessage;
import com.google.appengine.api.channel.ChannelService;
import com.google.appengine.api.channel.ChannelServiceFactory;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.images.ImagesService;
import com.google.appengine.api.images.ImagesServiceFactory;
import com.google.appengine.api.images.ServingUrlOptions;
import com.google.gson.Gson;

@SuppressWarnings("serial")
public class ChannelServlet extends HttpServlet {
	
	private final String CHAT_MESSAGE = "chat";
	private final String LEAVE_MESSAGE = "leave";
	private final String JOIN_MESSAGE = "join";
	private final String IMAGE_MESSAGE = "image";
	private final String BLOB_MESSAGE = "blob";
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		messageReceived(req, resp);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		messageReceived(req, resp);
	}
	
	private void messageReceived(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		
		String roomname = req.getParameter("roomname");
		//Check if user is in room
		if (req.getSession().getAttribute(roomname) == null) {
			resp.sendRedirect("/");
			return;
		}
		Message message;
		String type = req.getPathInfo();
		String username = (String)(req.getSession().getAttribute(roomname));
		Calendar now = Calendar.getInstance();
		int hours = now.get(Calendar.HOUR_OF_DAY);
		int minutes = now.get(Calendar.MINUTE);
		String time = hours+":"+minutes;
		if (isMessage(type)) {
			System.out.println("sending JSON message");
			message = new Message(CHAT_MESSAGE, username, req.getParameter("message"), time);
			sendMessage(roomname, message);
	
		}
		else if (isImage(type)) {
			BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
			Map<String, List<BlobKey>> blobs = blobstoreService.getUploads(req);
			BlobKey blobKey = blobs.get("file").get(0);

		    if (blobKey == null) {
		    	return;
		    }
		    else {
		    	ImagesService imagesService = ImagesServiceFactory.getImagesService();
		    	String url = imagesService.getServingUrl(
		    			ServingUrlOptions.Builder.withBlobKey(blobKey));
		    	String imageMsgContent = "<a href=\""+url+"\" target=\"_blank\"> <img src=\""
		    			+url+"=s128\" alt=\"Error displaying image\"></a>";
		    	message = new Message(IMAGE_MESSAGE, username, imageMsgContent, time);
		    	sendMessage(roomname, message);
		    	String blobMsgContent = blobstoreService.
		    			createUploadUrl("/channel/image/?roomname="+roomname);
		    	message = new Message(BLOB_MESSAGE, username, blobMsgContent, time);
		    	sendMessage(roomname, message);
		    }
		}
		else if (isLeave(type)) {
			System.out.println("\n\nLEAVELEAVE\n\n");
			DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
			//Breaking roomname into city and room
			String[] cityAndRoom = roomname.split(":");
			String city = cityAndRoom[0];
			String room = cityAndRoom[1];
			Key userkey = new KeyFactory.Builder("City", city)
			.addChild("Room", room)
			.addChild("User", username).getKey();
			datastore.delete(userkey);
			//decrement user count in room
			Key roomKey = new KeyFactory.Builder("City", city)
			.addChild("Room", room).getKey();
			Query query = new Query("Room", roomKey);
			Entity roomEntity = datastore.prepare(query).asSingleEntity();
			roomEntity.setProperty("nr_of_users", Integer.parseInt(roomEntity.getProperty("nr_of_users").toString())-1);
			datastore.put(roomEntity);
			
			message = new Message(LEAVE_MESSAGE, username, "", time);
			req.getSession().removeAttribute(roomname);
			sendMessage(roomname, message);
		}
		else if (isJoin(type)) {
			message = new Message(JOIN_MESSAGE, username, "", time);
			sendMessage(roomname, message);
		}
		else {
			System.out.println("\n\nkomtilslutten\n\n");
		}
		
		
	}
	
	private void sendMessage(String roomname, Message message) {
		ChannelService channelService = ChannelServiceFactory.
				getChannelService();
		channelService.sendMessage(new ChannelMessage(roomname, new Gson().toJson(message)));
	}
	
	private boolean isMessage(String type) {
		return type.equals("/message") || type.equals("/message/");
	}
	
	private boolean isLeave(String type) {
		return type.equals("/leave") || type.equals("/leave/");
	}
	
	private boolean isJoin(String type) {
		return type.equals("/join") || type.equals("/join/");
	}
	
	private boolean isImage(String type) {
		return type.equals("/image") || type.equals("/image/");
	}

}
