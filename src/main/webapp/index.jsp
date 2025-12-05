<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Kiểm tra session
    Object currentUser = session.getAttribute("userId");
    if (currentUser != null) {
        // Đã đăng nhập, chuyển đến trang chủ
        response.sendRedirect(request.getContextPath() + "/trangchu.jsp");
    } else {
        // Chưa đăng nhập, chuyển đến trang đăng nhập
        response.sendRedirect(request.getContextPath() + "/DangNhap.jsp");
    }
%>