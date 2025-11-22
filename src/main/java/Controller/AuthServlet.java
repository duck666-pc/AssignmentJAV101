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

@WebServlet(name = "AuthServlet", urlPatterns = {"/auth/*"})
public class AuthServlet extends HttpServlet {

    private Gson gson = new Gson();
    private static List<TaiKhoan> taiKhoanList = new ArrayList<>();
    private static int nextId = 1;

    // Getter để các servlet khác truy cập
    public static List<TaiKhoan> getTaiKhoanList() {
        return taiKhoanList;
    }

    // Getter để lấy tài khoản theo ID
    public static TaiKhoan getTaiKhoanById(int id) {
        return taiKhoanList.stream()
                .filter(tk -> tk.getId() == id)
                .findFirst()
                .orElse(null);
    }

    static {
        // Tài khoản mẫu
        TaiKhoan admin = new TaiKhoan(nextId++, "Admin", "admin@example.com", "admin123", "admin");
        admin.themDuAn(1);
        admin.themDuAn(2);
        taiKhoanList.add(admin);

        TaiKhoan user1 = new TaiKhoan(nextId++, "Nguyễn Văn A", "user1@example.com", "123456", "user");
        user1.themDuAn(1);
        taiKhoanList.add(user1);

        TaiKhoan user2 = new TaiKhoan(nextId++, "Trần Thị B", "user2@example.com", "123456", "user");
        user2.themDuAn(2);
        taiKhoanList.add(user2);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        String pathInfo = req.getPathInfo();

        if ("/register".equals(pathInfo)) {
            handleRegister(req, resp);
        } else if ("/login".equals(pathInfo)) {
            handleLogin(req, resp);
        } else if ("/logout".equals(pathInfo)) {
            handleLogout(req, resp);
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan tk = gson.fromJson(req.getReader(), TaiKhoan.class);

        // Kiểm tra email đã tồn tại
        for (TaiKhoan t : taiKhoanList) {
            if (t.getEmail().equals(tk.getEmail())) {
                resp.setStatus(400);
                resp.getWriter().write("{\"error\":\"Email đã được sử dụng\"}");
                return;
            }
        }

        // Validate
        if (tk.getTen() == null || tk.getEmail() == null || tk.getMatKhau() == null) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Thiếu thông tin bắt buộc\"}");
            return;
        }

        tk.setId(nextId++);
        tk.setVaiTro("user");
        taiKhoanList.add(tk);

        // Tạo session
        HttpSession session = req.getSession();
        session.setAttribute("userId", tk.getId());
        session.setAttribute("userName", tk.getTen());
        session.setAttribute("userRole", tk.getVaiTro());

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);

        Map<String, Object> userInfo = new HashMap<>();
        userInfo.put("id", tk.getId());
        userInfo.put("ten", tk.getTen());
        userInfo.put("email", tk.getEmail());
        userInfo.put("vaiTro", tk.getVaiTro());
        result.put("user", userInfo);

        resp.getWriter().write(gson.toJson(result));
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Map<String, String> credentials = gson.fromJson(req.getReader(), Map.class);
        String email = credentials.get("email");
        String matKhau = credentials.get("matKhau");

        for (TaiKhoan tk : taiKhoanList) {
            if (tk.getEmail().equals(email) && tk.getMatKhau().equals(matKhau)) {
                HttpSession session = req.getSession();
                session.setAttribute("userId", tk.getId());
                session.setAttribute("userName", tk.getTen());
                session.setAttribute("userRole", tk.getVaiTro());

                Map<String, Object> result = new HashMap<>();
                result.put("success", true);

                Map<String, Object> userInfo = new HashMap<>();
                userInfo.put("id", tk.getId());
                userInfo.put("ten", tk.getTen());
                userInfo.put("email", tk.getEmail());
                userInfo.put("vaiTro", tk.getVaiTro());
                result.put("user", userInfo);

                resp.getWriter().write(gson.toJson(result));
                return;
            }
        }

        resp.setStatus(401);
        resp.getWriter().write("{\"error\":\"Email hoặc mật khẩu không đúng\"}");
    }

    private void handleLogout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        resp.getWriter().write("{\"success\":true}");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
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
}
