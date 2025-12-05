<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<fmt:setLocale value="${param.lang != null ? param.lang : pageContext.request.locale}"/>
<fmt:setBundle basename="messages"/>

<div class="header">
    <div class="header-content">
        <h1><fmt:message key="app.title"/></h1>
        <div class="user-info">
            <div class="language-selector">
                <select onchange="changeLanguage(this.value)">
                    <option value="vi" ${param.lang == 'vi' || param.lang == null ? 'selected' : ''}>🇻🇳 Tiếng Việt</option>
                    <option value="en" ${param.lang == 'en' ? 'selected' : ''}>🇬🇧 English</option>
                </select>
            </div>

            <button class="theme-toggle" onclick="toggleTheme()" id="themeToggle">🌙</button>

            <c:if test="${not empty sessionScope.user}">
                <div class="notification-wrapper">
                    <button class="notification-btn" onclick="toggleNotifications()" id="notificationBtn">
                        🔔
                        <span class="notification-badge" id="notificationBadge">0</span>
                    </button>
                    <div class="notification-dropdown" id="notificationDropdown">
                        <div class="notification-header">
                            <strong><fmt:message key="notification.title"/></strong>
                            <button class="btn-clear-notifications" onclick="markAllAsRead()">
                                <fmt:message key="notification.mark_read"/>
                            </button>
                        </div>
                        <div class="notification-list" id="notificationList"></div>
                    </div>
                </div>

                <div class="user-avatar" onclick="window.location.href='${pageContext.request.contextPath}/taikhoan.jsp'">
                        ${sessionScope.user.ten.substring(0,1).toUpperCase()}
                </div>
                <span style="font-size: 14px;">${sessionScope.user.ten}</span>

                <form action="${pageContext.request.contextPath}/auth?action=logout" method="post" style="display: inline;">
                    <button type="submit" class="btn-logout"><fmt:message key="home.logout"/></button>
                </form>
            </c:if>
        </div>
    </div>
</div>
