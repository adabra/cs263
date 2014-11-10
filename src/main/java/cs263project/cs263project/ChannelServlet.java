package cs263project.cs263project;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.channel.ChannelService;
import com.google.appengine.api.channel.ChannelServiceFactory;

public class ChannelServlet extends HttpServlet {

	  @Override
	  public void doGet(HttpServletRequest req, HttpServletResponse resp)
	      throws IOException {
		  ChannelService channelService = ChannelServiceFactory.getChannelService();

			// The channelKey can be generated in any way that you want, as long as it remains
			// unique to the user.
			String channelKey = "xyz";
			String token = channelService.createChannel(channelKey);
	  }
	
}
