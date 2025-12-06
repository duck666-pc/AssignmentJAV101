<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- ✅ FIX 1: Thêm i18n support --%>
<c:set var="lang" value="${param.lang != null ? param.lang : pageContext.request.locale}" />
<fmt:setLocale value="${lang}" />
<fmt:setBundle basename="messages" />

<%-- Kiểm tra đăng nhập --%>
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/dangnhap.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="${lang}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="app.title"/> - Minimalist</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        /* ======= GIỮ NGUYÊN TOÀN BỘ CSS ======= */
        body {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .main-container {
            flex: 1;
            max-width: 1400px;
            width: 100%;
            margin: 0 auto;
            padding: var(--spacing-lg);
        }

        /* ✅ FIX 2: Thêm style cho language selector */
        .lang-selector {
            display: flex;
            gap: var(--spacing-xs);
            align-items: center;
        }

        .lang-btn {
            padding: 4px 8px;
            border: 1px solid var(--border-color);
            background: transparent;
            color: var(--text-secondary);
            font-size: var(--font-size-xs);
            cursor: pointer;
            border-radius: var(--radius-sm);
            transition: all var(--transition-fast);
        }

        .lang-btn.active {
            background: var(--color-black);
            color: var(--color-white);
            border-color: var(--color-black);
        }

        [data-theme="dark"] .lang-btn.active {
            background: var(--color-white);
            color: var(--color-black);
            border-color: var(--color-white);
        }

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
            font-size: var(--font-size-xs);
            font-weight: var(--font-weight-medium);
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            white-space: nowrap;
        }

        .filter-select {
            min-width: 160px;
        }

        .view-modes {
            display: flex;
            gap: 0;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            overflow: hidden;
        }

        .view-btn {
            padding: var(--spacing-sm) var(--spacing-md);
            border: none;
            background: transparent;
            color: var(--text-secondary);
            font-size: var(--font-size-xs);
            font-weight: var(--font-weight-medium);
            cursor: pointer;
            transition: all var(--transition-fast);
            border-right: 1px solid var(--border-color);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .view-btn:last-child {
            border-right: none;
        }

        .view-btn:hover {
            background: var(--hover-bg);
            color: var(--text-primary);
        }

        .view-btn.active {
            background: var(--color-black);
            color: var(--color-white);
        }

        [data-theme="dark"] .view-btn.active {
            background: var(--color-white);
            color: var(--color-black);
        }

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
            border-color: var(--text-primary);
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .task-card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: var(--spacing-md);
        }

        .task-title {
            font-size: var(--font-size-lg);
            font-weight: var(--font-weight-semibold);
            color: var(--text-primary);
            margin-bottom: var(--spacing-sm);
            letter-spacing: -0.01em;
        }

        .task-meta {
            display: flex;
            gap: var(--spacing-sm);
            align-items: center;
            flex-wrap: wrap;
        }

        /* ✅ FIX 3: Style cho tag badges */
        .tag-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 2px 8px;
            border: 1px solid;
            border-radius: var(--radius-full);
            font-size: 10px;
            font-weight: var(--font-weight-medium);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            white-space: nowrap;
        }

        .task-description {
            font-size: var(--font-size-sm);
            color: var(--text-secondary);
            margin-bottom: var(--spacing-md);
            line-height: var(--line-height-relaxed);
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
            font-size: var(--font-size-xs);
            color: var(--text-secondary);
        }

        .task-actions {
            display: flex;
            gap: var(--spacing-sm);
        }

        .kanban-view {
            display: none;
        }

        .kanban-view.active {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
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
            border-bottom: 1px solid var(--border-color);
        }

        .kanban-title {
            font-size: var(--font-size-sm);
            font-weight: var(--font-weight-semibold);
            color: var(--text-primary);
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .kanban-count {
            background: var(--bg-secondary);
            color: var(--text-secondary);
            padding: 2px 8px;
            border-radius: var(--radius-full);
            font-size: var(--font-size-xs);
            font-weight: var(--font-weight-bold);
            border: 1px solid var(--border-color);
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
            border-color: var(--text-primary);
            transform: translateY(-2px);
            box-shadow: var(--shadow-sm);
        }

        .kanban-task.dragging {
            opacity: 0.5;
            transform: rotate(2deg);
        }

        .kanban-task.drag-over {
            border: 2px solid var(--text-primary);
        }

        .kanban-task-title {
            font-size: var(--font-size-sm);
            font-weight: var(--font-weight-semibold);
            color: var(--text-primary);
            margin-bottom: var(--spacing-sm);
        }

        .kanban-task-meta {
            display: flex;
            gap: var(--spacing-sm);
            align-items: center;
            margin-top: var(--spacing-sm);
            flex-wrap: wrap;
        }

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

        .calendar-title {
            font-size: var(--font-size-xl);
            font-weight: var(--font-weight-semibold);
            color: var(--text-primary);
            min-width: 240px;
            text-align: center;
            letter-spacing: -0.02em;
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
            font-size: var(--font-size-xs);
            font-weight: var(--font-weight-semibold);
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.05em;
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
            opacity: 0.3;
        }

        .calendar-day.today {
            background: var(--bg-secondary);
        }

        .calendar-day-number {
            font-size: var(--font-size-sm);
            font-weight: var(--font-weight-semibold);
            color: var(--text-primary);
            margin-bottom: var(--spacing-sm);
        }

        .calendar-day.today .calendar-day-number {
            background: var(--color-black);
            color: var(--color-white);
            width: 28px;
            height: 28px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: var(--radius-full);
        }

        [data-theme="dark"] .calendar-day.today .calendar-day-number {
            background: var(--color-white);
            color: var(--color-black);
        }

        .calendar-task {
            background: var(--bg-secondary);
            border-left: 2px solid var(--color-black);
            padding: 4px 8px;
            margin-bottom: 4px;
            border-radius: var(--radius-sm);
            font-size: var(--font-size-xs);
            cursor: pointer;
            transition: all var(--transition-fast);
            line-height: var(--line-height-tight);
        }

        .calendar-task:hover {
            transform: translateX(4px);
            box-shadow: var(--shadow-sm);
        }

        .calendar-task.status-inprogress {
            border-left-color: var(--color-gray-600);
        }

        .calendar-task.status-done {
            border-left-color: var(--color-gray-400);
            opacity: 0.6;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: var(--spacing-md);
            margin-bottom: var(--spacing-lg);
        }

        .stat-card {
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: var(--spacing-lg);
            transition: all var(--transition-fast);
        }

        .stat-card:hover {
            border-color: var(--text-primary);
            transform: translateY(-2px);
        }

        .stat-value {
            font-size: var(--font-size-3xl);
            font-weight: var(--font-weight-bold);
            color: var(--text-primary);
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

            .filter-group {
                flex-direction: column;
                align-items: stretch;
            }

            .filter-select {
                width: 100%;
                min-width: auto;
            }

            .view-modes {
                width: 100%;
            }

            .view-btn {
                flex: 1;
            }

            .calendar-day {
                min-height: 80px;
            }

            .calendar-title {
                font-size: var(--font-size-lg);
                min-width: auto;
            }

            .task-footer {
                flex-direction: column;
                gap: var(--spacing-md);
                align-items: flex-start;
            }

            .task-actions {
                width: 100%;
            }

            .task-actions .btn {
                flex: 1;
            }
        }
    </style>
</head>
<body>
<!-- HEADER -->
<div class="header">
    <div class="header-content">
        <div class="header-brand">
            <span class="logo">□</span>
            <h1><fmt:message key="app.title"/></h1>
        </div>
        <div class="header-actions">
            <%-- ✅ FIX 4: Thêm language selector --%>
            <div class="lang-selector">
                <button class="lang-btn ${param.lang == 'vi' || empty param.lang ? 'active' : ''}"
                        onclick="changeLanguage('vi')">VI</button>
                <button class="lang-btn ${param.lang == 'en' ? 'active' : ''}"
                        onclick="changeLanguage('en')">EN</button>
            </div>
            <button class="btn-icon" onclick="setTheme('light')" title="Light Mode">○</button>
            <button class="btn-icon" onclick="setTheme('dark')" title="Dark Mode">●</button>
            <div class="user-section">
                <div class="user-avatar" onclick="location.href='${pageContext.request.contextPath}/taikhoan.jsp'">
                    <c:out value="${fn:substring(sessionScope.user.ten, 0, 1)}" />
                </div>
                <div class="user-info">
                    <div class="user-name"><c:out value="${sessionScope.user.ten}" /></div>
                    <div class="user-role"><c:out value="${sessionScope.user.vaiTro}" /></div>
                </div>
            </div>
            <form action="${pageContext.request.contextPath}/auth?action=logout" method="post" style="margin: 0;">
                <button type="submit" class="btn btn-secondary"><fmt:message key="home.logout"/></button>
            </form>
        </div>
    </div>
</div>

<!-- MAIN CONTAINER -->
<div class="main-container">
    <!-- STATS GRID -->
    <div class="stats-grid" id="statsGrid"></div>

    <!-- TOOLBAR -->
    <div class="toolbar">
        <div class="toolbar-section grow">
            <div class="filter-group">
                <label class="filter-label"><fmt:message key="home.project"/></label>
                <select class="filter-select form-select" id="projectFilter" onchange="loadTasks()">
                    <option value=""><fmt:message key="home.all"/></option>
                </select>
            </div>
            <div class="filter-group">
                <label class="filter-label"><fmt:message key="task.status"/></label>
                <select class="filter-select form-select" id="statusFilter" onchange="loadTasks()">
                    <option value=""><fmt:message key="home.all"/></option>
                    <option value="todo"><fmt:message key="status.todo"/></option>
                    <option value="inprogress"><fmt:message key="status.inprogress"/></option>
                    <option value="done"><fmt:message key="status.done"/></option>
                </select>
            </div>
            <div class="filter-group">
                <label class="filter-label"><fmt:message key="home.priority"/></label>
                <select class="filter-select form-select" id="priorityFilter" onchange="loadTasks()">
                    <option value=""><fmt:message key="home.all"/></option>
                    <option value="high"><fmt:message key="home.priority_high"/></option>
                    <option value="medium"><fmt:message key="home.priority_medium"/></option>
                    <option value="low"><fmt:message key="home.priority_low"/></option>
                </select>
            </div>
            <%-- ✅ FIX 5: Thêm Tag Filter --%>
            <div class="filter-group">
                <label class="filter-label">TAG</label>
                <select class="filter-select form-select" id="tagFilter" onchange="loadTasks()">
                    <option value="">All Tags</option>
                </select>
            </div>
        </div>

        <div class="toolbar-section">
            <div class="view-modes">
                <button class="view-btn active" onclick="changeView('list')"><fmt:message key="view.list"/></button>
                <button class="view-btn" onclick="changeView('kanban')"><fmt:message key="view.kanban"/></button>
                <button class="view-btn" onclick="changeView('calendar')"><fmt:message key="view.calendar"/></button>
            </div>
        </div>

        <div class="toolbar-section">
            <button class="btn btn-primary" onclick="showAddTaskModal()">+ <fmt:message key="home.add_task"/></button>
            <button class="btn btn-secondary" onclick="showAddProjectModal()">+ <fmt:message key="home.add_project"/></button>
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
                    <fmt:message key="status.todo"/>
                    <span class="kanban-count" id="todoCount">0</span>
                </div>
            </div>
            <div class="kanban-tasks" id="todoTasks" data-status="todo"></div>
        </div>

        <div class="kanban-column">
            <div class="kanban-header">
                <div class="kanban-title">
                    <fmt:message key="status.inprogress"/>
                    <span class="kanban-count" id="inprogressCount">0</span>
                </div>
            </div>
            <div class="kanban-tasks" id="inprogressTasks" data-status="inprogress"></div>
        </div>

        <div class="kanban-column">
            <div class="kanban-header">
                <div class="kanban-title">
                    <fmt:message key="status.done"/>
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
                <button class="btn-icon" onclick="changeMonth(-1)">‹</button>
                <div class="calendar-title" id="calendarTitle">January 2025</div>
                <button class="btn-icon" onclick="changeMonth(1)">›</button>
            </div>
            <button class="btn btn-secondary" onclick="goToToday()">Today</button>
        </div>
        <div class="calendar-grid">
            <div class="calendar-weekdays">
                <div class="calendar-weekday">Sun</div>
                <div class="calendar-weekday">Mon</div>
                <div class="calendar-weekday">Tue</div>
                <div class="calendar-weekday">Wed</div>
                <div class="calendar-weekday">Thu</div>
                <div class="calendar-weekday">Fri</div>
                <div class="calendar-weekday">Sat</div>
            </div>
            <div class="calendar-days" id="calendarDays"></div>
        </div>
    </div>
</div>

<!-- MODAL NHIỆM VỤ -->
<div class="modal" id="taskModal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 class="modal-title" id="taskModalTitle">New Task</h2>
            <button class="modal-close" onclick="closeTaskModal()">×</button>
        </div>
        <div class="modal-body">
            <form id="taskForm">
                <input type="hidden" id="taskId">

                <div class="form-group">
                    <label class="form-label" for="taskName"><fmt:message key="task.title"/> *</label>
                    <input type="text" class="form-input" id="taskName" required placeholder="Enter task name">
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskDescription">Description</label>
                    <textarea class="form-textarea" id="taskDescription" rows="3" placeholder="Task description"></textarea>
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskProject"><fmt:message key="task.project"/></label>
                    <select class="form-select" id="taskProject">
                        <option value="">No Project</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskStatus"><fmt:message key="task.status"/></label>
                    <select class="form-select" id="taskStatus">
                        <option value="todo"><fmt:message key="status.todo"/></option>
                        <option value="inprogress"><fmt:message key="status.inprogress"/></option>
                        <option value="done"><fmt:message key="status.done"/></option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskPriority"><fmt:message key="task.priority"/></label>
                    <select class="form-select" id="taskPriority">
                        <option value="1">Very Low</option>
                        <option value="2">Low</option>
                        <option value="3" selected>Medium</option>
                        <option value="4">High</option>
                        <option value="5">Very High</option>
                    </select>
                </div>

                <%-- ✅ FIX 6: Thêm Tag selector trong task form --%>
                <div class="form-group">
                    <label class="form-label">Tags</label>
                    <div id="taskTagsContainer" style="display: flex; gap: 8px; flex-wrap: wrap;"></div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskStartDate"><fmt:message key="task.start_date"/></label>
                    <input type="date" class="form-input" id="taskStartDate">
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskEndDate"><fmt:message key="task.end_date"/></label>
                    <input type="date" class="form-input" id="taskEndDate">
                </div>

                <div class="form-group">
                    <label class="form-label" for="taskNote"><fmt:message key="task.note"/></label>
                    <textarea class="form-textarea" id="taskNote" rows="2" placeholder="Additional notes"></textarea>
                </div>
            </form>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeTaskModal()"><fmt:message key="task.cancel"/></button>
            <button class="btn btn-primary" onclick="saveTask()"><fmt:message key="task.save"/></button>
        </div>
    </div>
</div>

<!-- MODAL DỰ ÁN -->
<div class="modal" id="projectModal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 class="modal-title" id="projectModalTitle">New Project</h2>
            <button class="modal-close" onclick="closeProjectModal()">×</button>
        </div>
        <div class="modal-body">
            <form id="projectForm">
                <input type="hidden" id="projectId">

                <div class="form-group">
                    <label class="form-label" for="projectName">Project Name *</label>
                    <input type="text" class="form-input" id="projectName" required placeholder="Enter project name">
                </div>

                <div class="form-group">
                    <label class="form-label" for="projectDescription">Description</label>
                    <textarea class="form-textarea" id="projectDescription" rows="3" placeholder="Project description"></textarea>
                </div>

                <div class="form-group">
                    <label class="form-label" for="projectAssignee">Assignee</label>
                    <input type="text" class="form-input" id="projectAssignee" value="<c:out value='${sessionScope.user.ten}' />" placeholder="Assignee name">
                </div>

                <div class="form-group">
                    <label class="form-label" for="projectStartDate">Start Date</label>
                    <input type="date" class="form-input" id="projectStartDate">
                </div>

                <div class="form-group">
                    <label class="form-label" for="projectEndDate">End Date</label>
                    <input type="date" class="form-input" id="projectEndDate">
                </div>

                <div class="form-group">
                    <label class="form-label" for="projectNote">Notes</label>
                    <textarea class="form-textarea" id="projectNote" rows="2" placeholder="Additional notes"></textarea>
                </div>
            </form>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeProjectModal()">Cancel</button>
            <button class="btn btn-primary" onclick="saveProject()">Save Project</button>
        </div>
    </div>
</div>

<script>
    // ==========================================
    // CONFIGURATION
    // ==========================================
    const API_BASE = '${pageContext.request.contextPath}';
    const API_TASKS = API_BASE + '/nhiemvu';
    const API_PROJECTS = API_BASE + '/duan';
    const API_TAGS = API_BASE + '/tag'; // ✅ FIX 7: Thêm API tag

    let currentUser = {
        id: ${sessionScope.user.id},
        ten: '<c:out value="${sessionScope.user.ten}" />',
        email: '<c:out value="${sessionScope.user.email}" />',
        vaiTro: '<c:out value="${sessionScope.user.vaiTro}" />'
    };

    let tasks = [];
    let projects = [];
    let allTags = []; // ✅ FIX 8: Thêm biến lưu tags
    let currentView = 'list';
    let currentMonth = new Date().getMonth();
    let currentYear = new Date().getFullYear();

    // ==========================================
    // INITIALIZATION
    // ==========================================
    document.addEventListener('DOMContentLoaded', () => {
        loadTheme();
        loadTags(); // ✅ FIX 9: Load tags trước
        loadProjects();
        loadTasks();
    });

    // ==========================================
    // ✅ FIX 10: Thêm hàm changeLanguage
    // ==========================================
    function changeLanguage(lang) {
        const url = new URL(window.location.href);
        url.searchParams.set('lang', lang);
        window.location.href = url.toString();
    }

    // ==========================================
    // THEME MANAGEMENT
    // ==========================================
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

    // ==========================================
    // ✅ FIX 11: Thêm hàm loadTags
    // ==========================================
    async function loadTags() {
        try {
            const response = await fetch(API_TAGS);
            if (response.ok) {
                allTags = await response.json();
                updateTagFilter();
                updateTaskTagsCheckboxes();
            }
        } catch (error) {
            console.error('Error loading tags:', error);
        }
    }

    function updateTagFilter() {
        const select = document.getElementById('tagFilter');
        const currentValue = select.value;

        const options = allTags.map(tag =>
            '<option value="' + tag.id + '">' + escapeHtml(tag.ten) + '</option>'
        ).join('');

        select.innerHTML = '<option value="">All Tags</option>' + options;

        if (currentValue) select.value = currentValue;
    }

    function updateTaskTagsCheckboxes() {
        const container = document.getElementById('taskTagsContainer');
        if (!container) return;

        container.innerHTML = allTags.map(tag =>
            '<label style="display: flex; align-items: center; gap: 4px; cursor: pointer;">' +
            '<input type="checkbox" class="tag-checkbox" data-tag-id="' + tag.id + '" ' +
            'style="width: 16px; height: 16px;">' +
            '<span style="font-size: 12px;">' + escapeHtml(tag.ten) + '</span>' +
            '</label>'
        ).join('');
    }

    // ==========================================
    // DATA LOADING
    // ==========================================
    async function loadProjects() {
        try {
            const response = await fetch(API_PROJECTS);
            if (response.ok) {
                projects = await response.json();
                updateProjectSelects();
            }
        } catch (error) {
            console.error('Error loading projects:', error);
        }
    }

    async function loadTasks() {
        try {
            const projectId = document.getElementById('projectFilter').value;
            const status = document.getElementById('statusFilter').value;
            const tagId = document.getElementById('tagFilter').value; // ✅ FIX 12: Lấy tag filter

            let url = API_TASKS;
            const params = new URLSearchParams();
            if (projectId) params.append('duAnId', projectId);
            if (status) params.append('trangThai', status);
            if (tagId) params.append('tagId', tagId); // ✅ FIX 13: Thêm tag param
            if (params.toString()) url += '?' + params.toString();

            const response = await fetch(url);
            if (response.ok) {
                tasks = await response.json();
                updateStats();
                renderCurrentView();
            }
        } catch (error) {
            console.error('Error loading tasks:', error);
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
                '<option value="' + p.id + '">' + escapeHtml(p.ten) + '</option>'
            ).join('');

            if (index === 0) {
                select.innerHTML = '<option value="">All Projects</option>' + options;
            } else {
                select.innerHTML = '<option value="">No Project</option>' + options;
            }

            if (currentValue) select.value = currentValue;
        });
    }

    function updateStats() {
        const total = tasks.length;
        const todo = tasks.filter(t => t.trangThai === 'todo').length;
        const inprogress = tasks.filter(t => t.trangThai === 'inprogress').length;
        const done = tasks.filter(t => t.trangThai === 'done').length;

        const statsHtml = '<div class="stat-card">' +
            '<div class="stat-value">' + total + '</div>' +
            '<div class="stat-label">Total Tasks</div>' +
            '</div>' +
            '<div class="stat-card">' +
            '<div class="stat-value">' + todo + '</div>' +
            '<div class="stat-label">To Do</div>' +
            '</div>' +
            '<div class="stat-card">' +
            '<div class="stat-value">' + inprogress + '</div>' +
            '<div class="stat-label">In Progress</div>' +
            '</div>' +
            '<div class="stat-card">' +
            '<div class="stat-value">' + done + '</div>' +
            '<div class="stat-label">Completed</div>' +
            '</div>';

        document.getElementById('statsGrid').innerHTML = statsHtml;
    }

    // ==========================================
    // VIEW MANAGEMENT
    // ==========================================
    function changeView(view) {
        currentView = view;

        document.querySelectorAll('.view-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        event.target.classList.add('active');

        document.getElementById('listView').classList.remove('active');
        document.getElementById('kanbanView').classList.remove('active');
        document.getElementById('calendarView').classList.remove('active');

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
    // ✅ FIX 14: Cập nhật renderListView để hiển thị tags
    // ==========================================
    function renderListView(taskList) {
        const container = document.getElementById('taskList');

        if (taskList.length === 0) {
            container.innerHTML = '<div class="empty-state">' +
                '<div class="empty-state-icon">□</div>' +
                '<h3 class="empty-state-title">No Tasks</h3>' +
                '<p class="empty-state-text">Create your first task to get started</p>' +
                '<button class="btn btn-primary" onclick="showAddTaskModal()">+ New Task</button>' +
                '</div>';
            return;
        }

        container.innerHTML = taskList.map(task => {
            let html = '<div class="task-card" onclick="editTask(' + task.id + ')">' +
                '<div class="task-card-header">' +
                '<div>' +
                '<h3 class="task-title">' + escapeHtml(task.ten) + '</h3>' +
                '<div class="task-meta">' +
                getStatusBadge(task.trangThai) +
                getPriorityBadge(task.doUuTien);

            if (task.duAnTen) {
                html += '<span class="badge">' + escapeHtml(task.duAnTen) + '</span>';
            }

            // ✅ FIX 15: Hiển thị tags
            if (task.tags && task.tags.length > 0) {
                task.tags.forEach(tag => {
                    html += '<span class="tag-badge" style="border-color: ' + tag.mauSac + '; color: ' + tag.mauSac + ';">' +
                        escapeHtml(tag.ten) +
                        '</span>';
                });
            }

            html += '</div></div></div>';

            if (task.mo_ta) {
                html += '<div class="task-description">' + escapeHtml(task.mo_ta) + '</div>';
            }

            html += '<div class="task-footer">' +
                '<div class="task-dates">';

            if (task.ngayBatDau) {
                html += '<span>Start: ' + formatDate(task.ngayBatDau) + '</span>';
            }
            if (task.ngayKetThuc) {
                html += '<span>Due: ' + formatDate(task.ngayKetThuc) + '</span>';
            }

            html += '</div>' +
                '<div class="task-actions" onclick="event.stopPropagation()">' +
                '<button class="btn btn-sm btn-secondary" onclick="editTask(' + task.id + ')">Edit</button>' +
                '<button class="btn btn-sm btn-danger" onclick="deleteTask(' + task.id + ')">Delete</button>' +
                '</div></div></div>';

            return html;
        }).join('');
    }

    // ==========================================
    // KANBAN VIEW RENDERING
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
            container.innerHTML = '<div class="empty-state-text">No tasks</div>';
            return;
        }

        container.innerHTML = taskList.map(task => {
            let html = '<div class="kanban-task" draggable="true" data-id="' + task.id + '"' +
                ' ondragstart="handleDragStart(event)"' +
                ' ondragend="handleDragEnd(event)"' +
                ' onclick="editTask(' + task.id + ')">' +
                '<div class="kanban-task-title">' + escapeHtml(task.ten) + '</div>';

            if (task.mo_ta) {
                html += '<div class="task-description">' + escapeHtml(task.mo_ta) + '</div>';
            }

            html += '<div class="kanban-task-meta">' +
                getPriorityBadge(task.doUuTien);

            if (task.ngayKetThuc) {
                html += '<span class="badge">Due: ' + formatDate(task.ngayKetThuc) + '</span>';
            }

            // ✅ FIX 16: Hiển thị tags trong kanban
            if (task.tags && task.tags.length > 0) {
                task.tags.forEach(tag => {
                    html += '<span class="tag-badge" style="border-color: ' + tag.mauSac + '; color: ' + tag.mauSac + ';">' +
                        escapeHtml(tag.ten) +
                        '</span>';
                });
            }

            html += '</div></div>';

            return html;
        }).join('');

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
                const response = await fetch(API_TASKS + '?id=' + taskId, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                    body: JSON.stringify({ trangThai: newStatus })
                });

                if (response.ok) {
                    await loadTasks();
                } else {
                    alert('Error updating status');
                }
            } catch (error) {
                console.error('Error:', error);
                alert('Error updating status');
            }
        }

        return false;
    }

    // ==========================================
    // CALENDAR VIEW RENDERING
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

        for (let x = firstDayIndex; x > 0; x--) {
            html += '<div class="calendar-day other-month">' +
                '<div class="calendar-day-number">' + (prevLastDayDate - x + 1) + '</div>' +
                '</div>';
        }

        const today = new Date();
        for (let i = 1; i <= lastDayDate; i++) {
            const isToday = i === today.getDate() &&
                currentMonth === today.getMonth() &&
                currentYear === today.getFullYear();

            const dayTasks = getTasksForDate(i, currentMonth, currentYear);

            html += '<div class="calendar-day ' + (isToday ? 'today' : '') + '">' +
                '<div class="calendar-day-number">' + i + '</div>';

            dayTasks.forEach(task => {
                html += '<div class="calendar-task status-' + task.trangThai + '" onclick="editTask(' + task.id + ')">' +
                    escapeHtml(task.ten) +
                    '</div>';
            });

            html += '</div>';
        }

        for (let j = 1; j <= nextDays; j++) {
            html += '<div class="calendar-day other-month">' +
                '<div class="calendar-day-number">' + j + '</div>' +
                '</div>';
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
        const monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'];
        document.getElementById('calendarTitle').textContent =
            monthNames[currentMonth] + ' ' + currentYear;
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
    // TASK MODAL
    // ==========================================
    function showAddTaskModal() {
        document.getElementById('taskModalTitle').textContent = 'New Task';
        document.getElementById('taskForm').reset();
        document.getElementById('taskId').value = '';
        updateTaskTagsCheckboxes();
        document.getElementById('taskModal').classList.add('active');
    }

    function closeTaskModal() {
        document.getElementById('taskModal').classList.remove('active');
    }

    async function editTask(taskId) {
        const task = tasks.find(t => t.id === taskId);
        if (!task) return;

        document.getElementById('taskModalTitle').textContent = 'Edit Task';
        document.getElementById('taskId').value = task.id;
        document.getElementById('taskName').value = task.ten || '';
        document.getElementById('taskDescription').value = task.mo_ta || '';
        document.getElementById('taskProject').value = task.duAnId || '';
        document.getElementById('taskStatus').value = task.trangThai || 'todo';
        document.getElementById('taskPriority').value = task.doUuTien || 3;
        document.getElementById('taskStartDate').value = formatDateForInput(task.ngayBatDau);
        document.getElementById('taskEndDate').value = formatDateForInput(task.ngayKetThuc);
        document.getElementById('taskNote').value = task.ghiChu || '';

        // ✅ FIX 17: Cập nhật tag checkboxes
        updateTaskTagsCheckboxes();
        if (task.tags && task.tags.length > 0) {
            task.tags.forEach(tag => {
                const checkbox = document.querySelector('.tag-checkbox[data-tag-id="' + tag.id + '"]');
                if (checkbox) checkbox.checked = true;
            });
        }

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
            alert('Please enter task name');
            return;
        }

        try {
            const url = taskId ? (API_TASKS + '?id=' + taskId) : API_TASKS;
            const method = taskId ? 'PUT' : 'POST';

            const response = await fetch(url, {
                method: method,
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify(taskData)
            });

            if (response.ok) {
                const savedTask = await response.json();

                // ✅ FIX 18: Lưu tags sau khi lưu task
                await saveTaskTags(savedTask.id || taskId);

                closeTaskModal();
                await loadTasks();
            } else {
                const error = await response.json();
                alert('Error: ' + (error.error || 'Cannot save task'));
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Server connection error');
        }
    }

    // ✅ FIX 19: Thêm hàm saveTaskTags
    async function saveTaskTags(taskId) {
        const checkboxes = document.querySelectorAll('.tag-checkbox:checked');
        const selectedTagIds = Array.from(checkboxes).map(cb => cb.dataset.tagId);

        // Xóa tất cả tags cũ và thêm tags mới
        for (const tagId of selectedTagIds) {
            try {
                await fetch(API_TAGS + '?action=addTagToTask&taskId=' + taskId + '&tagId=' + tagId, {
                    method: 'POST'
                });
            } catch (error) {
                console.error('Error adding tag:', error);
            }
        }
    }

    async function deleteTask(taskId) {
        if (!confirm('Are you sure you want to delete this task?')) return;

        try {
            const response = await fetch(API_TASKS + '?id=' + taskId, {
                method: 'DELETE'
            });

            if (response.ok) {
                await loadTasks();
            } else {
                alert('Error deleting task');
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Server connection error');
        }
    }

    // ==========================================
    // PROJECT MODAL
    // ==========================================
    function showAddProjectModal() {
        document.getElementById('projectModalTitle').textContent = 'New Project';
        document.getElementById('projectForm').reset();
        document.getElementById('projectId').value = '';
        document.getElementById('projectAssignee').value = currentUser.ten;
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
            ghiChu: document.getElementById('projectNote').value.trim(),
            trangThai: 'active'
        };

        if (!projectData.ten) {
            alert('Please enter project name');
            return;
        }

        try {
            const url = projectId ? (API_PROJECTS + '?id=' + projectId) : API_PROJECTS;
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
                alert('Error: ' + (error.error || 'Cannot save project'));
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Server connection error');
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
        return day + '/' + month + '/' + year;
    }

    function formatDateForInput(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return year + '-' + month + '-' + day;
    }

    function getStatusBadge(status) {
        const statusMap = {
            'todo': { label: 'To Do', className: 'badge-todo' },
            'inprogress': { label: 'In Progress', className: 'badge-inprogress' },
            'done': { label: 'Done', className: 'badge-done' }
        };
        const s = statusMap[status] || statusMap['todo'];
        return '<span class="badge ' + s.className + '">' + s.label + '</span>';
    }

    function getPriorityBadge(priority) {
        const level = getPriorityLevel(priority);
        const priorityMap = {
            'high': { label: 'High', className: 'badge-priority-high' },
            'medium': { label: 'Medium', className: 'badge-priority-medium' },
            'low': { label: 'Low', className: 'badge-priority-low' }
        };
        const p = priorityMap[level];
        return '<span class="badge ' + p.className + '">' + p.label + '</span>';
    }

    window.onclick = function(event) {
        const taskModal = document.getElementById('taskModal');
        const projectModal = document.getElementById('projectModal');

        if (event.target === taskModal) {
            closeTaskModal();
        }
        if (event.target === projectModal) {
            closeProjectModal();
        }
    }
</script>
</body>
</html>