package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import util.DatabaseConfig;
import util.EmailUtil;

import java.io.*;
import java.sql.*;
import java.util.*;
import java.text.SimpleDateFormat;

@WebServlet(name = "TaskServlet", urlPatterns = {"/tasks"})
public class TaskServlet extends HttpServlet {
    private Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd").create();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        int userId = (int) user.get("id");
        String vaiTro = (String) user.get("vaiTro");

        String duAnIdParam = req.getParameter("duAnId");
        String nguoiThucHienIdParam = req.getParameter("nguoiThucHienId");

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();

            StringBuilder sql = new StringBuilder(
                    "SELECT nv.*, da.ten as ten_du_an, tk1.ten as nguoi_tao_ten, tk2.ten as nguoi_thuc_hien_ten " +
                            "FROM nhiem_vu nv " +
                            "LEFT JOIN du_an da ON nv.du_an_id = da.id " +
                            "LEFT JOIN tai_khoan tk1 ON nv.nguoi_tao_id = tk1.id " +
                            "LEFT JOIN tai_khoan tk2 ON nv.nguoi_thuc_hien_id = tk2.id " +
                            "WHERE 1=1 "
            );

            // Filter by user permissions
            if (!"admin".equals(vaiTro)) {
                sql.append("AND (nv.nguoi_tao_id = ? OR nv.nguoi_thuc_hien_id = ?) ");
            }

            if (duAnIdParam != null) {
                sql.append("AND nv.du_an_id = ? ");
            }

            if (nguoiThucHienIdParam != null) {
                sql.append("AND nv.nguoi_thuc_hien_id = ? ");
            }

            sql.append("ORDER BY nv.ngay_tao DESC");

            PreparedStatement stmt = conn.prepareStatement(sql.toString());
            int paramIndex = 1;

            if (!"admin".equals(vaiTro)) {
                stmt.setInt(paramIndex++, userId);
                stmt.setInt(paramIndex++, userId);
            }

            if (duAnIdParam != null) {
                stmt.setInt(paramIndex++, Integer.parseInt(duAnIdParam));
            }

            if (nguoiThucHienIdParam != null) {
                stmt.setInt(paramIndex++, Integer.parseInt(nguoiThucHienIdParam));
            }

            ResultSet rs = stmt.executeQuery();
            List<Map<String, Object>> tasks = new ArrayList<>();

            while (rs.next()) {
                Map<String, Object> task = new HashMap<>();
                task.put("id", rs.getInt("id"));
                task.put("ten", rs.getString("ten"));
                task.put("duAnId", rs.getObject("du_an_id"));
                task.put("tenDuAn", rs.getString("ten_du_an"));
                task.put("nguoiTaoId", rs.getInt("nguoi_tao_id"));
                task.put("nguoiTaoTen", rs.getString("nguoi_tao_ten"));
                task.put("nguoiThucHienId", rs.getInt("nguoi_thuc_hien_id"));
                task.put("nguoiThucHienTen", rs.getString("nguoi_thuc_hien_ten"));
                task.put("ngayBatDau", rs.getDate("ngay_bat_dau"));
                task.put("ngayKetThuc", rs.getDate("ngay_ket_thuc"));
                task.put("ghiChu", rs.getString("ghi_chu"));
                task.put("trangThai", rs.getString("trang_thai"));
                task.put("doUuTien", rs.getInt("do_uu_tien"));
                tasks.add(task);
            }

            resp.getWriter().write(gson.toJson(tasks));

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
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        int userId = (int) user.get("id");

        Map<String, Object> taskData = gson.fromJson(req.getReader(), Map.class);

