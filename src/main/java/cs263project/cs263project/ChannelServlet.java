package cs263project.cs263project;

import java.io.IOException;
import java.util.Calendar;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.channel.ChannelMessage;
import com.google.appengine.api.channel.ChannelService;
import com.google.appengine.api.channel.ChannelServiceFactory;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

@SuppressWarnings("serial")
public class ChannelServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		messageReceived(req, resp);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		messageReceived(req, resp);
	}
	
	private void messageReceived(HttpServletRequest req, HttpServletResponse resp) {
		
		String type = req.getPathInfo();
		String roomname = req.getParameter("roomname");
		String username = (String)(req.getSession().getAttribute(roomname));
		if (isMessage(type)) {
			Calendar now = Calendar.getInstance();
			int hours = now.get(Calendar.HOUR_OF_DAY);
			int minutes = now.get(Calendar.MINUTE);
			String formattedMessage = 
					"["+hours+":"+minutes+"] ["+username+"] "+req.getParameter("message");
			ChannelService channelService = ChannelServiceFactory
					.getChannelService();
			System.out.println("ROOMNAME:"+roomname);
			channelService.sendMessage(new ChannelMessage(roomname,
					formattedMessage));		
		}
		else if (isLeave(type)) {
			DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
			Key userkey = new KeyFactory.Builder("Room", roomname)
			.addChild("User", username).getKey();
			datastore.delete(userkey);
			req.getSession().removeAttribute(roomname);
		}
		
		
	}
	
	private boolean isMessage(String type) {
		return type.equals("/message") || type.equals("/message/");
	}
	
	private boolean isLeave(String type) {
		return type.equals("/leave") || type.equals("/leave/");
	}

}
