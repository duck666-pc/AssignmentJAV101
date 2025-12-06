<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Task Manager</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: var(--spacing-lg);
        }

        .auth-container {
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            width: 100%;
            max-width: 460px;
            padding: var(--spacing-2xl);
            animation: slideUp 0.5s ease;
        }

        .auth-header {
            text-align: center;
            margin-bottom: var(--spacing-xl);
        }

        .auth-logo {
            font-size: 4rem;
            margin-bottom: var(--spacing-lg);
            font-weight: var(--font-weight-bold);
        }

        .auth-header h1 {
            font-size: var(--font-size-2xl);
            font-weight: var(--font-weight-semibold);
            margin-bottom: var(--spacing-sm);
            letter-spacing: -0.02em;
        }

        .auth-header p {
            font-size: var(--font-size-sm);
            color: var(--text-secondary);
        }

        .password-strength {
            margin-top: var(--spacing-sm);
        }

        .strength-bar {
            height: 3px;
            background: var(--border-color);
            border-radius: var(--radius-full);
            overflow: hidden;
            margin-bottom: var(--spacing-xs);
        }

        .strength-fill {
            height: 100%;
            width: 0%;
            transition: all var(--transition-normal);
            border-radius: var(--radius-full);
        }

        .strength-text {
            font-size: var(--font-size-xs);
            color: var(--text-secondary);
            font-weight: var(--font-weight-medium);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .btn-submit {
            width: 100%;
            padding: 12px;
            margin-top: var(--spacing-md);
        }

        .auth-footer {
            text-align: center;
            margin-top: var(--spacing-xl);
            padding-top: var(--spacing-lg);
            border-top: 1px solid var(--border-color);
            font-size: var(--font-size-sm);
            color: var(--text-secondary);
        }

        .auth-footer a {
            color: var(--text-primary);
            font-weight: var(--font-weight-medium);
            text-decoration: underline;
        }

        .theme-selector {
            display: flex;
            justify-content: center;
            gap: var(--spacing-sm);
            margin-top: var(--spacing-lg);
        }
    </style>
</head>
<body>
<div class="auth-container">
    <div class="auth-header">
        <div class="auth-logo">□</div>
        <h1>REGISTER</h1>
        <p>Create account to start managing tasks</p>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-error">
                ${error}
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/auth?action=register" method="post" id="registerForm" accept-charset="UTF-8">
        <div class="form-group">
            <label class="form-label" for="ten">Full Name</label>
            <input type="text"
                   class="form-input"
                   id="ten"
                   name="ten"
                   placeholder="John Doe"
                   value="${param.ten}"
                   required>
        </div>

        <div class="form-group">
            <label class="form-label" for="email">Email</label>
            <input type="email"
                   class="form-input"
                   id="email"
                   name="email"
                   placeholder="your@email.com"
                   value="${param.email}"
                   required>
        </div>

        <div class="form-group">
            <label class="form-label" for="matKhau">Password</label>
            <input type="password"
                   class="form-input"
                   id="matKhau"
                   name="matKhau"
                   placeholder="Minimum 6 characters"
                   minlength="6"
                   required>
            <div class="password-strength">
                <div class="strength-bar">
                    <div class="strength-fill" id="strengthFill"></div>
                </div>
                <div class="strength-text" id="strengthText"></div>
            </div>
        </div>

        <div class="form-group">
            <label class="form-label" for="confirmPassword">Confirm Password</label>
            <input type="password"
                   class="form-input"
                   id="confirmPassword"
                   placeholder="Re-enter password"
                   required>
        </div>

        <div class="form-checkbox">
            <input type="checkbox"
                   id="rememberMe"
                   name="rememberMe"
                   value="true">
            <label for="rememberMe">Remember me</label>
        </div>

        <button type="submit" class="btn btn-primary btn-submit">
            Create Account
        </button>
    </form>

    <div class="auth-footer">
        <p>
            Already have an account?
            <a href="${pageContext.request.contextPath}/DangNhap.jsp">Login</a>
        </p>
    </div>

    <div class="theme-selector">
        <button class="btn-icon" onclick="setTheme('light')" title="Light Mode">○</button>
        <button class="btn-icon" onclick="setTheme('dark')" title="Dark Mode">●</button>
    </div>
</div>

<script>
    const passwordInput = document.getElementById('matKhau');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const strengthFill = document.getElementById('strengthFill');
    const strengthText = document.getElementById('strengthText');
    const form = document.getElementById('registerForm');

    // Password strength checker
    passwordInput.addEventListener('input', () => {
        const password = passwordInput.value;
        let strength = 0;

        if (password.length >= 6) strength += 25;
        if (password.length >= 8) strength += 25;
        if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength += 25;
        if (/[0-9]/.test(password)) strength += 25;

        strengthFill.style.width = strength + '%';

        if (strength <= 25) {
            strengthFill.style.background = 'var(--color-black)';
            strengthText.textContent = 'Weak';
            strengthText.style.color = 'var(--color-black)';
        } else if (strength <= 50) {
            strengthFill.style.background = 'var(--color-gray-600)';
            strengthText.textContent = 'Fair';
            strengthText.style.color = 'var(--color-gray-600)';
        } else if (strength <= 75) {
            strengthFill.style.background = 'var(--color-gray-500)';
            strengthText.textContent = 'Good';
            strengthText.style.color = 'var(--color-gray-500)';
        } else {
            strengthFill.style.background = 'var(--color-black)';
            strengthText.textContent = 'Strong';
            strengthText.style.color = 'var(--color-black)';
        }
    });

    // Confirm password validation
    confirmPasswordInput.addEventListener('input', () => {
        if (confirmPasswordInput.value && passwordInput.value !== confirmPasswordInput.value) {
            confirmPasswordInput.style.borderColor = 'var(--color-danger)';
        } else {
            confirmPasswordInput.style.borderColor = 'var(--border-color)';
        }
    });

    // Form validation
    form.addEventListener('submit', (e) => {
        if (passwordInput.value !== confirmPasswordInput.value) {
            e.preventDefault();
            alert('Passwords do not match!');
            confirmPasswordInput.focus();
        }
    });

    function setTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('theme', theme);
        document.cookie = `theme=${theme}; path=/; max-age=31536000`;
    }

    function loadTheme() {
        const savedTheme = localStorage.getItem('theme') ||
            getCookie('theme') ||
            'light';
        document.documentElement.setAttribute('data-theme', savedTheme);
    }

    function getCookie(name) {
        const value = "; " + document.cookie;
        const parts = value.split("; " + name + "=");
        if (parts.length === 2) return parts.pop().split(";").shift();
        return null;
    }

    loadTheme();
</script>
</body>
</html>