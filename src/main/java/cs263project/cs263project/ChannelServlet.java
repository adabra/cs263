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
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.images.ImagesService;
import com.google.appengine.api.images.ImagesServiceFactory;
import com.google.appengine.api.images.ServingUrlOptions;

@SuppressWarnings("serial")
public class ChannelServlet extends HttpServlet {
	
	private final String CHAT_MESSAGE = "cha";
	private final String LEAVE_MESSAGE = "lea";
	private final String JOIN_MESSAGE = "joi";
	private final String IMAGE_MESSAGE = "ima";
	private final String BLOB_MESSAGE = "blo";
	
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
		
		String type = req.getPathInfo();
		String username = (String)(req.getSession().getAttribute(roomname));
		if (isMessage(type)) {
			Calendar now = Calendar.getInstance();
			int hours = now.get(Calendar.HOUR_OF_DAY);
			int minutes = now.get(Calendar.MINUTE);
			String formattedMessage = 
					"["+hours+":"+minutes+"] ["+username+"] "+req.getParameter("message");
			sendMessage(roomname, CHAT_MESSAGE, formattedMessage);
	
		}
		else if (isImage(type)) {
			BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
			Map<String, List<BlobKey>> blobs = blobstoreService.getUploads(req);
			BlobKey blobKey = blobs.get("file").get(0);

		    if (blobKey == null) {
		    	return;
		    }
		    else {
		    	Calendar now = Calendar.getInstance();
		    	int hours = now.get(Calendar.HOUR_OF_DAY);
		    	int minutes = now.get(Calendar.MINUTE);
		    	ImagesService imagesService = ImagesServiceFactory.getImagesService();
		    	String url = imagesService.getServingUrl(ServingUrlOptions.Builder.withBlobKey(blobKey));
		    	String formattedImageMessage = 
		    	"["+hours+":"+minutes+"] ["+username+"] "
		    	+ "<a href=\""+url+"\" target=\"_blank\"> <img src=\""
		    			+url+"=s128\" alt=\"Error displaying image\"></a>";
		    	sendMessage(roomname, IMAGE_MESSAGE, formattedImageMessage);
		    	sendMessage(roomname, BLOB_MESSAGE, username+";"+blobstoreService.createUploadUrl("/channel/image/?roomname="+roomname));
		    }
		}
		else if (isLeave(type)) {
			System.out.println("\n\nLEAVELEAVE\n\n");
			DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
			Key userkey = new KeyFactory.Builder("Room", roomname)
			.addChild("User", username).getKey();
			datastore.delete(userkey);
			req.getSession().removeAttribute(roomname);
			sendMessage(roomname, LEAVE_MESSAGE, username);
		}
		else if (isJoin(type)) {
			sendMessage(roomname, JOIN_MESSAGE, username);
		}
		else {
			System.out.println("\n\nkomtilslutten\n\n");
		}
		
		
	}
	
	private void sendMessage(String roomname, String type, String content) {
		ChannelService channelService = ChannelServiceFactory
				.getChannelService();
		channelService.sendMessage(new ChannelMessage(roomname,
				type+content));
		System.out.println(type+content);
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
