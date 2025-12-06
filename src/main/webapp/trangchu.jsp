<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Kiểm tra đăng nhập --%>
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/DangNhap.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Chủ - Task Manager</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        /* =================================
           MAIN CONTAINER
           ================================= */
        .main-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: var(--spacing-lg);
        }

        /* =================================
           TOOLBAR
           ================================= */
        .toolbar {
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: var(--spacing-lg);
            margin-bottom: var(--spacing-lg);
            display: flex;
            gap: var(--spacing-lg);
            align-items: center;
            flex-wrap: wrap;
            box-shadow: var(--shadow-sm);
        }

        .toolbar-section {
            display: flex;
            gap: var(--spacing-md);
            align-items: center;
            flex-wrap: wrap;
        }

        .toolbar-section.grow {
            flex: 1;
        }

        .filter-group {
            display: flex;
            gap: var(--spacing-sm);
            align-items: center;
        }

        .filter-label {
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--text-secondary);
            white-space: nowrap;
        }

        .filter-select {
            min-width: 180px;
            padding: 8px 12px;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            background: var(--bg-primary);
            color: var(--text-primary);
            font-size: 0.875rem;
            cursor: pointer;
            transition: all var(--transition-fast);
        }

        .filter-select:focus {
            outline: none;
            border-color: var(--text-primary);
            box-shadow: 0 0 0 3px rgba(0,0,0,0.05);
        }

        .view-modes {
            display: flex;
            gap: var(--spacing-xs);
            background: var(--bg-secondary);
            padding: 4px;
            border-radius: var(--radius-md);
        }

        .view-btn {
            padding: 8px 16px;
            border: none;
            background: transparent;
            color: var(--text-secondary);
            font-size: 0.875rem;
            font-weight: 600;
            cursor: pointer;
            border-radius: var(--radius-sm);
            transition: all var(--transition-fast);
        }

        .view-btn:hover {
            background: var(--bg-primary);
            color: var(--text-primary);
        }

        .view-btn.active {
            background: var(--bg-primary);
            color: var(--text-primary);
            box-shadow: var(--shadow-sm);
        }

        .btn-add-new {
            padding: 10px 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: var(--radius-md);
            font-size: 0.875rem;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
            transition: all var(--transition-fast);
        }

        .btn-add-new:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }

        /* =================================
           LIST VIEW
           ================================= */
        .list-view {
            display: none;
        }

        .list-view.active {
            display: block;
        }

        .task-list {
            display: flex;
            flex-direction: column;
            gap: var(--spacing-md);
        }

        .task-card {
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: var(--spacing-lg);
            transition: all var(--transition-fast);
            cursor: pointer;
        }

        .task-card:hover {
            box-shadow: var(--shadow-md);
            border-color: var(--border-hover);
            transform: translateY(-2px);
        }

        .task-card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: var(--spacing-md);
        }

        .task-title {
            font-size: 1.125rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: var(--spacing-sm);
        }

        .task-meta {
            display: flex;
            gap: var(--spacing-sm);
            align-items: center;
            flex-wrap: wrap;
        }

        .task-description {
            font-size: 0.875rem;
            color: var(--text-secondary);
            margin-bottom: var(--spacing-md);
            line-height: 1.6;
        }

        .task-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: var(--spacing-md);
            border-top: 1px solid var(--border-color);
        }

        .task-dates {
            display: flex;
            gap: var(--spacing-md);
            font-size: 0.75rem;
            color: var(--text-secondary);
        }

        .task-actions {
            display: flex;
            gap: var(--spacing-sm);
        }

        .task-action-btn {
            padding: 6px 12px;
            border: 1px solid var(--border-color);
            background: transparent;
            color: var(--text-primary);
            border-radius: var(--radius-sm);
            font-size: 0.75rem;
            cursor: pointer;
            transition: all var(--transition-fast);
        }

        .task-action-btn:hover {
            background: var(--hover-bg);
        }

        .task-action-btn.danger:hover {
            background: var(--color-danger);
            color: white;
            border-color: var(--color-danger);
        }

        /* =================================
           KANBAN VIEW
           ================================= */
        .kanban-view {
            display: none;
        }

        .kanban-view.active {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: var(--spacing-lg);
        }

        .kanban-column {
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: var(--spacing-lg);
            min-height: 500px;
        }

        .kanban-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--spacing-lg);
            padding-bottom: var(--spacing-md);
            border-bottom: 2px solid var(--border-color);
        }

        .kanban-title {
            font-size: 1rem;
            font-weight: 700;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
        }

        .kanban-count {
            background: var(--bg-secondary);
            color: var(--text-secondary);
            padding: 2px 8px;
            border-radius: var(--radius-full);
            font-size: 0.75rem;
            font-weight: 700;
        }

        .kanban-tasks {
            display: flex;
            flex-direction: column;
            gap: var(--spacing-md);
            min-height: 400px;
        }

        .kanban-task {
            background: var(--bg-secondary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: var(--spacing-md);
            cursor: move;
            transition: all var(--transition-fast);
        }

        .kanban-task:hover {
            box-shadow: var(--shadow-md);
            transform: translateY(-2px);
        }

        .kanban-task.dragging {
            opacity: 0.5;
        }

        .kanban-task.drag-over {
            border: 2px dashed var(--text-primary);
        }

        .kanban-task-title {
            font-size: 0.9375rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: var(--spacing-sm);
        }

        .kanban-task-meta {
            display: flex;
            gap: var(--spacing-sm);
            align-items: center;
            margin-top: var(--spacing-sm);
        }

        /* =================================
           CALENDAR VIEW
           ================================= */
        .calendar-view {
            display: none;
        }

        .calendar-view.active {
            display: block;
        }

        .calendar-header {
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: var(--spacing-lg);
            margin-bottom: var(--spacing-lg);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .calendar-nav {
            display: flex;
            gap: var(--spacing-sm);
            align-items: center;
        }

        .calendar-nav-btn {
            width: 36px;
            height: 36px;
            border: 1px solid var(--border-color);
            background: transparent;
            color: var(--text-primary);
            border-radius: var(--radius-md);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all var(--transition-fast);
        }

        .calendar-nav-btn:hover {
            background: var(--hover-bg);
        }

        .calendar-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--text-primary);
            min-width: 200px;
            text-align: center;
        }

        .calendar-grid {
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            overflow: hidden;
        }

        .calendar-weekdays {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            background: var(--bg-secondary);
            border-bottom: 1px solid var(--border-color);
        }

        .calendar-weekday {
            padding: var(--spacing-md);
            text-align: center;
            font-size: 0.875rem;
            font-weight: 700;
            color: var(--text-secondary);
        }

        .calendar-days {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 1px;
            background: var(--border-color);
        }

        .calendar-day {
            background: var(--bg-primary);
            min-height: 120px;
            padding: var(--spacing-sm);
            position: relative;
            transition: all var(--transition-fast);
        }

        .calendar-day:hover {
            background: var(--bg-secondary);
        }

        .calendar-day.other-month {
            opacity: 0.4;
        }

        .calendar-day.today {
            background: rgba(102, 126, 234, 0.1);
        }

        .calendar-day-number {
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: var(--spacing-sm);
        }

        .calendar-day.today .calendar-day-number {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            width: 28px;
            height: 28px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: var(--radius-full);
        }

        .calendar-task {
            background: var(--bg-secondary);
            border-left: 3px solid var(--color-todo);
            padding: 4px 8px;
            margin-bottom: 4px;
            border-radius: 4px;
            font-size: 0.75rem;
            cursor: pointer;
            transition: all var(--transition-fast);
        }

        .calendar-task:hover {
            transform: translateX(4px);
            box-shadow: var(--shadow-sm);
        }

        .calendar-task.status-todo {
            border-left-color: var(--color-todo);
        }

        .calendar-task.status-inprogress {
            border-left-color: var(--color-inprogress);
        }

        .calendar-task.status-done {
            border-left-color: var(--color-done);
        }

        /* =================================
           EMPTY STATE
           ================================= */
        .empty-state {
            text-align: center;
            padding: var(--spacing-xl) var(--spacing-lg);
            color: var(--text-secondary);
        }

        .empty-state-icon {
            font-size: 4rem;
            margin-bottom: var(--spacing-lg);
            opacity: 0.5;
        }

        .empty-state-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: var(--spacing-sm);
        }

        .empty-state-text {
            font-size: 0.875rem;
            margin-bottom: var(--spacing-lg);
        }

        /* =================================
           RESPONSIVE
           ================================= */
        @media (max-width: 1024px) {
            .kanban-view.active {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .toolbar {
                flex-direction: column;
                align-items: stretch;
            }

            .toolbar-section {
                width: 100%;
            }

            .filter-select {
                width: 100%;
            }

            .calendar-days {
                font-size: 0.75rem;
            }

            .calendar-day {
                min-height: 80px;
            }
        }
    </style>
</head>
<body>
<!-- HEADER -->
<div class="header">
    <div class="header-content">
        <div class="header-brand">
            <span class="logo">📋</span>
            <h1>Task Manager</h1>
        </div>
        <div class="header-actions">
            <button class="btn-icon" onclick="setTheme('light')" title="Chế độ sáng">☀️</button>
            <button class="btn-icon" onclick="setTheme('dark')" title="Chế độ tối">🌙</button>
            <div class="user-section">
                <div class="user-avatar" onclick="location.href='${pageContext.request.contextPath}/taikhoan.jsp'">
                    ${sessionScope.user.ten.substring(0,1).toUpperCase()}
                </div>
                <div class="user-info">
                    <div class="user-name">${sessionScope.user.ten}</div>
                    <div class="user-role">${sessionScope.user.vaiTro}</div>
                </div>
            </div>
            <form action="${pageContext.request.contextPath}/auth?action=logout" method="post" style="margin: 0;">
                <button type="submit" class="btn btn-secondary">Đăng xuất</button>
            </form>
        </div>
    </div>
</div>

<!-- MAIN CONTAINER -->
<div class="main-container">
    <!-- TOOLBAR -->
    <div class="toolbar">
        <div class="toolbar-section grow">
            <div class="filter-group">
                <label class="filter-label">Dự án:</label>
                <select class="filter-select" id="projectFilter" onchange="loadTasks()">
                    <option value="">Tất cả dự án</option>
                </select>
            </div>
            <div class="filter-group">
                <label class="filter-label">Trạng thái:</label>
                <select class="filter-select" id="statusFilter" onchange="loadTasks()">
                    <option value="">Tất cả</option>
                    <option value="todo">Chưa làm</option>
                    <option value="inprogress">Đang làm</option>
                    <option value="done">Đã xong</option>
                </select>
            </div>
            <div class="filter-group">
                <label class="filter-label">Ưu tiên:</label>
                <select class="filter-select" id="priorityFilter" onchange="loadTasks()">
                    <option value="">Tất cả</option>
                    <option value="high">Cao</option>
                    <option value="medium">Trung bình</option>
                    <option value="low">Thấp</option>
                </select>
            </div>
        </div>

        <div class="toolbar-section">
            <div class="view-modes">
                <button class="view-btn active" onclick="changeView('list')">📋 Danh sách</button>
                <button class="view-btn" onclick="changeView('kanban')">📊 Kanban</button>
                <button class="view-btn" onclick="changeView('calendar')">📅 Lịch</button>
            </div>
        </div>

        <div class="toolbar-section">
            <button class="btn-add-new" onclick="showAddTaskModal()">
                <span>➕</span>
                <span>Thêm nhiệm vụ</span>
            </button>
            <button class="btn btn-secondary" onclick="showAddProjectModal()">
                <span>📁</span>
                <span>Thêm dự án</span>
            </button>
        </div>
    </div>

    <!-- LIST VIEW -->
    <div class="list-view active" id="listView">
        <div class="task-list" id="taskList"></div>
    </div>

    <!-- KANBAN VIEW -->
    <div class="kanban-view" id="kanbanView">
        <div class="kanban-column">
            <div class="kanban-header">
                <div class="kanban-title">
                    📝 Chưa làm
                    <span class="kanban-count" id="todoCount">0</span>
                </div>
            </div>
            <div class="kanban-tasks" id="todoTasks" data-status="todo"></div>
        </div>

        <div class="kanban-column">
            <div class="kanban-header">
                <div class="kanban-title">
                    ⏳ Đang làm
                    <span class="kanban-count" id="inprogressCount">0</span>
                </div>
            </div>
            <div class="kanban-tasks" id="inprogressTasks" data-status="inprogress"></div>
        </div>

        <div class="kanban-column">
            <div class="kanban-header">
                <div class="kanban-title">
                    ✅ Đã xong
                    <span class="kanban-count" id="doneCount">0</span>
                </div>
            </div>
            <div class="kanban-tasks" id="doneTasks" data-status="done"></div>
        </div>
    </div>

    <!-- CALENDAR VIEW -->
    <div class="calendar-view" id="calendarView">
        <div class="calendar-header">
            <div class="calendar-nav">
                <button class="calendar-nav-btn" onclick="changeMonth(-1)">◀</button>
                <div class="calendar-title" id="calendarTitle">Tháng 1, 2025</div>
                <button class="calendar-nav-btn" onclick="changeMonth(1)">▶</button>
            </div>
            <button class="btn btn-secondary" onclick="goToToday()">Hôm nay</button>
        </div>
        <div class="calendar-grid">
            <div class="calendar-weekdays">
                <div class="calendar-weekday">CN</div>
                <div class="calendar-weekday">T2</div>
                <div class="calendar-weekday">T3</div>
                <div class="calendar-weekday">T4</div>
                <div class="calendar-weekday">T5</div>
                <div class="calendar-weekday">T6</div>
                <div class="calendar-weekday">T7</div>
            </div>
            <div class="calendar-days" id="calendarDays"></div>
        </div>
    </div>
</div>

<!-- MODAL THÊM/SỬA NHIỆM VỤ -->
<div class="modal" id="taskModal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 class="modal-title" id="taskModalTitle">Thêm nhiệm vụ mới</h2>
            <button class="modal-close" onclick="closeTaskModal()">✕</button>
        </div>
        <div class="modal-body">
            <form id="taskForm">
                <input type="hidden" id="taskId">

                <div class="form-group">
                    <label class="form-label" for="taskName">Tên nhiệm vụ *</label>
                    <input type="text" class="form-input" id="taskName" required>
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskDescription">Mô tả</label>
                    <textarea class="form-textarea" id="taskDescription" rows="3"></textarea>
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskProject">Dự án</label>
                    <select class="form-select" id="taskProject">
                        <option value="">Không thuộc dự án</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskStatus">Trạng thái</label>
                    <select class="form-select" id="taskStatus">
                        <option value="todo">Chưa làm</option>
                        <option value="inprogress">Đang làm</option>
                        <option value="done">Đã xong</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskPriority">Độ ưu tiên</label>
                    <select class="form-select" id="taskPriority">
                        <option value="1">Rất thấp</option>
                        <option value="2">Thấp</option>
                        <option value="3" selected>Trung bình</option>
                        <option value="4">Cao</option>
                        <option value="5">Rất cao</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskStartDate">Ngày bắt đầu</label>
                    <input type="date" class="form-input" id="taskStartDate">
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskEndDate">Ngày kết thúc</label>
                    <input type="date" class="form-input" id="taskEndDate">
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskNote">Ghi chú</label>
                    <textarea class="form-textarea" id="taskNote" rows="2"></textarea>
                </div>
            </form>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeTaskModal()">Hủy</button>
            <button class="btn btn-primary" onclick="saveTask()">Lưu</button>
        </div>
    </div>
</div>

<!-- MODAL THÊM/SỬA DỰ ÁN -->
<div class="modal" id="projectModal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 class="modal-title" id="projectModalTitle">Thêm dự án mới</h2>
            <button class="modal-close" onclick="closeProjectModal()">✕</button>
        </div>
        <div class="modal-body">
            <form id="projectForm">
                <input type="hidden" id="projectId">

                <div class="form-group">
                    <label class="form-label" for="projectName">Tên dự án *</label>
                    <input type="text" class="form-input" id="projectName" required>
                </div>

                <div class="form-group">
                    <label class="form-label" for="projectDescription">Mô tả</label>
                    <textarea class="form-textarea" id="projectDescription" rows="3"></textarea>
                </div>

                <div class="form-group">
                    <label class="form-label" for="projectAssignee">Người thực hiện</label>
                    <input type="text" class="form-input" id="projectAssignee" value="${sessionScope.user.ten}">
                </div>

                <div class="form-group">
                    <label class="form-label" for="projectStartDate">Ngày bắt đầu</label>
                    <input type="date" class="form-input" id="projectStartDate">
                </div>

                <div class="form-group">
                    <label class="form-label" for="projectEndDate">Ngày kết thúc</label>
                    <input type="date" class="form-input" id="projectEndDate">
                </div>

                <div class="form-group">
                    <label class="form-label" for="projectColor">Màu sắc</label>
                    <input type="color" class="form-input" id="projectColor" value="#667eea">
                </div>

                <div class="form-group">
                    <label class="form-label" for="projectNote">Ghi chú</label>
                    <textarea class="form-textarea" id="projectNote" rows="2"></textarea>
                </div>
            </form>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeProjectModal()">Hủy</button>
            <button class="btn btn-primary" onclick="saveProject()">Lưu</button>
        </div>
    </div>
</div>

<script>
    // ==========================================
    // BIẾN TOÀN CỤC
    // ==========================================
    const API_BASE = '${pageContext.request.contextPath}';
    const API_TASKS = API_BASE + '/nhiemvu';
    const API_PROJECTS = API_BASE + '/duan';

    let currentUser = {
        id: ${sessionScope.user.id},
        ten: '${sessionScope.user.ten}',
        email: '${sessionScope.user.email}',
        vaiTro: '${sessionScope.user.vaiTro}'
    };

    let tasks = [];
    let projects = [];
    let currentView = 'list';
    let currentMonth = new Date().getMonth();
    let currentYear = new Date().getFullYear();

    // ==========================================
    // KHỞI TẠO
    // ==========================================
    document.addEventListener('DOMContentLoaded', () => {
        loadTheme();
        loadProjects();
        loadTasks();
    });

    // ==========================================
    // THEME
    // ==========================================
    function setTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('theme', theme);
        document.cookie = "theme=" + theme + "; path=/; max-age=31536000";
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

    // ==========================================
    // LOAD DỮ LIỆU
    // ==========================================
    async function loadProjects() {
        try {
            const response = await fetch(API_PROJECTS);
            if (response.ok) {
                projects = await response.json();
                updateProjectSelects();
            }
        } catch (error) {
            console.error('Lỗi load projects:', error);
        }
    }

    async function loadTasks() {
        try {
            const projectId = document.getElementById('projectFilter').value;
            const status = document.getElementById('statusFilter').value;

            let url = API_TASKS;
            const params = new URLSearchParams();
            if (projectId) params.append('duAnId', projectId);
            if (status) params.append('trangThai', status);
            if (params.toString()) url += '?' + params.toString();

            const response = await fetch(url);
            if (response.ok) {
                tasks = await response.json();
                renderCurrentView();
            }
        } catch (error) {
            console.error('Lỗi load tasks:', error);
        }
    }

    function updateProjectSelects() {
        const selects = [
            document.getElementById('projectFilter'),
            document.getElementById('taskProject')
        ];

        selects.forEach((select, index) => {
            const currentValue = select.value;
            const options = projects.map(p =>
                `<option value="${p.id}">${p.ten}</option>`
            ).join('');

            if (index === 0) {
                select.innerHTML = '<option value="">Tất cả dự án</option>' + options;
            } else {
                select.innerHTML = '<option value="">Không thuộc dự án</option>' + options;
            }

            if (currentValue) select.value = currentValue;
        });
    }

    // ==========================================
    // RENDER VIEWS
    // ==========================================
    function changeView(view) {
        currentView = view;

        // Update buttons
        document.querySelectorAll('.view-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        event.target.classList.add('active');

        // Hide all views
        document.getElementById('listView').classList.remove('active');
        document.getElementById('kanbanView').classList.remove('active');
        document.getElementById('calendarView').classList.remove('active');

        // Show selected view
        document.getElementById(view + 'View').classList.add('active');

        renderCurrentView();
    }

    function renderCurrentView() {
        const priorityFilter = document.getElementById('priorityFilter').value;
        let filteredTasks = filterTasksByPriority(tasks, priorityFilter);

        if (currentView === 'list') {
            renderListView(filteredTasks);
        } else if (currentView === 'kanban') {
            renderKanbanView(filteredTasks);
        } else if (currentView === 'calendar') {
            renderCalendarView();
        }
    }

    function filterTasksByPriority(tasks, priority) {
        if (!priority) return tasks;

        return tasks.filter(task => {
            const level = getPriorityLevel(task.doUuTien);
            return level === priority;
        });
    }

    function getPriorityLevel(priority) {
        if (priority >= 4) return 'high';
        if (priority >= 3) return 'medium';
        return 'low';
    }

    // ==========================================
    // LIST VIEW
    // ==========================================
    function renderListView(taskList) {
        const container = document.getElementById('taskList');

        if (taskList.length === 0) {
            container.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">📝</div>
                <h3 class="empty-state-title">Chưa có nhiệm vụ nào</h3>
                <p class="empty-state-text">Hãy tạo nhiệm vụ đầu tiên của bạn!</p>
                <button class="btn btn-primary" onclick="showAddTaskModal()">Thêm nhiệm vụ</button>
            </div>
        `;
            return;
        }

        container.innerHTML = taskList.map(task => `
        <div class="task-card" onclick="editTask(${task.id})">
            <div class="task-card-header">
                <div>
                    <h3 class="task-title">${escapeHtml(task.ten)}</h3>
                    <div class="task-meta">
                        ${getStatusBadge(task.trangThai)}
                        ${getPriorityBadge(task.doUuTien)}
                        ${task.duAnTen ? `<span class="badge" style="background: rgba(102, 126, 234, 0.1); color: #667eea;">📁 ${escapeHtml(task.duAnTen)}</span>` : ''}
                    </div>
                </div>
            </div>

            ${task.mo_ta ? `<div class="task-description">${escapeHtml(task.mo_ta)}</div>` : ''}

            <div class="task-footer">
                <div class="task-dates">
                    ${task.ngayBatDau ? `<span>📅 Bắt đầu: ${formatDate(task.ngayBatDau)}</span>` : ''}
                    ${task.ngayKetThuc ? `<span>⏰ Hạn: ${formatDate(task.ngayKetThuc)}</span>` : ''}
                </div>
                <div class="task-actions" onclick="event.stopPropagation()">
                    <button class="task-action-btn" onclick="editTask(${task.id})">✏️ Sửa</button>
                    <button class="task-action-btn danger" onclick="deleteTask(${task.id})">🗑️ Xóa</button>
                </div>
            </div>
        </div>
    `).join('');
    }

    // ==========================================
    // KANBAN VIEW
    // ==========================================
    function renderKanbanView(taskList) {
        const todoTasks = taskList.filter(t => t.trangThai === 'todo');
        const inprogressTasks = taskList.filter(t => t.trangThai === 'inprogress');
        const doneTasks = taskList.filter(t => t.trangThai === 'done');

        document.getElementById('todoCount').textContent = todoTasks.length;
        document.getElementById('inprogressCount').textContent = inprogressTasks.length;
        document.getElementById('doneCount').textContent = doneTasks.length;

        renderKanbanColumn('todoTasks', todoTasks);
        renderKanbanColumn('inprogressTasks', inprogressTasks);
        renderKanbanColumn('doneTasks', doneTasks);
    }

    function renderKanbanColumn(columnId, taskList) {
        const container = document.getElementById(columnId);

        if (taskList.length === 0) {
            container.innerHTML = '<div class="empty-state-text">Không có nhiệm vụ</div>';
            return;
        }

        container.innerHTML = taskList.map(task => `
        <div class="kanban-task" draggable="true" data-id="${task.id}"
             ondragstart="handleDragStart(event)"
             ondragend="handleDragEnd(event)"
             onclick="editTask(${task.id})">
            <div class="kanban-task-title">${escapeHtml(task.ten)}</div>
            ${task.mo_ta ? `<div class="task-description">${escapeHtml(task.mo_ta)}</div>` : ''}
            <div class="kanban-task-meta">
                ${getPriorityBadge(task.doUuTien)}
                ${task.ngayKetThuc ? `<span class="badge" style="background: rgba(245, 158, 11, 0.1); color: #f59e0b;">⏰ ${formatDate(task.ngayKetThuc)}</span>` : ''}
            </div>
        </div>
    `).join('');

        // Setup drop zones
        container.addEventListener('dragover', handleDragOver);
        container.addEventListener('drop', handleDrop);
    }

    let draggedTask = null;

    function handleDragStart(e) {
        draggedTask = e.target;
        e.target.classList.add('dragging');
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/html', e.target.innerHTML);
    }

    function handleDragEnd(e) {
        e.target.classList.remove('dragging');
    }

    function handleDragOver(e) {
        if (e.preventDefault) {
            e.preventDefault();
        }
        e.dataTransfer.dropEffect = 'move';
        return false;
    }

    async function handleDrop(e) {
        if (e.stopPropagation) {
            e.stopPropagation();
        }
        e.preventDefault();

        if (draggedTask) {
            const taskId = parseInt(draggedTask.dataset.id);
            const newStatus = e.currentTarget.dataset.status;

            try {
                const response = await fetch(`${API_TASKS}?id=${taskId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                    body: JSON.stringify({ trangThai: newStatus })
                });

                if (response.ok) {
                    await loadTasks();
                } else {
                    alert('Lỗi cập nhật trạng thái');
                }
            } catch (error) {
                console.error('Lỗi:', error);
                alert('Lỗi cập nhật trạng thái');
            }
        }

        return false;
    }

    // ==========================================
    // CALENDAR VIEW
    // ==========================================
    function renderCalendarView() {
        updateCalendarTitle();

        const firstDay = new Date(currentYear, currentMonth, 1);
        const lastDay = new Date(currentYear, currentMonth + 1, 0);
        const prevLastDay = new Date(currentYear, currentMonth, 0);

        const firstDayIndex = firstDay.getDay();
        const lastDayDate = lastDay.getDate();
        const prevLastDayDate = prevLastDay.getDate();
        const nextDays = 7 - lastDay.getDay() - 1;

        const calendarDays = document.getElementById('calendarDays');
        let html = '';

        // Previous month days
        for (let x = firstDayIndex; x > 0; x--) {
            html += `<div class="calendar-day other-month">
            <div class="calendar-day-number">${prevLastDayDate - x + 1}</div>
        </div>`;
        }

        // Current month days
        const today = new Date();
        for (let i = 1; i <= lastDayDate; i++) {
            const isToday = i === today.getDate() &&
                currentMonth === today.getMonth() &&
                currentYear === today.getFullYear();

            const dayTasks = getTasksForDate(i, currentMonth, currentYear);

            html += `<div class="calendar-day ${isToday ? 'today' : ''}">
            <div class="calendar-day-number">${i}</div>
            ${dayTasks.map(task => `
                <div class="calendar-task status-${task.trangThai}" onclick="editTask(${task.id})">
                    ${escapeHtml(task.ten)}
                </div>
            `).join('')}
        </div>`;
        }

        // Next month days
        for (let j = 1; j <= nextDays; j++) {
            html += `<div class="calendar-day other-month">
            <div class="calendar-day-number">${j}</div>
        </div>`;
        }

        calendarDays.innerHTML = html;
    }

    function getTasksForDate(day, month, year) {
        return tasks.filter(task => {
            if (!task.ngayKetThuc) return false;
            const taskDate = new Date(task.ngayKetThuc);
            return taskDate.getDate() === day &&
                taskDate.getMonth() === month &&
                taskDate.getFullYear() === year;
        });
    }

    function updateCalendarTitle() {
        const monthNames = ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
            'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
        document.getElementById('calendarTitle').textContent =
            `${monthNames[currentMonth]}, ${currentYear}`;
    }

    function changeMonth(delta) {
        currentMonth += delta;
        if (currentMonth > 11) {
            currentMonth = 0;
            currentYear++;
        } else if (currentMonth < 0) {
            currentMonth = 11;
            currentYear--;
        }
        renderCalendarView();
    }

    function goToToday() {
        const today = new Date();
        currentMonth = today.getMonth();
        currentYear = today.getFullYear();
        renderCalendarView();
    }

    // ==========================================
    // MODAL NHIỆM VỤ
    // ==========================================
    function showAddTaskModal() {
        document.getElementById('taskModalTitle').textContent = 'Thêm nhiệm vụ mới';
        document.getElementById('taskForm').reset();
        document.getElementById('taskId').value = '';
        document.getElementById('taskModal').classList.add('active');
    }

    function closeTaskModal() {
        document.getElementById('taskModal').classList.remove('active');
    }

    function editTask(taskId) {
        const task = tasks.find(t => t.id === taskId);
        if (!task) return;

        document.getElementById('taskModalTitle').textContent = 'Chỉnh sửa nhiệm vụ';
        document.getElementById('taskId').value = task.id;
        document.getElementById('taskName').value = task.ten;
        document.getElementById('taskDescription').value = task.mo_ta || '';
        document.getElementById('taskProject').value = task.duAnId || '';
        document.getElementById('taskStatus').value = task.trangThai;
        document.getElementById('taskPriority').value = task.doUuTien;
        document.getElementById('taskStartDate').value = formatDateForInput(task.ngayBatDau);
        document.getElementById('taskEndDate').value = formatDateForInput(task.ngayKetThuc);
        document.getElementById('taskNote').value = task.ghiChu || '';

        document.getElementById('taskModal').classList.add('active');
    }

    async function saveTask() {
        const taskId = document.getElementById('taskId').value;
        const taskData = {
            ten: document.getElementById('taskName').value.trim(),
            mo_ta: document.getElementById('taskDescription').value.trim(),
            duAnId: document.getElementById('taskProject').value || null,
            trangThai: document.getElementById('taskStatus').value,
            doUuTien: parseInt(document.getElementById('taskPriority').value),
            ngayBatDau: document.getElementById('taskStartDate').value || null,
            ngayKetThuc: document.getElementById('taskEndDate').value || null,
            ghiChu: document.getElementById('taskNote').value.trim(),
            nguoiThucHienId: currentUser.id
        };

        if (!taskData.ten) {
            alert('Vui lòng nhập tên nhiệm vụ');
            return;
        }

        try {
            const url = taskId ? `${API_TASKS}?id=${taskId}` : API_TASKS;
            const method = taskId ? 'PUT' : 'POST';

            const response = await fetch(url, {
                method: method,
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify(taskData)
            });

            if (response.ok) {
                closeTaskModal();
                await loadTasks();
            } else {
                const error = await response.json();
                alert('Lỗi: ' + (error.error || 'Không thể lưu nhiệm vụ'));
            }
        } catch (error) {
            console.error('Lỗi:', error);
            alert('Lỗi kết nối server');
        }
    }

    async function deleteTask(taskId) {
        if (!confirm('Bạn có chắc muốn xóa nhiệm vụ này?')) return;

        try {
            const response = await fetch(`${API_TASKS}?id=${taskId}`, {
                method: 'DELETE'
            });

            if (response.ok) {
                await loadTasks();
            } else {
                alert('Lỗi xóa nhiệm vụ');
            }
        } catch (error) {
            console.error('Lỗi:', error);
            alert('Lỗi kết nối server');
        }
    }

    // ==========================================
    // MODAL DỰ ÁN
    // ==========================================
    function showAddProjectModal() {
        document.getElementById('projectModalTitle').textContent = 'Thêm dự án mới';
        document.getElementById('projectForm').reset();
        document.getElementById('projectId').value = '';
        document.getElementById('projectModal').classList.add('active');
    }

    function closeProjectModal() {
        document.getElementById('projectModal').classList.remove('active');
    }

    async function saveProject() {
        const projectId = document.getElementById('projectId').value;
        const projectData = {
            ten: document.getElementById('projectName').value.trim(),
            mo_ta: document.getElementById('projectDescription').value.trim(),
            nguoiThucHien: document.getElementById('projectAssignee').value.trim(),
            ngayBatDau: document.getElementById('projectStartDate').value || null,
            ngayKetThuc: document.getElementById('projectEndDate').value || null,
            mauSac: document.getElementById('projectColor').value,
            ghiChu: document.getElementById('projectNote').value.trim(),
            trangThai: 'active'
        };

        if (!projectData.ten) {
            alert('Vui lòng nhập tên dự án');
            return;
        }

        try {
            const url = projectId ? `${API_PROJECTS}?id=${projectId}` : API_PROJECTS;
            const method = projectId ? 'PUT' : 'POST';

            const response = await fetch(url, {
                method: method,
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify(projectData)
            });

            if (response.ok) {
                closeProjectModal();
                await loadProjects();
                await loadTasks();
            } else {
                const error = await response.json();
                alert('Lỗi: ' + (error.error || 'Không thể lưu dự án'));
            }
        } catch (error) {
            console.error('Lỗi:', error);
            alert('Lỗi kết nối server');
        }
    }

    // ==========================================
    // UTILITY FUNCTIONS
    // ==========================================
    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    function formatDate(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        const day = String(date.getDate()).padStart(2, '0');
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const year = date.getFullYear();
        return `${day}/${month}/${year}`;
    }

    function formatDateForInput(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    function getStatusBadge(status) {
        const statusMap = {
            'todo': { label: 'Chưa làm', class: 'badge-todo' },
            'inprogress': { label: 'Đang làm', class: 'badge-inprogress' },
            'done': { label: 'Đã xong', class: 'badge-done' }
        };
        const s = statusMap[status] || statusMap['todo'];
        return `<span class="badge ${s.class}">${s.label}</span>`;
    }

    function getPriorityBadge(priority) {
        const level = getPriorityLevel(priority);
        const priorityMap = {
            'high': { label: 'Cao', class: 'badge-priority-high', icon: '🔴' },
            'medium': { label: 'TB', class: 'badge-priority-medium', icon: '🟡' },
            'low': { label: 'Thấp', class: 'badge-priority-low', icon: '🟢' }
        };
        const p = priorityMap[level];
        return `<span class="badge ${p.class}">${p.icon} ${p.label}</span>`;
    }
</script>
</body>
</html>