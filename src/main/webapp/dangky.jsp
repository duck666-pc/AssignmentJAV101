<%-- src/main/webapp/dangky.jsp --%>
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
    <title><fmt:message key="register.title"/> - <fmt:message key="app.title"/></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .password-strength {
            margin-top: 8px;
            font-size: 12px;
            color: var(--text-secondary);
        }

        .strength-bar {
            height: 4px;
            background: var(--border-color);
            border-radius: 2px;
            margin-top: 6px;
            overflow: hidden;
        }

        .strength-bar-fill {
            height: 100%;
            width: 0%;
            transition: all 0.3s;
            border-radius: 2px;
        }
    </style>
</head>
<body>
<div class="auth-container">
    <div class="auth-header">
        <h1><fmt:message key="register.create_account"/></h1>
        <p><fmt:message key="register.start_managing"/></p>
    </div>

    <c:if test="${not empty error}">
        <div class="error-message">${error}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/auth?action=register" method="post" id="registerForm">
        <div class="form-group">
            <label for="ten"><fmt:message key="register.name"/></label>
            <input type="text" id="ten" name="ten" required
                   placeholder="Nguyễn Văn A" value="${param.ten}">
        </div>

        <div class="form-group">
            <label for="email"><fmt:message key="register.email"/></label>
            <input type="email" id="email" name="email" required
                   placeholder="your@email.com" value="${param.email}">
        </div>

        <div class="form-group">
            <label for="matKhau"><fmt:message key="register.password"/></label>
            <input type="password" id="matKhau" name="matKhau" required
                   placeholder="••••••••" minlength="6">
            <div class="strength-bar">
                <div class="strength-bar-fill" id="strengthBar"></div>
            </div>
            <div class="password-strength" id="strengthText"></div>
        </div>

        <div class="form-group">
            <label for="confirmPassword"><fmt:message key="register.confirm_password"/></label>
            <input type="password" id="confirmPassword" required
                   placeholder="••••••••">
        </div>

        <div class="form-group">
            <label style="display: flex; align-items: center; gap: 8px; font-weight: normal;">
                <input type="checkbox" name="rememberMe" value="true">
                Ghi nhớ đăng nhập
            </label>
        </div>

        <button type="submit" class="btn-primary" id="submitBtn">
            <fmt:message key="register.submit"/>
        </button>
    </form>

    <div class="auth-footer">
        <p>
            <fmt:message key="register.have_account"/>
            <a href="${pageContext.request.contextPath}/dangnhap.jsp">
                <fmt:message key="register.login"/>
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
    const passwordInput = document.getElementById('matKhau');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const strengthBar = document.getElementById('strengthBar');
    const strengthText = document.getElementById('strengthText');
    const form = document.getElementById('registerForm');

    passwordInput.addEventListener('input', () => {
        const password = passwordInput.value;
        let strength = 0;

        if (password.length >= 6) strength += 33;
        if (/[a-zA-Z]/.test(password)) strength += 33;
        if (/[0-9]/.test(password)) strength += 34;

        strengthBar.style.width = strength + '%';

        if (strength <= 33) {
            strengthBar.style.background = '#c33';
            strengthText.textContent = 'Yếu';
        } else if (strength <= 66) {
            strengthBar.style.background = '#d97706';
            strengthText.textContent = 'Trung bình';
        } else {
            strengthBar.style.background = '#3c3';
            strengthText.textContent = 'Mạnh';
        }
    });

    confirmPasswordInput.addEventListener('input', () => {
        if (confirmPasswordInput.value && passwordInput.value !== confirmPasswordInput.value) {
            confirmPasswordInput.style.borderColor = '#c33';
        } else {
            confirmPasswordInput.style.borderColor = 'var(--border-color)';
        }
    });

    form.addEventListener('submit', (e) => {
        if (passwordInput.value !== confirmPasswordInput.value) {
            e.preventDefault();
            alert('Mật khẩu xác nhận không khớp!');
        }
    });

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
