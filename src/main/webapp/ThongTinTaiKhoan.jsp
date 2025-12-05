<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông Tin Tài Khoản</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        :root {
            --bg-primary: #ffffff;
            --bg-secondary: #f8f9fa;
            --text-primary: #1a1a1a;
            --text-secondary: #666;
            --border-color: #e5e5e5;
            --hover-bg: #f5f5f5;
        }

        [data-theme="dark"] {
            --bg-primary: #1a1a1a;
            --bg-secondary: #2a2a2a;
            --text-primary: #ffffff;
            --text-secondary: #999;
            --border-color: #3a3a3a;
            --hover-bg: #333;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: var(--bg-secondary);
            min-height: 100vh;
            color: var(--text-primary);
            transition: background 0.3s, color 0.3s;
        }

        .header {
            background: var(--bg-primary);
            border-bottom: 1px solid var(--border-color);
            padding: 16px 24px;
        }

        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h1 {
            font-size: 20px;
            font-weight: 600;
        }

        .btn-back {
            padding: 6px 12px;
            background: transparent;
            border: 1px solid var(--border-color);
            color: var(--text-primary);
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s;
        }

        .btn-back:hover {
            background: var(--hover-bg);
        }

        .container {
            max-width: 800px;
            margin: 24px auto;
            padding: 0 24px;
        }

        .profile-card {
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 32px;
            margin-bottom: 24px;
        }

        .profile-header {
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 32px;
            padding-bottom: 24px;
            border-bottom: 1px solid var(--border-color);
        }

        .profile-avatar {
            width: 80px;
            height: 80px;
            background: var(--text-primary);
            color: var(--bg-primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            font-weight: 600;
        }

        .profile-info h2 {
            font-size: 24px;
            margin-bottom: 4px;
        }

        .info-group {
            margin-bottom: 24px;
        }

        .info-label {
            font-size: 14px;
            color: var(--text-secondary);
            margin-bottom: 6px;
            font-weight: 500;
        }

        .info-value {
            font-size: 16px;
            color: var(--text-primary);
        }

        .btn-edit {
            padding: 8px 16px;
            background: var(--text-primary);
            color: var(--bg-primary);
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.2s;
            margin-right: 8px;
        }

        .btn-edit:hover {
            opacity: 0.9;
        }

        .btn-cancel {
            padding: 8px 16px;
            background: transparent;
            border: 1px solid var(--border-color);
            color: var(--text-primary);
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.2s;
        }

        .btn-cancel:hover {
            background: var(--hover-bg);
        }

        .edit-form {
            display: none;
        }

        .edit-form.active {
            display: block;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 6px;
            color: var(--text-primary);
        }

        .form-group input {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 14px;
            background: var(--bg-primary);
            color: var(--text-primary);
            transition: all 0.2s;
        }

        .form-group input:focus {
            outline: none;
            border-color: var(--text-primary);
        }

        .message {
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 14px;
            display: none;
        }

        .success-message {
            background: #efe;
            color: #3c3;
            border: 1px solid #dfd;
        }

        .error-message {
            background: #fee;
            color: #c33;
            border: 1px solid #fdd;
        }

        [data-theme="dark"] .success-message {
            background: #204a20;
            color: #66bb6a;
            border: 1px solid #205a20;
        }

        [data-theme="dark"] .error-message {
            background: #4a2020;
            color: #ff6b6b;
            border: 1px solid #5a2020;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-top: 24px;
        }

        .stat-card {
            background: var(--bg-secondary);
            padding: 20px;
            border-radius: 8px;
            border: 1px solid var(--border-color);
        }

        .stat-value {
            font-size: 32px;
            font-weight: 600;
            margin-bottom: 4px;
        }

        .stat-label {
            font-size: 14px;
            color: var(--text-secondary);
        }
    </style>
</head>
<body>
<div class="header">
    <div class="header-content">
        <h1>Thông Tin Tài Khoản</h1>
        <a href="TrangChu.jsp" class="btn-back">← Quay lại</a>
    </div>
</div>

<div class="container">
    <div class="success-message" id="successMsg"></div>
    <div class="error-message" id="errorMsg"></div>

    <div class="profile-card">
        <div class="profile-header">
            <div class="profile-avatar" id="profileAvatar">A</div>
            <div class="profile-info">
                <h2 id="profileName">Đang tải...</h2>
            </div>
        </div>

        <div id="viewMode">
            <div class="info-group">
                <div class="info-label">Email</div>
                <div class="info-value" id="viewEmail">-</div>
            </div>

            <button class="btn-edit" onclick="showEditForm()">Chỉnh sửa</button>
        </div>

        <div id="editMode" class="edit-form">
            <form id="editForm">
                <div class="form-group">
                    <label>Họ và tên</label>
                    <input type="text" id="editName" required>
                </div>

                <div class="form-group">
                    <label>Email</label>
                    <input type="email" id="editEmail" required>
                </div>

                <div class="form-group">
                    <label>Mật khẩu mới (để trống nếu không đổi)</label>
                    <input type="password" id="editPassword" placeholder="••••••••">
                </div>

                <button type="submit" class="btn-edit">Lưu thay đổi</button>
                <button type="button" class="btn-cancel" onclick="cancelEdit()">Hủy</button>
            </form>
        </div>
    </div>
</div>

<script>
    const ACCOUNTS_KEY = 'taskManagerAccounts';
    const TASKS_KEY = 'taskManagerTasks';
    let currentUser = null;

    function loadTheme() {
        const savedTheme = localStorage.getItem('theme') || 'light';
        document.documentElement.setAttribute('data-theme', savedTheme);
    }

    function checkAuth() {
        const userStr = sessionStorage.getItem('currentUser');
        if (!userStr) {
            window.location.href = 'DangNhap.html';
            return;
        }
        currentUser = JSON.parse(userStr);
        loadProfile();
        loadStats();
    }

    function loadProfile() {
        document.getElementById('profileAvatar').textContent = currentUser.ten.charAt(0).toUpperCase();
        document.getElementById('profileName').textContent = currentUser.ten;
        document.getElementById('viewEmail').textContent = currentUser.email;
    }

    function loadStats() {
        const allTasks = JSON.parse(localStorage.getItem(TASKS_KEY) || '[]');
        const userTasks = allTasks.filter(t =>
            t.nguoiTaoId === currentUser.id ||
            t.nguoiThucHienId === currentUser.id
        );

        document.getElementById('statTotal').textContent = userTasks.length;
        document.getElementById('statDone').textContent = userTasks.filter(t => t.trangThai === 'done').length;
        document.getElementById('statInProgress').textContent = userTasks.filter(t => t.trangThai === 'inprogress').length;
        document.getElementById('statTodo').textContent = userTasks.filter(t => t.trangThai === 'todo').length;
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

    document.getElementById('editForm').addEventListener('submit', (e) => {
        e.preventDefault();

        const successMsg = document.getElementById('successMsg');
        const errorMsg = document.getElementById('errorMsg');
        successMsg.style.display = 'none';
        errorMsg.style.display = 'none';

        const newName = document.getElementById('editName').value.trim();
        const newEmail = document.getElementById('editEmail').value.trim();
        const newPassword = document.getElementById('editPassword').value;

        if (!newName || !newEmail) {
            errorMsg.textContent = 'Vui lòng nhập đầy đủ thông tin';
            errorMsg.style.display = 'block';
            return;
        }

        let accounts = JSON.parse(localStorage.getItem(ACCOUNTS_KEY) || '[]');
        const accountIndex = accounts.findIndex(a => a.id === currentUser.id);

        if (accountIndex === -1) {
            errorMsg.textContent = 'Không tìm thấy tài khoản';
            errorMsg.style.display = 'block';
            return;
        }

        const emailTaken = accounts.find(a => a.email === newEmail && a.id !== currentUser.id);
        if (emailTaken) {
            errorMsg.textContent = 'Email đã được sử dụng';
            errorMsg.style.display = 'block';
            return;
        }

        accounts[accountIndex].ten = newName;
        accounts[accountIndex].email = newEmail;
        if (newPassword) {
            accounts[accountIndex].matKhau = newPassword;
        }

        localStorage.setItem(ACCOUNTS_KEY, JSON.stringify(accounts));

        currentUser.ten = newName;
        currentUser.email = newEmail;
        sessionStorage.setItem('currentUser', JSON.stringify(currentUser));

        successMsg.textContent = 'Cập nhật thành công';
        successMsg.style.display = 'block';

        loadProfile();
        cancelEdit();

        setTimeout(() => {
            successMsg.style.display = 'none';
        }, 3000);
    });

    loadTheme();
    checkAuth();
</script>
</body>
</html>