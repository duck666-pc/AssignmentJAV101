<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Ký - Task Manager</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: var(--spacing-lg);
        }

        .auth-container {
            background: var(--bg-primary);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            width: 100%;
            max-width: 480px;
            padding: var(--spacing-xl);
            animation: slideUp 0.5s ease;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .auth-header {
            text-align: center;
            margin-bottom: var(--spacing-xl);
        }

        .auth-logo {
            font-size: 3rem;
            margin-bottom: var(--spacing-md);
        }

        .auth-header h1 {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: var(--spacing-sm);
        }

        .auth-header p {
            font-size: 0.875rem;
            color: var(--text-secondary);
        }

        .alert {
            padding: var(--spacing-md);
            border-radius: var(--radius-md);
            margin-bottom: var(--spacing-lg);
            font-size: 0.875rem;
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .alert-error {
            background: rgba(239, 68, 68, 0.1);
            color: var(--color-danger);
            border: 1px solid rgba(239, 68, 68, 0.2);
        }

        .form-group {
            margin-bottom: var(--spacing-lg);
        }

        .form-label {
            display: block;
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: var(--spacing-sm);
        }

        .form-input {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            font-size: 0.9375rem;
            background: var(--bg-primary);
            color: var(--text-primary);
            transition: all var(--transition-fast);
        }

        .form-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .password-strength {
            margin-top: var(--spacing-sm);
        }

        .strength-bar {
            height: 4px;
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
            font-size: 0.75rem;
            color: var(--text-secondary);
            font-weight: 500;
        }

        .form-checkbox {
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
            margin-bottom: var(--spacing-lg);
        }

        .form-checkbox input {
            width: 18px;
            height: 18px;
            cursor: pointer;
        }

        .form-checkbox label {
            font-size: 0.875rem;
            color: var(--text-secondary);
            cursor: pointer;
        }

        .btn-submit {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: var(--radius-md);
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all var(--transition-fast);
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }

        .btn-submit:active {
            transform: translateY(0);
        }

        .auth-footer {
            text-align: center;
            margin-top: var(--spacing-xl);
            padding-top: var(--spacing-lg);
            border-top: 1px solid var(--border-color);
            font-size: 0.875rem;
            color: var(--text-secondary);
        }

        .auth-footer a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            transition: color var(--transition-fast);
        }

        .auth-footer a:hover {
            color: #764ba2;
            text-decoration: underline;
        }

        .theme-selector {
            display: flex;
            justify-content: center;
            gap: var(--spacing-sm);
            margin-top: var(--spacing-lg);
        }

        .theme-btn {
            width: 40px;
            height: 40px;
            border-radius: var(--radius-full);
            border: 2px solid var(--border-color);
            background: var(--bg-primary);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            transition: all var(--transition-fast);
        }

        .theme-btn:hover {
            border-color: #667eea;
            transform: scale(1.1);
        }

        [data-theme="dark"] body {
            background: linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 100%);
        }
    </style>
</head>
<body>
<div class="auth-container">
    <div class="auth-header">
        <div class="auth-logo">📋</div>
        <h1>Đăng Ký Tài Khoản</h1>
        <p>Tạo tài khoản để bắt đầu quản lý công việc</p>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-error">
            ⚠️ ${error}
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/auth?action=register" method="post" id="registerForm" accept-charset="UTF-8">
        <div class="form-group">
            <label class="form-label" for="ten">Họ và tên</label>
            <input type="text"
                   class="form-input"
                   id="ten"
                   name="ten"
                   placeholder="Nguyễn Văn A"
                   value="${param.ten}"
                   required>
        </div>

        <div class="form-group">
            <label class="form-label" for="email">Email</label>
            <input type="email"
                   class="form-input"
                   id="email"
                   name="email"
                   placeholder="email@example.com"
                   value="${param.email}"
                   required>
        </div>

        <div class="form-group">
            <label class="form-label" for="matKhau">Mật khẩu</label>
            <input type="password"
                   class="form-input"
                   id="matKhau"
                   name="matKhau"
                   placeholder="••••••••"
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
            <label class="form-label" for="confirmPassword">Xác nhận mật khẩu</label>
            <input type="password"
                   class="form-input"
                   id="confirmPassword"
                   placeholder="••••••••"
                   required>
        </div>

        <div class="form-checkbox">
            <input type="checkbox"
                   id="rememberMe"
                   name="rememberMe"
                   value="true">
            <label for="rememberMe">Ghi nhớ đăng nhập</label>
        </div>

        <button type="submit" class="btn-submit">
            Đăng Ký
        </button>
    </form>

    <div class="auth-footer">
        <p>
            Đã có tài khoản?
            <a href="${pageContext.request.contextPath}/DangNhap.jsp">Đăng nhập ngay</a>
        </p>
    </div>

    <div class="theme-selector">
        <button class="theme-btn" onclick="setTheme('light')" title="Chế độ sáng">☀️</button>
        <button class="theme-btn" onclick="setTheme('dark')" title="Chế độ tối">🌙</button>
    </div>
</div>

<script>
    const passwordInput = document.getElementById('matKhau');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const strengthFill = document.getElementById('strengthFill');
    const strengthText = document.getElementById('strengthText');
    const form = document.getElementById('registerForm');

    // Kiểm tra độ mạnh mật khẩu
    passwordInput.addEventListener('input', () => {
        const password = passwordInput.value;
        let strength = 0;

        if (password.length >= 6) strength += 25;
        if (password.length >= 8) strength += 25;
        if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength += 25;
        if (/[0-9]/.test(password)) strength += 25;

        strengthFill.style.width = strength + '%';

        if (strength <= 25) {
            strengthFill.style.background = '#ef4444';
            strengthText.textContent = 'Yếu';
            strengthText.style.color = '#ef4444';
        } else if (strength <= 50) {
            strengthFill.style.background = '#f59e0b';
            strengthText.textContent = 'Trung bình';
            strengthText.style.color = '#f59e0b';
        } else if (strength <= 75) {
            strengthFill.style.background = '#3b82f6';
            strengthText.textContent = 'Tốt';
            strengthText.style.color = '#3b82f6';
        } else {
            strengthFill.style.background = '#10b981';
            strengthText.textContent = 'Rất mạnh';
            strengthText.style.color = '#10b981';
        }
    });

    // Kiểm tra xác nhận mật khẩu
    confirmPasswordInput.addEventListener('input', () => {
        if (confirmPasswordInput.value && passwordInput.value !== confirmPasswordInput.value) {
            confirmPasswordInput.style.borderColor = '#ef4444';
        } else {
            confirmPasswordInput.style.borderColor = 'var(--border-color)';
        }
    });

    // Xác thực form
    form.addEventListener('submit', (e) => {
        if (passwordInput.value !== confirmPasswordInput.value) {
            e.preventDefault();
            alert('Mật khẩu xác nhận không khớp!');
            confirmPasswordInput.focus();
        }
    });

    function setTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('theme', theme);
        document.cookie = "theme=" + theme + "; path=/; max-age=31536000";
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
