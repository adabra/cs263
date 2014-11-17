package cs263project.cs263project;

import java.io.IOException;
import java.util.Calendar;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.channel.ChannelMessage;
import com.google.appengine.api.channel.ChannelService;
import com.google.appengine.api.channel.ChannelServiceFactory;

@SuppressWarnings("serial")
public class ServletTest extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		messageReceived(req, resp);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		messageReceived(req, resp);
	}
	
	private void messageReceived(HttpServletRequest req, HttpServletResponse resp) {
		String username = (String)(req.getSession().getAttribute("username"));
		String roomname = req.getParameter("roomname");
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

}
