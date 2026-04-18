package com.example.testapp;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(urlPatterns = "/hello", description = "Hello Jakarta EE Servlet")
public class HelloServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        response.getWriter().println(
            "<!DOCTYPE html><html><body>" +
            "<h1>Hello Jakarta EE!</h1>" +
            "<p>Running on: " + request.getServerName() + "</p>" +
            "</body></html>"
        );
    }
}
