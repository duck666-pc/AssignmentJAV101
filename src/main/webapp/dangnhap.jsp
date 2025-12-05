<%-- src/main/webapp/dangnhap.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<fmt:setLocale value="${param.lang != null ? param.lang : pageContext.request.locale}"/>
<fmt:setBundle basename="messages"/>

<!DOCTYPE html>
<html lang="${pageContext.request.locale}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="login.title"/> - <fmt:message key="app.title"/></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
    </style>
</head>
<body>
<div class="auth-container">
    <div class="auth-header">
        <h1><fmt:message key="login.title"/></h1>
        <p><fmt:message key="login.welcome"/></p>
    </div>

    <c:if test="${not empty error}">
        <div class="error-message">${error}</div>
    </c:if>

    <c:if test="${not empty success}">
        <div class="success-message">${success}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/auth?action=login" method="post">
        <div class="form-group">
            <label for="email"><fmt:message key="login.email"/></label>
            <input type="email" id="email" name="email" required
                   placeholder="your@email.com"
                   value="${cookie.rememberedEmail.value}">
        </div>

        <div class="form-group">
            <label for="matKhau"><fmt:message key="login.password"/></label>
            <input type="password" id="matKhau" name="matKhau" required
                   placeholder="••••••••">
        </div>

        <div class="form-group">
            <label style="display: flex; align-items: center; gap: 8px; font-weight: normal;">
                <input type="checkbox" name="rememberMe" value="true"
                ${not empty cookie.rememberedEmail ? 'checked' : ''}>
                Ghi nhớ đăng nhập
            </label>
        </div>

        <button type="submit" class="btn-primary">
            <fmt:message key="login.submit"/>
        </button>
    </form>

    <div class="auth-footer">
        <p>
            <fmt:message key="login.no_account"/>
            <a href="${pageContext.request.contextPath}/dangky.jsp">
                <fmt:message key="login.register"/>
            </a>
        </p>
    </div>

    <div style="margin-top: 20px; text-align: center;">
        <select onchange="window.location.href='?lang=' + this.value"
                style="padding: 6px 12px; border: 1px solid var(--border-color); border-radius: 6px; background: var(--bg-primary); color: var(--text-primary); cursor: pointer;">
            <option value="vi" ${param.lang == 'vi' || param.lang == null ? 'selected' : ''}>🇻🇳 Tiếng Việt</option>
            <option value="en" ${param.lang == 'en' ? 'selected' : ''}>🇬🇧 English</option>
        </select>
        <button class="theme-toggle" onclick="toggleTheme()" id="themeToggle"
                style="margin-left: 8px;">🌙</button>
    </div>
</div>

<script>
    function toggleTheme() {
        const html = document.documentElement;
        const currentTheme = html.getAttribute('data-theme');
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';

        html.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);
        document.cookie = "theme=" + newTheme + "; path=/; max-age=31536000";

        document.getElementById('themeToggle').textContent = newTheme === 'dark' ? '☀️' : '🌙';
    }

    function loadTheme() {
        function getCookie(name) {
            const value = "; " + document.cookie;
            const parts = value.split("; " + name + "=");
            if (parts.length === 2) return parts.pop().split(";").shift();
        }

        const savedTheme = localStorage.getItem('theme') || getCookie('theme') || 'light';
        document.documentElement.setAttribute('data-theme', savedTheme);
        document.getElementById('themeToggle').textContent = savedTheme === 'dark' ? '☀️' : '🌙';
    }

    loadTheme();
</script>
</body>
</html>
