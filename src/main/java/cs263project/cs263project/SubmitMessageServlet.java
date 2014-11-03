package cs263project.cs263project;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import java.io.IOException;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class SubmitMessageServlet extends HttpServlet {
  @Override
  public void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws IOException {
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();

    String chatroomName = req.getParameter("chatroomName");
    Key chatroomKey = KeyFactory.createKey("Chatroom", chatroomName);
    String content = req.getParameter("content");
    Date date = new Date();
    Entity message = new Entity("Message", chatroomKey);
    message.setProperty("user", user);
    message.setProperty("date", date);
    message.setProperty("content", content);

    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
    datastore.put(message);

    resp.sendRedirect("/chatroom.jsp?chatroomName=" + chatroomName);
  }
}