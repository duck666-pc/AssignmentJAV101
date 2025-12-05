package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.google.gson.Gson;
import util.DatabaseConfig;
import util.EmailUtil;

import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet(name = "AuthServlet", urlPatterns = {"/auth"})
public class AuthServlet extends HttpServlet {
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String action = req.getParameter("action");

        if ("check".equals(action)) {
            checkSession(req, resp);
        } else if ("logout".equals(action)) {
            handleLogout(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/dangnhap.jsp");
        }
    }

    private void checkSession(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        HttpSession session = req.getSession(false);

        if (session != null && session.getAttribute("user") != null) {
            Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
            resp.getWriter().write(gson.toJson(user));
        } else {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        String action = req.getParameter("action");

        if ("register".equals(action)) {
            handleRegister(req, resp);
        } else if ("login".equals(action)) {
            handleLogin(req, resp);
        } else if ("logout".equals(action)) {
            handleLogout(req, resp);
        } else {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Invalid action\"}");
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String ten = req.getParameter("ten");
        String email = req.getParameter("email");
        String matKhau = req.getParameter("matKhau");

        // Validate
        if (ten == null || ten.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập họ tên");
            req.getRequestDispatcher("/dangky.jsp").forward(req, resp);
            return;
        }

        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập email");
            req.getRequestDispatcher("/dangky.jsp").forward(req, resp);
            return;
        }

        if (matKhau == null || matKhau.length() < 6) {
            req.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự");
            req.getRequestDispatcher("/dangky.jsp").forward(req, resp);
            return;
        }

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();

            // Check if email exists
            String checkSql = "SELECT id FROM tai_khoan WHERE email = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, email);
            ResultSet rs = checkStmt.getResultSet();

            if (rs.next()) {
                req.setAttribute("error", "Email đã được sử dụng");
                req.getRequestDispatcher("/dangky.jsp").forward(req, resp);
                return;
            }

            // Insert new account
            String insertSql = "INSERT INTO tai_khoan (ten, email, mat_khau, vai_tro) VALUES (?, ?, ?, 'user')";
            PreparedStatement insertStmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            insertStmt.setString(1, ten);
            insertStmt.setString(2, email);
            insertStmt.setString(3, matKhau); // In production, use password hashing!
            insertStmt.executeUpdate();

            ResultSet generatedKeys = insertStmt.getGeneratedKeys();
            if (generatedKeys.next()) {
                int userId = generatedKeys.getInt(1);

                // Create session
                HttpSession session = req.getSession(true);
                Map<String, Object> user = new HashMap<>();
                user.put("id", userId);
                user.put("ten", ten);
                user.put("email", email);
                user.put("vaiTro", "user");
                session.setAttribute("user", user);

                // Remember me cookie if checked
                String rememberMe = req.getParameter("rememberMe");
                if ("true".equals(rememberMe)) {
                    Cookie emailCookie = new Cookie("rememberedEmail", email);
                    emailCookie.setMaxAge(30 * 24 * 60 * 60); // 30 days
                    emailCookie.setPath("/");
                    resp.addCookie(emailCookie);
                }

                // Send welcome email
                new Thread(() -> EmailUtil.sendWelcomeEmail(email, ten)).start();

                req.setAttribute("success", "Đăng ký thành công");
                resp.sendRedirect(req.getContextPath() + "/trangchu.jsp");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            req.getRequestDispatcher("/dangky.jsp").forward(req, resp);
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String email = req.getParameter("email");
        String matKhau = req.getParameter("matKhau");

        if (email == null || matKhau == null) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ thông tin");
            req.getRequestDispatcher("/dangnhap.jsp").forward(req, resp);
            return;
        }

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();

            String sql = "SELECT id, ten, email, vai_tro FROM tai_khoan WHERE email = ? AND mat_khau = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            stmt.setString(2, matKhau); // In production, use password hashing!

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                HttpSession session = req.getSession(true);
                Map<String, Object> user = new HashMap<>();
                user.put("id", rs.getInt("id"));
                user.put("ten", rs.getString("ten"));
                user.put("email", rs.getString("email"));
                user.put("vaiTro", rs.getString("vai_tro"));
                session.setAttribute("user", user);

                // Remember me cookie
                String rememberMe = req.getParameter("rememberMe");
                if ("true".equals(rememberMe)) {
                    Cookie emailCookie = new Cookie("rememberedEmail", email);
                    emailCookie.setMaxAge(30 * 24 * 60 * 60);
                    emailCookie.setPath("/");
                    resp.addCookie(emailCookie);
                } else {
                    // Clear cookie
                    Cookie emailCookie = new Cookie("rememberedEmail", "");
                    emailCookie.setMaxAge(0);
                    emailCookie.setPath("/");
                    resp.addCookie(emailCookie);
                }

                resp.sendRedirect(req.getContextPath() + "/trangchu.jsp");
            } else {
                req.setAttribute("error", "Email hoặc mật khẩu không đúng");
                req.getRequestDispatcher("/dangnhap.jsp").forward(req, resp);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            req.getRequestDispatcher("/dangnhap.jsp").forward(req, resp);
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }

    private void handleLogout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        resp.sendRedirect(req.getContextPath() + "/dangnhap.jsp");
    }
}
