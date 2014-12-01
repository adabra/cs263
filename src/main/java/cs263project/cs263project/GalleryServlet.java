package cs263project.cs263project;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class GalleryServlet extends HttpServlet {

	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws IOException, ServletException {
		
		String roomname = request.getPathInfo().substring(1);
		if (roomname.endsWith("/")) {
			roomname = roomname.substring(0, roomname.length()-1);
		}
		if (request.getSession().getAttribute(roomname)!=null) {
			request.getRequestDispatcher("/gallery.jsp?roomname="+roomname).forward(request, response);
		}
		else {
			response.sendRedirect("/");
		}
	}
	
}
