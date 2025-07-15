<%@ page import="java.sql.*, javax.sql.*, javax.naming.*" %>
<%@ page import="java.util.*" %>
<%
    // Obtener el contexto inicial
    InitialContext ctx = new InitialContext();
    // Buscar el DataSource
    DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/PostgreSQLDS");
    // Obtener la conexión
    Connection conn = ds.getConnection();
    // Crear la consulta SQL
    String sql = "SELECT id, nombre, email FROM usuarios";
    // Crear el statement
    Statement stmt = conn.createStatement();
    // Ejecutar la consulta
    ResultSet rs = stmt.executeQuery(sql);
    // Procesar los resultados
    out.println("<html><body>");
    out.println("<h1>Hola Mundo</h1>");
    out.println("<table border='1'>");
    out.println("<tr><th>ID</th><th>Nombre</th><th>Email</th></tr>");
    while (rs.next()) {
        out.println("<tr>");
        out.println("<td>" + rs.getInt("id") + "</td>");
        out.println("<td>" + rs.getString("nombre") + "</td>");
        out.println("<td>" + rs.getString("email") + "</td>");
        out.println("</tr>");
    }
    out.println("</table>");
    out.println("</body></html>");
    // Cerrar los recursos
    rs.close();
    stmt.close();
    conn.close();
%>

