<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>J2EE JSP App</title>
    <style>
        body { font-family: sans-serif; max-width: 780px; margin: 3rem auto; padding: 0 1rem; }
        .card { border: 1px solid #ddd; border-radius: 10px; padding: 1rem 1.25rem; }
        code { background: #f7f7f7; padding: 0.15rem 0.4rem; border-radius: 6px; }
    </style>
</head>
<body>
    <div class="card">
        <h1>JSP Web App Ready</h1>
        <p>Server time: <%= new java.util.Date() %></p>
        <p>Try servlet endpoint: <a href="hello">/hello</a></p>
    </div>
</body>
</html>
