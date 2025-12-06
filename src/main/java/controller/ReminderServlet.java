package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import util.DatabaseConfig;
import util.EmailUtil;

import java.io.*;
import java.sql.*;
import java.sql.Date;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@WebServlet(name = "ReminderServlet", urlPatterns = {"/reminder"})
public class ReminderServlet extends HttpServlet {

    private Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm").create();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        int userId = (int) user.get("id");

        String taskId = req.getParameter("taskId");

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            StringBuilder sql = new StringBuilder(
                    "SELECT nn.*, nv.ten as nhiem_vu_ten " +
                            "FROM nhac_nho nn " +
                            "INNER JOIN nhiem_vu nv ON nn.nhiem_vu_id = nv.id " +
                            "WHERE nn.tai_khoan_id = ?"
            );

            List<Object> params = new ArrayList<>();
            params.add(userId);

            if (taskId != null && !taskId.isEmpty()) {
                sql.append(" AND nn.nhiem_vu_id = ?");
                params.add(Integer.parseInt(taskId));
            }

            sql.append(" ORDER BY nn.thoi_gian_nhac ASC");

            PreparedStatement stmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            ResultSet rs = stmt.executeQuery();
            List<Map<String, Object>> reminders = new ArrayList<>();

            while (rs.next()) {
                Map<String, Object> reminder = new HashMap<>();
                reminder.put("id", rs.getInt("id"));
                reminder.put("nhiemVuId", rs.getInt("nhiem_vu_id"));
                reminder.put("nhiemVuTen", rs.getString("nhiem_vu_ten"));
                reminder.put("thoiGianNhac", rs.getTimestamp("thoi_gian_nhac"));
                reminder.put("loaiNhac", rs.getString("loai_nhac"));
                reminder.put("daGui", rs.getBoolean("da_gui"));
                reminder.put("ngayGui", rs.getTimestamp("ngay_gui"));
                reminders.add(reminder);
            }

            resp.getWriter().write(gson.toJson(reminders));

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        int userId = (int) user.get("id");

        Map<String, Object> reminderData = gson.fromJson(req.getReader(), Map.class);

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            String sql = "INSERT INTO nhac_nho (nhiem_vu_id, tai_khoan_id, thoi_gian_nhac, loai_nhac) " +
                    "VALUES (?, ?, ?, ?)";

            PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setInt(1, ((Number) reminderData.get("nhiemVuId")).intValue());
            stmt.setInt(2, userId);
            stmt.setTimestamp(3, Timestamp.valueOf(reminderData.get("thoiGianNhac").toString()));
            stmt.setString(4, reminderData.get("loaiNhac") != null ?
                    reminderData.get("loaiNhac").toString() : "email");

            stmt.executeUpdate();
            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                reminderData.put("id", rs.getInt(1));
                resp.getWriter().write(gson.toJson(reminderData));
            }

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        String reminderId = req.getParameter("id");

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            String sql = "DELETE FROM nhac_nho WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(reminderId));

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                resp.setStatus(204);
            } else {
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Reminder không tồn tại\"}");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }
}

// Scheduled Job để gửi reminder
class ReminderScheduler extends Thread {

    @Override
    public void run() {
        while (true) {
            try {
                processReminders();
                Thread.sleep(60000); // Check mỗi phút
            } catch (InterruptedException e) {
                e.printStackTrace();
                break;
            }
        }
    }

    private void processReminders() {
        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();

            // Lấy reminders cần gửi
            String sql = "SELECT nn.*, nv.ten as nhiem_vu_ten, tk.email, tk.ten as nguoi_dung_ten " +
                    "FROM nhac_nho nn " +
                    "INNER JOIN nhiem_vu nv ON nn.nhiem_vu_id = nv.id " +
                    "INNER JOIN tai_khoan tk ON nn.tai_khoan_id = tk.id " +
                    "WHERE nn.da_gui = 0 AND nn.thoi_gian_nhac <= GETDATE()";

            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                int reminderId = rs.getInt("id");
                String email = rs.getString("email");
                String taskName = rs.getString("nhiem_vu_ten");
                String userName = rs.getString("nguoi_dung_ten");
                String reminderType = rs.getString("loai_nhac");

                if ("email".equals(reminderType)) {
                    // Gửi email
                    boolean sent = EmailUtil.sendTaskReminderEmail(email, taskName,
                            rs.getTimestamp("thoi_gian_nhac").toString());

                    if (sent) {
                        // Cập nhật đã gửi
                        String updateSql = "UPDATE nhac_nho SET da_gui = 1, ngay_gui = GETDATE() WHERE id = ?";
                        PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                        updateStmt.setInt(1, reminderId);
                        updateStmt.executeUpdate();
                    }
                } else if ("notification".equals(reminderType)) {
                    // Tạo notification trong database
                    String notifSql = "INSERT INTO thong_bao (nguoi_nhan_id, tieu_de, noi_dung, loai) " +
                            "VALUES (?, ?, ?, 'warning')";
                    PreparedStatement notifStmt = conn.prepareStatement(notifSql);
                    notifStmt.setInt(1, rs.getInt("tai_khoan_id"));
                    notifStmt.setString(2, "⏰ Task Reminder");
                    notifStmt.setString(3, "Don't forget: " + taskName);
                    notifStmt.executeUpdate();

                    // Cập nhật đã gửi
                    String updateSql = "UPDATE nhac_nho SET da_gui = 1, ngay_gui = GETDATE() WHERE id = ?";
                    PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                    updateStmt.setInt(1, reminderId);
                    updateStmt.executeUpdate();
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }
}
