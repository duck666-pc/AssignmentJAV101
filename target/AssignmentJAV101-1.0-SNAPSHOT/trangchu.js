let currentUser = null;
let currentView = 'list';
let currentMonth = new Date().getMonth();
let currentYear = new Date().getFullYear();
let tasks = [];
let projects = [];
let selectedProjectColor = '#1a1a1a';

const TASKS_KEY = 'taskManagerTasks';
const PROJECTS_KEY = 'taskManagerProjects';

// Theme handling
function toggleTheme() {
    const html = document.documentElement;
    const currentTheme = html.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';

    html.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);

    document.getElementById('themeToggle').textContent = newTheme === 'dark' ? '☀️' : '🌙';
}

// Load saved theme
function loadTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
    document.getElementById('themeToggle').textContent = savedTheme === 'dark' ? '☀️' : '🌙';
}

function checkAuth() {
    const userStr = sessionStorage.getItem('currentUser');
    if (!userStr) {
        window.location.href = 'DangNhap.html';
        return;
    }
    currentUser = JSON.parse(userStr);
    document.getElementById('userName').textContent = currentUser.ten;
    document.getElementById('userAvatar').textContent = currentUser.ten.charAt(0).toUpperCase();
}

function logout() {
    sessionStorage.removeItem('currentUser');
    window.location.href = 'DangNhap.html';
}

function initData() {
    let savedProjects = localStorage.getItem(PROJECTS_KEY);
    if (!savedProjects) {
        projects = [
            { id: 1, ten: 'Website Bán Hàng', mauSac: '#1a1a1a', nguoiThucHien: 'Admin' },
            { id: 2, ten: 'App Mobile', mauSac: '#2563eb', nguoiThucHien: 'Admin' },
            { id: 3, ten: 'Marketing', mauSac: '#7c3aed', nguoiThucHien: 'Admin' }
        ];
        localStorage.setItem(PROJECTS_KEY, JSON.stringify(projects));
    } else {
        projects = JSON.parse(savedProjects);
    }

    let savedTasks = localStorage.getItem(TASKS_KEY);
    if (!savedTasks) {
        tasks = [];
        localStorage.setItem(TASKS_KEY, JSON.stringify(tasks));
    } else {
        const allTasks = JSON.parse(savedTasks);
        // Hiển thị tất cả nhiệm vụ của người dùng hiện tại
        tasks = allTasks.filter(t =>
            t.nguoiTaoId === currentUser.id ||
            t.nguoiThucHienId === currentUser.id
        );
    }
}

function loadProjects() {
    const selects = [document.getElementById('projectSelect'), document.getElementById('taskProject')];
    selects.forEach(select => {
        const options = projects.map(p => `<option value="${p.id}">${p.ten}</option>`).join('');
        if (select.id === 'projectSelect') {
            select.innerHTML = '<option value="">Tất cả</option>' + options;
        } else {
            select.innerHTML = '<option value="">Không thuộc dự án</option>' + options;
        }
    });
}

function toggleAddDropdown() {
    const dropdown = document.getElementById('addDropdown');
    dropdown.classList.toggle('active');

    if (dropdown.classList.contains('active')) {
        setTimeout(() => {
            document.addEventListener('click', closeDropdownOnClickOutside);
        }, 0);
    }
}

function closeDropdownOnClickOutside(e) {
    const dropdown = document.getElementById('addDropdown');
    const addButton = document.querySelector('.btn-add');

    if (!dropdown.contains(e.target) && !addButton.contains(e.target)) {
        dropdown.classList.remove('active');
        document.removeEventListener('click', closeDropdownOnClickOutside);
    }
}

function showAddTaskModal() {
    document.getElementById('addDropdown').classList.remove('active');
    document.getElementById('modalTitle').textContent = 'Thêm Nhiệm Vụ';
    document.getElementById('taskForm').reset();
    document.getElementById('editTaskId').value = '';
    document.getElementById('taskStatus').value = 'todo';
    document.getElementById('taskModal').classList.add('active');
}