        if (taskData.get("ten") == null || taskData.get("ten").toString().isEmpty()) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Thiếu tên nhiệm vụ\"}");
            return;
        }

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();

            String sql = "INSERT INTO nhiem_vu (ten, du_an_id, nguoi_tao_id, nguoi_thuc_hien_id, " +
                    "ngay_bat_dau, ngay_ket_thuc, ghi_chu, trang_thai, do_uu_tien) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, taskData.get("ten").toString());
            stmt.setObject(2, taskData.get("duAnId"));
            stmt.setInt(3, userId);
            stmt.setInt(4, taskData.get("nguoiThucHienId") != null ?
                    ((Double) taskData.get("nguoiThucHienId")).intValue() : userId);
            stmt.setObject(5, taskData.get("ngayBatDau"));
            stmt.setObject(6, taskData.get("ngayKetThuc"));
            stmt.setString(7, (String) taskData.get("ghiChu"));
            stmt.setString(8, taskData.get("trangThai") != null ?
                    (String) taskData.get("trangThai") : "todo");
            stmt.setInt(9, taskData.get("doUuTien") != null ?
                    ((Double) taskData.get("doUuTien")).intValue() : 3);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    int newId = rs.getInt(1);
                    taskData.put("id", newId);

                    // Create notification
                    createNotification(conn,
                            ((Double) taskData.get("nguoiThucHienId")).intValue(),
                            "Nhiệm vụ mới: " + taskData.get("ten"),
                            "Bạn được giao nhiệm vụ mới",
                            "task",
                            "/trangchu.jsp?taskId=" + newId
                    );

                    // Send email notification (async)
                    String assigneeEmail = getEmailById(conn,
                            ((Double) taskData.get("nguoiThucHienId")).intValue());
                    if (assigneeEmail != null) {
                        String projectName = taskData.get("duAnId") != null ?
                                getProjectNameById(conn, ((Double) taskData.get("duAnId")).intValue()) : "Không có dự án";
                        new Thread(() -> EmailUtil.sendTaskAssignmentEmail(
                                assigneeEmail,
                                taskData.get("ten").toString(),
                                projectName,
                                user.get("ten").toString()
                        )).start();
                    }
                }
            }

            resp.getWriter().write(gson.toJson(taskData));

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        int id = Integer.parseInt(req.getParameter("id"));
        Map<String, Object> updateData = gson.fromJson(req.getReader(), Map.class);

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();

            StringBuilder sql = new StringBuilder("UPDATE nhiem_vu SET ");
            List<Object> params = new ArrayList<>();

            if (updateData.containsKey("ten")) {
                sql.append("ten = ?, ");
                params.add(updateData.get("ten"));
            }
            if (updateData.containsKey("trangThai")) {
                sql.append("trang_thai = ?, ");
                params.add(updateData.get("trangThai"));
            }
            if (updateData.containsKey("ngayBatDau")) {
                sql.append("ngay_bat_dau = ?, ");
                params.add(updateData.get("ngayBatDau"));
            }
            if (updateData.containsKey("ngayKetThuc")) {
                sql.append("ngay_ket_thuc = ?, ");
                params.add(updateData.get("ngayKetThuc"));
            }
            if (updateData.containsKey("ghiChu")) {
                sql.append("ghi_chu = ?, ");
                params.add(updateData.get("ghiChu"));
            }
            if (updateData.containsKey("doUuTien")) {
                sql.append("do_uu_tien = ?, ");
                params.add(((Double) updateData.get("doUuTien")).intValue());
            }
            if (updateData.containsKey("nguoiThucHienId")) {
                sql.append("nguoi_thuc_hien_id = ?, ");
                params.add(((Double) updateData.get("nguoiThucHienId")).intValue());
            }

            // Remove trailing comma
            sql.setLength(sql.length() - 2);
            sql.append(" WHERE id = ?");
            params.add(id);

            PreparedStatement stmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                updateData.put("id", id);
                resp.getWriter().write(gson.toJson(updateData));
            } else {
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Không tìm thấy nhiệm vụ\"}");
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
        int id = Integer.parseInt(req.getParameter("id"));

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();

            String sql = "DELETE FROM nhiem_vu WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, id);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                resp.setStatus(204);
            } else {
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Không tìm thấy nhiệm vụ\"}");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }

    private void createNotification(Connection conn, int userId, String title,
                                    String content, String type, String link) throws SQLException {
        String sql = "INSERT INTO thong_bao (nguoi_nhan_id, tieu_de, noi_dung, loai, lien_ket) " +
                "VALUES (?, ?, ?, ?, ?)";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userId);
        stmt.setString(2, title);
        stmt.setString(3, content);
        stmt.setString(4, type);
        stmt.setString(5, link);
        stmt.executeUpdate();
    }

    private String getEmailById(Connection conn, int userId) throws SQLException {
        String sql = "SELECT email FROM tai_khoan WHERE id = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userId);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            return rs.getString("email");
        }
        return null;
    }

    private String getProjectNameById(Connection conn, int projectId) throws SQLException {
        String sql = "SELECT ten FROM du_an WHERE id = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, projectId);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            return rs.getString("ten");
        }
        return null;
    }
}
