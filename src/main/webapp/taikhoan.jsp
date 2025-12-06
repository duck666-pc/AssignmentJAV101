<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- Kiểm tra đăng nhập --%>
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/dangnhap.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account - Task Manager</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        body {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .container {
            flex: 1;
            max-width: 800px;
            width: 100%;
            margin: 0 auto;
            padding: var(--spacing-lg);
        }

        .profile-card {
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: var(--spacing-2xl);
            margin-bottom: var(--spacing-lg);
        }

        .profile-header {
            display: flex;
            align-items: center;
            gap: var(--spacing-lg);
            margin-bottom: var(--spacing-2xl);
            padding-bottom: var(--spacing-xl);
            border-bottom: 1px solid var(--border-color);
        }

        .profile-avatar {
            width: 80px;
            height: 80px;
            background: var(--color-black);
            color: var(--color-white);
            border-radius: var(--radius-full);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: var(--font-size-3xl);
            font-weight: var(--font-weight-bold);
            border: 1px solid var(--border-color);
        }

        [data-theme="dark"] .profile-avatar {
            background: var(--color-white);
            color: var(--color-black);
        }

        .profile-info h2 {
            font-size: var(--font-size-2xl);
            font-weight: var(--font-weight-semibold);
            margin-bottom: var(--spacing-xs);
            letter-spacing: -0.02em;
        }

        .profile-role {
            font-size: var(--font-size-sm);
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            font-weight: var(--font-weight-medium);
        }

        .info-group {
            margin-bottom: var(--spacing-xl);
        }

        .info-label {
            font-size: var(--font-size-xs);
            color: var(--text-secondary);
            margin-bottom: var(--spacing-sm);
            font-weight: var(--font-weight-medium);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .info-value {
            font-size: var(--font-size-base);
            color: var(--text-primary);
            font-weight: var(--font-weight-medium);
        }

        .action-group {
            display: flex;
            gap: var(--spacing-sm);
            flex-wrap: wrap;
        }

        .edit-form {
            display: none;
        }

        .edit-form.active {
            display: block;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: var(--spacing-md);
            margin-bottom: var(--spacing-lg);
        }

        .stat-card {
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            padding: var(--spacing-lg);
            border-radius: var(--radius-lg);
            transition: all var(--transition-fast);
        }

        .stat-card:hover {
            border-color: var(--text-primary);
            transform: translateY(-2px);
        }

        .stat-value {
            font-size: var(--font-size-3xl);
            font-weight: var(--font-weight-bold);
            margin-bottom: var(--spacing-xs);
            letter-spacing: -0.02em;
        }

        .stat-label {
            font-size: var(--font-size-xs);
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            font-weight: var(--font-weight-medium);
        }
    </style>
</head>
<body>
<!-- HEADER -->
<div class="header">
    <div class="header-content">
        <div class="header-brand">
            <span class="logo">□</span>
            <h1>ACCOUNT</h1>
        </div>
        <div class="header-actions">
            <button class="btn-icon" onclick="setTheme('light')" title="Light Mode">○</button>
            <button class="btn-icon" onclick="setTheme('dark')" title="Dark Mode">●</button>
            <a href="${pageContext.request.contextPath}/trangchu.jsp" class="btn btn-secondary">← Back</a>
        </div>
    </div>
</div>

<div class="container">
    <div id="successMsg" class="alert alert-success" style="display: none;"></div>
    <div id="errorMsg" class="alert alert-error" style="display: none;"></div>

    <!-- Stats Grid -->
    <div class="stats-grid" id="statsGrid">
        <div class="stat-card">
            <div class="stat-value" id="statTotal">0</div>
            <div class="stat-label">Total Tasks</div>
        </div>
        <div class="stat-card">
            <div class="stat-value" id="statTodo">0</div>
            <div class="stat-label">To Do</div>
        </div>
        <div class="stat-card">
            <div class="stat-value" id="statInProgress">0</div>
            <div class="stat-label">In Progress</div>
        </div>
        <div class="stat-card">
            <div class="stat-value" id="statDone">0</div>
            <div class="stat-label">Completed</div>
        </div>
    </div>

    <!-- Profile Card -->
    <div class="profile-card">
        <div class="profile-header">
            <div class="profile-avatar" id="profileAvatar">
                <c:out value="${fn:substring(sessionScope.user.ten, 0, 1)}" />
            </div>
            <div class="profile-info">
                <h2 id="profileName"><c:out value="${sessionScope.user.ten}" /></h2>
                <div class="profile-role"><c:out value="${sessionScope.user.vaiTro}" /></div>
            </div>
        </div>

        <div id="viewMode">
            <div class="info-group">
                <div class="info-label">Email Address</div>
                <div class="info-value" id="viewEmail"><c:out value="${sessionScope.user.email}" /></div>
            </div>

            <div class="info-group">
                <div class="info-label">User ID</div>
                <div class="info-value">#${sessionScope.user.id}</div>
            </div>

            <div class="action-group">
                <button class="btn btn-primary" onclick="showEditForm()">Edit Profile</button>
                <form action="${pageContext.request.contextPath}/auth?action=logout" method="post" style="margin: 0;">
                    <button type="submit" class="btn btn-secondary">Logout</button>
                </form>
            </div>
        </div>

        <div id="editMode" class="edit-form">
            <form id="editForm">
                <div class="form-group">
                    <label class="form-label">Full Name</label>
                    <input type="text" class="form-input" id="editName" required>
                </div>

                <div class="form-group">
                    <label class="form-label">Email</label>
                    <input type="email" class="form-input" id="editEmail" required>
                </div>

                <div class="form-group">
                    <label class="form-label">New Password (leave blank to keep current)</label>
                    <input type="password" class="form-input" id="editPassword" placeholder="Enter new password">
                </div>

                <div class="action-group">
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                    <button type="button" class="btn btn-secondary" onclick="cancelEdit()">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    const API_BASE = '${pageContext.request.contextPath}';
    const API_TASKS = API_BASE + '/nhiemvu';

    let currentUser = {
        id: ${sessionScope.user.id},
        ten: '<c:out value="${sessionScope.user.ten}" />',
        email: '<c:out value="${sessionScope.user.email}" />',
        vaiTro: '<c:out value="${sessionScope.user.vaiTro}" />'
    };

    function setTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('theme', theme);
        document.cookie = 'theme=' + theme + '; path=/; max-age=31536000';
    }

    function loadTheme() {
        const savedTheme = localStorage.getItem('theme') || getCookie('theme') || 'light';
        document.documentElement.setAttribute('data-theme', savedTheme);
    }

    function getCookie(name) {
        const value = "; " + document.cookie;
        const parts = value.split("; " + name + "=");
        if (parts.length === 2) return parts.pop().split(";").shift();
        return null;
    }

    async function loadStats() {
        try {
            const response = await fetch(API_TASKS);
            if (response.ok) {
                const tasks = await response.json();
                const userTasks = tasks.filter(t =>
                    t.nguoiTaoId === currentUser.id ||
                    t.nguoiThucHienId === currentUser.id
                );

                document.getElementById('statTotal').textContent = userTasks.length;
                document.getElementById('statTodo').textContent = userTasks.filter(t => t.trangThai === 'todo').length;
                document.getElementById('statInProgress').textContent = userTasks.filter(t => t.trangThai === 'inprogress').length;
                document.getElementById('statDone').textContent = userTasks.filter(t => t.trangThai === 'done').length;
            }
        } catch (error) {
            console.error('Error loading stats:', error);
        }
    }

    function showEditForm() {
        document.getElementById('viewMode').style.display = 'none';
        document.getElementById('editMode').classList.add('active');

        document.getElementById('editName').value = currentUser.ten;
        document.getElementById('editEmail').value = currentUser.email;
        document.getElementById('editPassword').value = '';
    }

    function cancelEdit() {
        document.getElementById('viewMode').style.display = 'block';
        document.getElementById('editMode').classList.remove('active');
    }

    function showMessage(type, text) {
        const successMsg = document.getElementById('successMsg');
        const errorMsg = document.getElementById('errorMsg');

        successMsg.style.display = 'none';
        errorMsg.style.display = 'none';

        if (type === 'success') {
            successMsg.textContent = text;
            successMsg.style.display = 'block';
        } else {
            errorMsg.textContent = text;
            errorMsg.style.display = 'block';
        }

        setTimeout(() => {
            successMsg.style.display = 'none';
            errorMsg.style.display = 'none';
        }, 5000);
    }

    document.getElementById('editForm').addEventListener('submit', async (e) => {
        e.preventDefault();

        const newName = document.getElementById('editName').value.trim();
        const newEmail = document.getElementById('editEmail').value.trim();
        const newPassword = document.getElementById('editPassword').value;

        if (!newName || !newEmail) {
            showMessage('error', 'Please fill in all required fields');
            return;
        }

        // Note: This requires backend API endpoint for updating profile
        // For now, just show a message
        showMessage('success', 'Profile update feature requires backend implementation');
        cancelEdit();
    });

    loadTheme();
    loadStats();
</script>
</body>
</html>