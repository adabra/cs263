package cs263project.cs263project;

import java.io.IOException;

import javax.servlet.http.*;

import com.google.appengine.api.channel.ChannelMessage;
import com.google.appengine.api.channel.ChannelService;
import com.google.appengine.api.channel.ChannelServiceFactory;

@SuppressWarnings("serial")
public class ServletTest extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		ChannelService channelService = ChannelServiceFactory
				.getChannelService();
		channelService.sendMessage(new ChannelMessage("logger",
				req.getParameter("message")));
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		ChannelService channelService = ChannelServiceFactory
				.getChannelService();
		channelService.sendMessage(new ChannelMessage("logger",
				req.getParameter("message")));
	}

}
