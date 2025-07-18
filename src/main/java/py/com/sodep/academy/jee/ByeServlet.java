package py.com.sodep.academy.jee;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class ByeServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
        String name = request.getParameter("name");
        if (name == null || name.isEmpty()) {
            name = "mundo";
        }

        request.setAttribute("name", name);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/bye.jsp");
        dispatcher.forward(request, response);
    }
}
