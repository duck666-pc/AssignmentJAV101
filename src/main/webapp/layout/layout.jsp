<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="${pageContext.request.locale}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${pageTitle}" default="Task Manager"/></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <c:if test="${not empty additionalCSS}">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/${additionalCSS}">
    </c:if>
</head>
<body>
<jsp:include page="header.jsp"/>

<div class="main-content">
    <jsp:include page="${contentPage}"/>
</div>

<jsp:include page="footer.jsp"/>

<script>
    function toggleTheme() {
        const html = document.documentElement;
        const currentTheme = html.getAttribute('data-theme');
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';

        html.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);

        const toggle = document.getElementById('themeToggle');
        if (toggle) {
            toggle.textContent = newTheme === 'dark' ? '☀️' : '🌙';
        }

        document.cookie = "theme=" + newTheme + "; path=/; max-age=31536000";
    }

    function loadTheme() {
        const savedTheme = localStorage.getItem('theme') || getCookie('theme') || 'light';
        document.documentElement.setAttribute('data-theme', savedTheme);
        const toggle = document.getElementById('themeToggle');
        if (toggle) {
            toggle.textContent = savedTheme === 'dark' ? '☀️' : '🌙';
        }
    }

    function getCookie(name) {
        const value = "; " + document.cookie;
        const parts = value.split("; " + name + "=");
        if (parts.length === 2) return parts.pop().split(";").shift();
    }

    function changeLanguage(lang) {
        window.location.href = '?lang=' + lang;
    }

    loadTheme();
</script>

<c:if test="${not empty additionalJS}">
    <script src="${pageContext.request.contextPath}/js/${additionalJS}"></script>
</c:if>
</body>
</html>
