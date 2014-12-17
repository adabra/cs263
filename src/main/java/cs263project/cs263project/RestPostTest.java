package cs263project.cs263project;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * This RestPostTest is used to forward users to restposttest.jsp, which
 * presents the user with a form that can be used to test sending json post
 * requests to the rest api of the application.
 * Mapped to the /restposttest URL.
 *
 */

public class RestPostTest extends HttpServlet{

	/**
	 * Forward request to restposttest.jsp.
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
	         throws ServletException, IOException {
		request.getRequestDispatcher("restposttest.jsp").forward(request, response);
	}
	
	
}
