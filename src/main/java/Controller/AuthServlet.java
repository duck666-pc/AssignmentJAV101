package Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.google.gson.Gson;
import java.io.*;
import java.util.*;

@WebServlet(name = "AuthServlet", urlPatterns = {"/auth", "/auth/register", "/auth/login", "/auth/logout"})
public class AuthServlet extends HttpServlet {

    private Gson gson = new Gson();

    // Danh sách tài khoản lưu trong bộ nhớ
    private static List<Map<String, Object>> accounts = new ArrayList<>();
    private static int nextId = 1;

    static {
        // Tạo tài khoản admin mặc định
        Map<String, Object> admin = new HashMap<>();
        admin.put("id", nextId++);
        admin.put("ten", "Admin");
        admin.put("email", "admin@example.com");
        admin.put("matKhau", "admin123");
        admin.put("vaiTro", "admin");
        accounts.add(admin);

        // Tài khoản user mẫu
        Map<String, Object> user1 = new HashMap<>();
        user1.put("id", nextId++);
        user1.put("ten", "Nguyễn Văn A");
        user1.put("email", "user1@example.com");
        user1.put("matKhau", "123456");
        user1.put("vaiTro", "user");
        accounts.add(user1);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");

        // Kiểm tra session hiện tại
        HttpSession session = req.getSession(false);

        if (session != null && session.getAttribute("userId") != null) {
            Map<String, Object> user = new HashMap<>();
            user.put("id", session.getAttribute("userId"));
            user.put("ten", session.getAttribute("userName"));
            user.put("vaiTro", session.getAttribute("userRole"));
            resp.getWriter().write(gson.toJson(user));
        } else {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        req.setCharacterEncoding("UTF-8");

        String pathInfo = req.getRequestURI();

        if (pathInfo.endsWith("/register")) {
            handleRegister(req, resp);
        } else if (pathInfo.endsWith("/login")) {
            handleLogin(req, resp);
        } else if (pathInfo.endsWith("/logout")) {
            handleLogout(req, resp);
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            // Đọc dữ liệu JSON từ request
            BufferedReader reader = req.getReader();
            Map<String, String> data = gson.fromJson(reader, Map.class);

            String ten = data.get("ten");
            String email = data.get("email");
            String matKhau = data.get("matKhau");

            // Validate dữ liệu
            if (ten == null || ten.trim().isEmpty()) {
                resp.setStatus(400);
                resp.getWriter().write("{\"error\":\"Vui lòng nhập họ tên\"}");
                return;
            }

            if (email == null || email.trim().isEmpty()) {
                resp.setStatus(400);
                resp.getWriter().write("{\"error\":\"Vui lòng nhập email\"}");
                return;
            }

            if (matKhau == null || matKhau.length() < 6) {
                resp.setStatus(400);
                resp.getWriter().write("{\"error\":\"Mật khẩu phải có ít nhất 6 ký tự\"}");
                return;
            }

            // Kiểm tra email đã tồn tại
            for (Map<String, Object> account : accounts) {
                if (account.get("email").equals(email)) {
                    resp.setStatus(400);
                    resp.getWriter().write("{\"error\":\"Email đã được sử dụng\"}");
                    return;
                }
            }

            // Tạo tài khoản mới
            Map<String, Object> newAccount = new HashMap<>();
            newAccount.put("id", nextId++);
            newAccount.put("ten", ten);
            newAccount.put("email", email);
            newAccount.put("matKhau", matKhau);
            newAccount.put("vaiTro", "user");
            accounts.add(newAccount);

            // Tạo session tự động đăng nhập
            HttpSession session = req.getSession(true);
            session.setAttribute("userId", newAccount.get("id"));
            session.setAttribute("userName", newAccount.get("ten"));
            session.setAttribute("userRole", newAccount.get("vaiTro"));

            // Trả về kết quả
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);

            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("id", newAccount.get("id"));
            userInfo.put("ten", newAccount.get("ten"));
            userInfo.put("email", newAccount.get("email"));
            userInfo.put("vaiTro", newAccount.get("vaiTro"));
            result.put("user", userInfo);

            resp.getWriter().write(gson.toJson(result));

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            BufferedReader reader = req.getReader();
            Map<String, String> credentials = gson.fromJson(reader, Map.class);

            String email = credentials.get("email");
            String matKhau = credentials.get("matKhau");

            if (email == null || matKhau == null) {
                resp.setStatus(400);
                resp.getWriter().write("{\"error\":\"Vui lòng nhập đầy đủ thông tin\"}");
                return;
            }

            for (Map<String, Object> account : accounts) {
                if (account.get("email").equals(email) && account.get("matKhau").equals(matKhau)) {
                    HttpSession session = req.getSession(true);
                    session.setAttribute("userId", account.get("id"));
                    session.setAttribute("userName", account.get("ten"));
                    session.setAttribute("userRole", account.get("vaiTro"));

                    Map<String, Object> result = new HashMap<>();
                    result.put("success", true);

                    Map<String, Object> userInfo = new HashMap<>();
                    userInfo.put("id", account.get("id"));
                    userInfo.put("ten", account.get("ten"));
                    userInfo.put("email", account.get("email"));
                    userInfo.put("vaiTro", account.get("vaiTro"));
                    result.put("user", userInfo);

                    resp.getWriter().write(gson.toJson(result));
                    return;
                }
            }

            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Email hoặc mật khẩu không đúng\"}");

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }

    private void handleLogout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        resp.getWriter().write("{\"success\":true}");
    }
}
