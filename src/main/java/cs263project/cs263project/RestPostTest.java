package cs263project.cs263project;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class RestPostTest extends HttpServlet{

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
	         throws ServletException, IOException {
		request.getRequestDispatcher("restposttest.jsp").forward(request, response);
		
	}
	
	
}