function showAddProjectModal() {
    document.getElementById('addDropdown').classList.remove('active');
    document.getElementById('projectModalTitle').textContent = 'Thêm Dự Án';
    document.getElementById('projectForm').reset();
    document.getElementById('editProjectId').value = '';
    selectedProjectColor = '#1a1a1a';
    document.getElementById('projectColor').value = '#1a1a1a';
    document.querySelectorAll('.color-option').forEach(opt => opt.classList.remove('selected'));
    document.querySelector('.color-option[data-color="#1a1a1a"]').classList.add('selected');
    document.getElementById('projectModal').classList.add('active');
}

function selectColor(element) {
    document.querySelectorAll('.color-option').forEach(opt => opt.classList.remove('selected'));
    element.classList.add('selected');
    selectedProjectColor = element.dataset.color;
    document.getElementById('projectColor').value = selectedProjectColor;
}

function closeProjectModal() {
    document.getElementById('projectModal').classList.remove('active');
}

function loadTasks() {
    const projectId = document.getElementById('projectSelect').value;
    const priorityFilter = document.getElementById('priorityFilter').value;

    let filteredTasks = tasks;

    if (projectId) {
        filteredTasks = filteredTasks.filter(t => t.duAnId == projectId);
    }

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

function changeView(view) {
    currentView = view;
    document.querySelectorAll('.view-btn').forEach(btn => btn.classList.remove('active'));
    event.target.classList.add('active');

    document.getElementById('listView').classList.add('hidden');
    document.getElementById('kanbanView').classList.add('hidden');
    document.getElementById('calendarView').classList.add('hidden');

    loadTasks();
}

function renderListView(taskList) {
    const view = document.getElementById('listView');
    view.classList.remove('hidden');

    if (taskList.length === 0) {
        view.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">📝</div>
                <h3>Chưa có nhiệm vụ</h3>
                <p style="font-size: 13px; color: #999;">Nhấn "Thêm mới" để bắt đầu</p>
            </div>
        `;
        return;
    }

    view.innerHTML = taskList.map(t => {
        const priority = t.doUuTien >= 4 ? 'high' : t.doUuTien >= 3 ? 'medium' : 'low';
        const priorityText = t.doUuTien >= 4 ? 'Cao' : t.doUuTien >= 3 ? 'TB' : 'Thấp';
        const project = t.duAnId ? projects.find(p => p.id === t.duAnId) : null;
        const completed = t.trangThai === 'done';

        return `
            <div class="task-item">
                <input type="checkbox" class="task-checkbox" ${completed ? 'checked' : ''}
                       onchange="toggleTask(${t.id}, this.checked)">
                <div class="task-content">
                    <div class="task-title ${completed ? 'completed' : ''}">${t.ten}</div>
                    <div class="task-meta">
                        <span class="task-priority priority-${priority}">${priorityText}</span>
                        <span>${project ? project.ten : 'Không có dự án'}</span>
                        ${t.ngayKetThuc ? '<span>📅 ' + new Date(t.ngayKetThuc).toLocaleDateString('vi-VN') + '</span>' : ''}
                    </div>
                </div>
                <div class="task-actions">
                    <button class="btn-icon" onclick="editTask(${t.id})">✏️</button>
                    <button class="btn-icon btn-delete" onclick="deleteTask(${t.id})">🗑️</button>
                </div>
            </div>
        `;
    }).join('');
}

function renderKanbanView(taskList) {
    const view = document.getElementById('kanbanView');
    view.classList.remove('hidden');

    const columns = [
        { status: 'todo', title: 'Cần làm' },
        { status: 'inprogress', title: 'Đang làm' },
        { status: 'done', title: 'Hoàn thành' }
    ];

    view.innerHTML = columns.map(col => {
        const colTasks = taskList.filter(t => t.trangThai === col.status);
        return `
            <div class="kanban-column" data-status="${col.status}">
                <div class="kanban-header">
                    <span>${col.title}</span>
                    <span class="kanban-count">${colTasks.length}</span>
                </div>
                <div class="kanban-cards" ondrop="drop(event)" ondragover="allowDrop(event)">
                    ${colTasks.map(t => {
            const priority = t.doUuTien >= 4 ? 'high' : t.doUuTien >= 3 ? 'medium' : 'low';
            const project = t.duAnId ? projects.find(p => p.id === t.duAnId) : null;
            return `
                            <div class="kanban-card priority-${priority}"
                                 draggable="true"
                                 ondragstart="drag(event)"
                                 data-task-id="${t.id}"
                                 onclick="editTask(${t.id})">
                                <div class="kanban-card-title">${t.ten}</div>
                                <div class="kanban-card-meta">
                                    ${project ? project.ten : 'Không có dự án'} •
                                    ${t.ngayKetThuc ? new Date(t.ngayKetThuc).toLocaleDateString('vi-VN') : 'Không có hạn'}
                                </div>
                            </div>
                        `;
        }).join('')}
                </div>
            </div>
        `;
    }).join('');
}

function allowDrop(ev) {
    ev.preventDefault();
}

function drag(ev) {
    ev.dataTransfer.setData("taskId", ev.target.dataset.taskId);
}

function drop(ev) {
    ev.preventDefault();
    const taskId = ev.dataTransfer.getData("taskId");
    const task = tasks.find(t => t.id == taskId);

    if (!task) return;

    let dropTarget = ev.target;
    while (dropTarget && !dropTarget.classList.contains('kanban-column')) {
        dropTarget = dropTarget.parentElement;
    }

    if (dropTarget) {
        task.trangThai = dropTarget.dataset.status;
        saveTasks();
        loadTasks();
    }
}

function renderCalendarView() {
    const view = document.getElementById('calendarView');
    view.classList.remove('hidden');

    const firstDay = new Date(currentYear, currentMonth, 1);
    const daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();
    const startDay = firstDay.getDay();

    const monthNames = ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
        'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];

    const today = new Date();
    const isCurrentMonth = currentMonth === today.getMonth() && currentYear === today.getFullYear();

    view.innerHTML = `
        <div class="calendar-header">
            <div class="calendar-header-left">
                <div class="calendar-selector">
                    <button type="button" class="calendar-selector-btn" onclick="toggleMonthDropdown(event)">
                        ${monthNames[currentMonth]} ▼
                    </button>
                    <div class="calendar-dropdown" id="monthDropdown">
                        ${monthNames.map((month, index) => `
                            <div class="calendar-dropdown-item ${index === currentMonth ? 'selected' : ''}"
                                 onclick="selectMonth(${index})">
                                ${month}
                            </div>
                        `).join('')}
                    </div>
                </div>
                <div class="calendar-selector">
                    <button type="button" class="calendar-selector-btn" onclick="toggleYearDropdown(event)">
                        ${currentYear} ▼
                    </button>
                    <div class="calendar-dropdown" id="yearDropdown">
                        ${Array.from({length: 11}, (_, i) => currentYear - 5 + i).map(year => `
                            <div class="calendar-dropdown-item ${year === currentYear ? 'selected' : ''}"
                                 onclick="selectYear(${year})">
                                ${year}
                            </div>
                        `).join('')}
                    </div>
                </div>
            </div>
            <div class="calendar-nav">
                <button class="btn-icon" onclick="changeMonth(-1)">◀</button>
                <button class="btn-icon" onclick="changeMonth(0)">Hôm nay</button>
                <button class="btn-icon" onclick="changeMonth(1)">▶</button>
            </div>
        </div>
        <div class="calendar-grid">
            ${['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'].map(day =>
        `<div class="calendar-day-header">${day}</div>`
    ).join('')}
            ${Array.from({length: startDay}, () => '<div></div>').join('')}
            ${Array.from({length: daysInMonth}, (_, i) => {
        const day = i + 1;
        const date = new Date(currentYear, currentMonth, day);
        const isToday = isCurrentMonth && day === today.getDate();
        const dateStr = date.toISOString().split('T')[0];

        const dayTasks = tasks.filter(t => t.ngayKetThuc && t.ngayKetThuc === dateStr);

        return `
                    <div class="calendar-day ${isToday ? 'today' : ''}">
                        <div class="calendar-day-number">${day}</div>
                        ${dayTasks.map(t => {
            const priority = t.doUuTien >= 4 ? 'high' : t.doUuTien >= 3 ? 'medium' : 'low';
            return `<div class="calendar-task priority-${priority}" onclick="viewTaskDetail(${t.id})" title="${t.ten}">${t.ten}</div>`;
        }).join('')}
                    </div>
                `;
    }).join('')}
        </div>
    `;
}

function toggleMonthDropdown(e) {
    e.stopPropagation();
    const dropdown = document.getElementById('monthDropdown');
    const yearDropdown = document.getElementById('yearDropdown');
    if (yearDropdown) yearDropdown.classList.remove('active');
    dropdown.classList.toggle('active');

    if (dropdown.classList.contains('active')) {
        setTimeout(() => {
            document.addEventListener('click', closeCalendarDropdowns);
        }, 0);
    }
}

function toggleYearDropdown(e) {
    e.stopPropagation();
    const dropdown = document.getElementById('yearDropdown');
    const monthDropdown = document.getElementById('monthDropdown');
    if (monthDropdown) monthDropdown.classList.remove('active');
    dropdown.classList.toggle('active');

    if (dropdown.classList.contains('active')) {
        setTimeout(() => {
            document.addEventListener('click', closeCalendarDropdowns);
        }, 0);
    }
}

function closeCalendarDropdowns(e) {
    const monthDropdown = document.getElementById('monthDropdown');
    const yearDropdown = document.getElementById('yearDropdown');

    if (monthDropdown && !monthDropdown.contains(e.target)) {
        monthDropdown.classList.remove('active');
    }

    if (yearDropdown && !yearDropdown.contains(e.target)) {
        yearDropdown.classList.remove('active');
    }

    if (!monthDropdown?.classList.contains('active') && !yearDropdown?.classList.contains('active')) {
        document.removeEventListener('click', closeCalendarDropdowns);
    }
}

function selectMonth(month) {
    currentMonth = month;
    renderCalendarView();
}

function selectYear(year) {
    currentYear = year;
    renderCalendarView();
}

function changeMonth(delta) {
    if (delta === 0) {
        const today = new Date();
        currentMonth = today.getMonth();
        currentYear = today.getFullYear();
    } else {
        currentMonth += delta;
        if (currentMonth > 11) {
            currentMonth = 0;
            currentYear++;
        } else if (currentMonth < 0) {
            currentMonth = 11;
            currentYear--;
        }
    }
    renderCalendarView();
}

function viewTaskDetail(id) {
    const task = tasks.find(t => t.id === id);
    if (!task) return;

    const priority = task.doUuTien >= 4 ? 'Cao' : task.doUuTien >= 3 ? 'Trung bình' : 'Thấp';
    const status = task.trangThai === 'todo' ? 'Cần làm' :
        task.trangThai === 'inprogress' ? 'Đang làm' : 'Hoàn thành';
    const project = task.duAnId ? projects.find(p => p.id === task.duAnId) : null;

    document.getElementById('viewContent').innerHTML = `
        <div class="detail-row">
            <span class="detail-label">Tên nhiệm vụ</span>
            <span class="detail-value">${task.ten}</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">Dự án</span>
            <span class="detail-value">${project ? project.ten : 'Không có'}</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">Ngày bắt đầu</span>
            <span class="detail-value">${task.ngayBatDau ? new Date(task.ngayBatDau).toLocaleDateString('vi-VN') : 'Không có'}</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">Ngày kết thúc</span>
            <span class="detail-value">${task.ngayKetThuc ? new Date(task.ngayKetThuc).toLocaleDateString('vi-VN') : 'Không có'}</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">Độ ưu tiên</span>
            <span class="detail-value">${priority}</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">Trạng thái</span>
            <span class="detail-value">${status}</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">Ghi chú</span>
            <span class="detail-value">${task.ghiChu || 'Không có'}</span>
        </div>
    `;

    document.getElementById('viewModal').classList.add('active');
}

function closeViewModal() {
    document.getElementById('viewModal').classList.remove('active');
}

function toggleTask(id, checked) {
    const task = tasks.find(t => t.id === id);
    if (task) {
        task.trangThai = checked ? 'done' : 'todo';
        saveTasks();
        loadTasks();
    }
}

function deleteTask(id) {
    if (!confirm('Xóa nhiệm vụ này?')) return;

    tasks = tasks.filter(t => t.id !== id);
    let allTasks = JSON.parse(localStorage.getItem(TASKS_KEY) || '[]');
    allTasks = allTasks.filter(t => t.id !== id);
    localStorage.setItem(TASKS_KEY, JSON.stringify(allTasks));

    loadTasks();
}

function editTask(id) {
    const task = tasks.find(t => t.id === id);
    if (!task) return;

    document.getElementById('modalTitle').textContent = 'Sửa Nhiệm Vụ';
    document.getElementById('editTaskId').value = task.id;
    document.getElementById('taskTitle').value = task.ten;
    document.getElementById('taskProject').value = task.duAnId || '';
    document.getElementById('taskStartDate').value = task.ngayBatDau || '';
    document.getElementById('taskEndDate').value = task.ngayKetThuc || '';
    document.getElementById('taskPriority').value = task.doUuTien;
    document.getElementById('taskStatus').value = task.trangThai;
    document.getElementById('taskNote').value = task.ghiChu || '';

    document.getElementById('taskModal').classList.add('active');
}

function closeModal() {
    document.getElementById('taskModal').classList.remove('active');
}

document.getElementById('taskForm').addEventListener('submit', (e) => {
    e.preventDefault();

    const editId = document.getElementById('editTaskId').value;
    const projectValue = document.getElementById('taskProject').value;

    const taskData = {
        ten: document.getElementById('taskTitle').value,
        duAnId: projectValue ? parseInt(projectValue) : null,
        ngayBatDau: document.getElementById('taskStartDate').value || null,
        ngayKetThuc: document.getElementById('taskEndDate').value || null,
        doUuTien: parseInt(document.getElementById('taskPriority').value),
        trangThai: document.getElementById('taskStatus').value,
        ghiChu: document.getElementById('taskNote').value,
        nguoiTaoId: currentUser.id,
        nguoiThucHienId: currentUser.id
    };

    let allTasks = JSON.parse(localStorage.getItem(TASKS_KEY) || '[]');

    if (editId) {
        const taskIndex = allTasks.findIndex(t => t.id == editId);
        if (taskIndex !== -1) {
            allTasks[taskIndex] = { ...allTasks[taskIndex], ...taskData };
        }
        const localIndex = tasks.findIndex(t => t.id == editId);
        if (localIndex !== -1) {
            tasks[localIndex] = { ...tasks[localIndex], ...taskData };
        }
    } else {
        const newId = allTasks.length > 0 ? Math.max(...allTasks.map(t => t.id)) + 1 : 1;
        const newTask = { id: newId, ...taskData };
        allTasks.push(newTask);
        tasks.push(newTask);
    }

    localStorage.setItem(TASKS_KEY, JSON.stringify(allTasks));
    closeModal();
    loadTasks();
});

document.getElementById('projectForm').addEventListener('submit', (e) => {
    e.preventDefault();

    const editId = document.getElementById('editProjectId').value;

    const projectData = {
        ten: document.getElementById('projectName').value,
        nguoiThucHien: document.getElementById('projectPerson').value || 'Chưa phân công',
        ngayBatDau: document.getElementById('projectStartDate').value || null,
        ngayKetThuc: document.getElementById('projectEndDate').value || null,
        ghiChu: document.getElementById('projectNote').value || '',
        mauSac: document.getElementById('projectColor').value
    };

    if (editId) {
        const projectIndex = projects.findIndex(p => p.id == editId);
        if (projectIndex !== -1) {
            projects[projectIndex] = { ...projects[projectIndex], ...projectData };
        }
    } else {
        const newId = projects.length > 0 ? Math.max(...projects.map(p => p.id)) + 1 : 1;
        const newProject = { id: newId, ...projectData };
        projects.push(newProject);
    }

    localStorage.setItem(PROJECTS_KEY, JSON.stringify(projects));
    closeProjectModal();
    loadProjects();
    loadTasks();
});

function saveTasks() {
    let allTasks = JSON.parse(localStorage.getItem(TASKS_KEY) || '[]');
    tasks.forEach(updatedTask => {
        const index = allTasks.findIndex(t => t.id === updatedTask.id);
        if (index !== -1) {
            allTasks[index] = updatedTask;
        }
    });
    localStorage.setItem(TASKS_KEY, JSON.stringify(allTasks));
}

function init() {
    loadTheme();
    checkAuth();
    initData();
    loadProjects();
    loadTasks();
}

init();