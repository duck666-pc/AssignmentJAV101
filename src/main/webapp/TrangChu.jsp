<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- Kiểm tra đăng nhập --%>
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/DangNhap.jsp"/>
</c:if>

<fmt:setLocale value="${param.lang != null ? param.lang : pageContext.request.locale}"/>
<fmt:setBundle basename="messages"/>

<!DOCTYPE html>
<html lang="${pageContext.request.locale}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="home.title"/> - <fmt:message key="app.title"/></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        /* Copy toàn bộ CSS từ TrangChu.html vào đây */
        /* Để tiết kiệm không gian, tôi sẽ chỉ ghi chú */
        /* Bạn copy CSS từ TrangChu.html vào đây */
    </style>
</head>
<body>
<%-- Include header --%>
<jsp:include page="/layout/header.jsp"/>

<div class="container">
    <div class="toolbar">
        <div class="filters-group">
            <div class="project-selector">
                <label><fmt:message key="home.project"/>:</label>
                <select id="projectSelect" onchange="loadTasks()">
                    <option value=""><fmt:message key="home.all"/></option>
                </select>
            </div>
            <div class="priority-filter">
                <label><fmt:message key="home.priority"/>:</label>
                <select id="priorityFilter" onchange="loadTasks()">
                    <option value=""><fmt:message key="home.all"/></option>
                    <option value="high"><fmt:message key="home.priority_high"/></option>
                    <option value="medium"><fmt:message key="home.priority_medium"/></option>
                    <option value="low"><fmt:message key="home.priority_low"/></option>
                </select>
            </div>
        </div>

        <div class="view-modes">
            <button class="view-btn active" onclick="changeView('list')"><fmt:message key="view.list"/></button>
            <button class="view-btn" onclick="changeView('kanban')"><fmt:message key="view.kanban"/></button>
            <button class="view-btn" onclick="changeView('calendar')"><fmt:message key="view.calendar"/></button>
        </div>

        <div class="add-button-group">
            <button class="btn-add" onclick="toggleAddDropdown()"><fmt:message key="home.add_new"/></button>
            <div class="add-dropdown" id="addDropdown">
                <div class="add-dropdown-item" onclick="showAddTaskModal()"><fmt:message key="home.add_task"/></div>
                <div class="add-dropdown-item" onclick="showAddProjectModal()"><fmt:message key="home.add_project"/></div>
            </div>
        </div>
    </div>

    <div id="listView" class="list-view"></div>
    <div id="kanbanView" class="kanban-view hidden"></div>
    <div id="calendarView" class="calendar-view hidden"></div>
</div>

<%-- Modals giống TrangChu.html --%>

<%-- Include footer --%>
<jsp:include page="/layout/footer.jsp"/>

<script>
    // API endpoint
    const API_BASE = '${pageContext.request.contextPath}';
    const API_TASKS = API_BASE + '/nhiemvu';
    const API_PROJECTS = API_BASE + '/duan';

    let currentUser = {
        id: ${sessionScope.user.id},
        ten: '${sessionScope.user.ten}',
        email: '${sessionScope.user.email}',
        vaiTro: '${sessionScope.user.vaiTro}'
    };

    let currentView = 'list';
    let tasks = [];
    let projects = [];

    // Load dữ liệu từ server
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
            const projectId = document.getElementById('projectSelect').value;
            const url = new URL(API_TASKS, window.location.origin);
            if (projectId) url.searchParams.append('duAnId', projectId);

            const response = await fetch(url);
            if (response.ok) {
                tasks = await response.json();
                renderView();
            }
        } catch (error) {
            console.error('Lỗi load tasks:', error);
        }
    }

    function updateProjectSelects() {
        const selects = [document.getElementById('projectSelect'), document.getElementById('taskProject')];
        selects.forEach(select => {
            const options = projects.map(p =>
                `<option value="${p.id}">${p.ten}</option>`
            ).join('');

            if (select.id === 'projectSelect') {
                select.innerHTML = '<option value=""><fmt:message key="home.all"/></option>' + options;
            } else {
                select.innerHTML = '<option value="">Không thuộc dự án</option>' + options;
            }
        });
    }

    function renderView() {
        const priorityFilter = document.getElementById('priorityFilter').value;
        let filteredTasks = tasks;

        if (priorityFilter) {
            filteredTasks = filteredTasks.filter(t => {
                const priority = t.doUuTien >= 4 ? 'high' : t.doUuTien >= 3 ? 'medium' : 'low';
                return priority === priorityFilter;
            });
        }

        if (currentView === 'list') {
            renderListView(filteredTasks);
        } else if (currentView === 'kanban') {
            renderKanbanView(filteredTasks);
        } else if (currentView === 'calendar') {
            renderCalendarView();
        }
    }

    // Các hàm render giống TrangChu.html
    function renderListView(taskList) {
        // Copy từ TrangChu.html
    }

    // CRUD operations
    async function createTask(taskData) {
        try {
            const response = await fetch(API_TASKS, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(taskData)
            });

            if (response.ok) {
                await loadTasks();
                closeModal();
            } else {
                alert('Lỗi tạo task');
            }
        } catch (error) {
            console.error('Lỗi:', error);
        }
    }

    async function updateTask(taskId, updateData) {
        try {
            const response = await fetch(`${API_TASKS}?id=${taskId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(updateData)
            });

            if (response.ok) {
                await loadTasks();
            } else {
                alert('Lỗi cập nhật task');
            }
        } catch (error) {
            console.error('Lỗi:', error);
        }
    }

    async function deleteTask(taskId) {
        if (!confirm('Xóa nhiệm vụ này?')) return;

        try {
            const response = await fetch(`${API_TASKS}?id=${taskId}`, {
                method: 'DELETE'
            });

            if (response.ok) {
                await loadTasks();
            } else {
                alert('Lỗi xóa task');
            }
        } catch (error) {
            console.error('Lỗi:', error);
        }
    }

    // Tương tự cho projects
    async function createProject(projectData) {
        try {
            const response = await fetch(API_PROJECTS, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(projectData)
            });

            if (response.ok) {
                await loadProjects();
                closeProjectModal();
            }
        } catch (error) {
            console.error('Lỗi:', error);
        }
    }

    // Init
    document.addEventListener('DOMContentLoaded', () => {
        loadProjects();
        loadTasks();
    });

    // Copy các hàm còn lại từ TrangChu.html
</script>
</body>
</html>