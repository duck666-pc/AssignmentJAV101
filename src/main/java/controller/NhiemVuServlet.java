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
import java.util.*;

@WebServlet(name = "NhiemVuServlet", urlPatterns = {"/nhiemvu"})
public class NhiemVuServlet extends HttpServlet {

    private Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd").create();

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
        String vaiTro = (String) user.get("vaiTro");

        String duAnIdParam = req.getParameter("duAnId");
        String trangThaiParam = req.getParameter("trangThai");
        String tagIdParam = req.getParameter("tagId");

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            StringBuilder sql = new StringBuilder(
                    "SELECT DISTINCT nv.*, tk.ten as nguoi_thuc_hien_ten, da.ten as du_an_ten " +
                            "FROM nhiem_vu nv " +
                            "LEFT JOIN tai_khoan tk ON nv.nguoi_thuc_hien_id = tk.id " +
                            "LEFT JOIN du_an da ON nv.du_an_id = da.id "
            );

            // Thêm join với tags nếu cần filter theo tag
            if (tagIdParam != null && !tagIdParam.isEmpty()) {
                sql.append("INNER JOIN nhiem_vu_tag nvt ON nv.id = nvt.nhiem_vu_id ");
            }

            sql.append("WHERE (nv.nguoi_tao_id = ? OR nv.nguoi_thuc_hien_id = ?");

            List<Object> params = new ArrayList<>();
            params.add(userId);
            params.add(userId);

            if ("admin".equals(vaiTro)) {
                sql.append(" OR 1=1");
            }
            sql.append(")");

            if (duAnIdParam != null && !duAnIdParam.isEmpty()) {
                sql.append(" AND nv.du_an_id = ?");
                params.add(Integer.parseInt(duAnIdParam));
            }

            if (trangThaiParam != null && !trangThaiParam.isEmpty()) {
                sql.append(" AND nv.trang_thai = ?");
                params.add(trangThaiParam);
            }

            if (tagIdParam != null && !tagIdParam.isEmpty()) {
                sql.append(" AND nvt.nhan_tag_id = ?");
                params.add(Integer.parseInt(tagIdParam));
            }

            sql.append(" ORDER BY nv.ngay_cap_nhat DESC");

            PreparedStatement stmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            ResultSet rs = stmt.executeQuery();
            List<Map<String, Object>> tasks = new ArrayList<>();

            while (rs.next()) {
                Map<String, Object> task = new HashMap<>();
                int taskId = rs.getInt("id");

                task.put("id", taskId);
                task.put("ten", rs.getString("ten"));
                task.put("mo_ta", rs.getString("mo_ta"));
                task.put("duAnId", rs.getObject("du_an_id"));
                task.put("duAnTen", rs.getString("du_an_ten"));
                task.put("nguoiTaoId", rs.getInt("nguoi_tao_id"));
                task.put("nguoiThucHienId", rs.getInt("nguoi_thuc_hien_id"));
                task.put("nguoiThucHienTen", rs.getString("nguoi_thuc_hien_ten"));
                task.put("ngayBatDau", rs.getDate("ngay_bat_dau"));
                task.put("ngayKetThuc", rs.getDate("ngay_ket_thuc"));
                task.put("ghiChu", rs.getString("ghi_chu"));
                task.put("trangThai", rs.getString("trang_thai"));
                task.put("doUuTien", rs.getInt("do_uu_tien"));
                task.put("thoiGianHoanThanh", rs.getTimestamp("thoi_gian_hoan_thanh"));
                task.put("ngayTao", rs.getTimestamp("ngay_tao"));
                task.put("ngayCapNhat", rs.getTimestamp("ngay_cap_nhat"));

                // Lấy tags cho task này
                task.put("tags", getTaskTags(conn, taskId));

                tasks.add(task);
            }

            resp.getWriter().write(gson.toJson(tasks));

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Lỗi database: " + e.getMessage() + "\"}");
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }

    private List<Map<String, Object>> getTaskTags(Connection conn, int taskId) throws SQLException {
        List<Map<String, Object>> tags = new ArrayList<>();
        String sql = "SELECT nt.* FROM nhan_tag nt " +
                "INNER JOIN nhiem_vu_tag nvt ON nt.id = nvt.nhan_tag_id " +
                "WHERE nvt.nhiem_vu_id = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, taskId);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Map<String, Object> tag = new HashMap<>();
            tag.put("id", rs.getInt("id"));
            tag.put("ten", rs.getString("ten"));
            tag.put("mauSac", rs.getString("mau_sac"));
            tags.add(tag);
        }

        return tags;
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

        Map<String, Object> taskData = gson.fromJson(req.getReader(), Map.class);

        if (taskData.get("ten") == null || taskData.get("ten").toString().trim().isEmpty()) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Thiếu tên nhiệm vụ\"}");
            return;
        }

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            String sql = "INSERT INTO nhiem_vu (ten, mo_ta, du_an_id, nguoi_tao_id, nguoi_thuc_hien_id, " +
                    "ngay_bat_dau, ngay_ket_thuc, ghi_chu, trang_thai, do_uu_tien) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, taskData.get("ten").toString());
            stmt.setString(2, taskData.get("mo_ta") != null ? taskData.get("mo_ta").toString() : null);

            Object duAnId = taskData.get("duAnId");
            if (duAnId != null && !duAnId.toString().isEmpty()) {
                stmt.setInt(3, ((Number) duAnId).intValue());
            } else {
                stmt.setNull(3, Types.INTEGER);
            }

            stmt.setInt(4, userId);
            stmt.setInt(5, taskData.get("nguoiThucHienId") != null ?
                    ((Number) taskData.get("nguoiThucHienId")).intValue() : userId);

            stmt.setDate(6, taskData.get("ngayBatDau") != null ?
                    Date.valueOf(taskData.get("ngayBatDau").toString()) : null);
            stmt.setDate(7, taskData.get("ngayKetThuc") != null ?
                    Date.valueOf(taskData.get("ngayKetThuc").toString()) : null);

            stmt.setString(8, taskData.get("ghiChu") != null ? taskData.get("ghiChu").toString() : null);
            stmt.setString(9, taskData.get("trangThai") != null ?
                    taskData.get("trangThai").toString() : "todo");
            stmt.setInt(10, taskData.get("doUuTien") != null ?
                    ((Number) taskData.get("doUuTien")).intValue() : 3);

            int affected = stmt.executeUpdate();

            if (affected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    int newId = rs.getInt(1);
                    taskData.put("id", newId);

                    // Gửi email thông báo (async)
                    if (taskData.get("nguoiThucHienId") != null) {
                        new Thread(() -> {
                            try {
                                Connection emailConn = DatabaseConfig.getConnection();
                                String emailSql = "SELECT email, ten FROM tai_khoan WHERE id = ?";
                                PreparedStatement emailStmt = emailConn.prepareStatement(emailSql);
                                emailStmt.setInt(1, ((Number) taskData.get("nguoiThucHienId")).intValue());
                                ResultSet emailRs = emailStmt.executeQuery();

                                if (emailRs.next()) {
                                    EmailUtil.sendTaskAssignmentEmail(
                                            emailRs.getString("email"),
                                            taskData.get("ten").toString(),
                                            taskData.get("duAnTen") != null ? taskData.get("duAnTen").toString() : "Không có dự án",
                                            user.get("ten").toString()
                                    );
                                }
                                DatabaseConfig.closeConnection(emailConn);
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }).start();
                    }

                    resp.getWriter().write(gson.toJson(taskData));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Lỗi database: " + e.getMessage() + "\"}");
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Thiếu ID nhiệm vụ\"}");
            return;
        }

        int taskId = Integer.parseInt(idParam);
        Map<String, Object> updateData = gson.fromJson(req.getReader(), Map.class);

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();

            // Lấy trạng thái cũ để log lịch sử
            String oldStatusSql = "SELECT trang_thai FROM nhiem_vu WHERE id = ?";
            PreparedStatement oldStmt = conn.prepareStatement(oldStatusSql);
            oldStmt.setInt(1, taskId);
            ResultSet oldRs = oldStmt.executeQuery();
            String oldStatus = oldRs.next() ? oldRs.getString("trang_thai") : null;

            StringBuilder sql = new StringBuilder("UPDATE nhiem_vu SET ngay_cap_nhat = GETDATE()");
            List<Object> params = new ArrayList<>();

            if (updateData.containsKey("ten")) {
                sql.append(", ten = ?");
                params.add(updateData.get("ten"));
            }
            if (updateData.containsKey("mo_ta")) {
                sql.append(", mo_ta = ?");
                params.add(updateData.get("mo_ta"));
            }
            if (updateData.containsKey("trangThai")) {
                sql.append(", trang_thai = ?");
                params.add(updateData.get("trangThai"));
            }
            if (updateData.containsKey("doUuTien")) {
                sql.append(", do_uu_tien = ?");
                params.add(((Number) updateData.get("doUuTien")).intValue());
            }
            if (updateData.containsKey("ngayBatDau")) {
                sql.append(", ngay_bat_dau = ?");
                params.add(updateData.get("ngayBatDau") != null ?
                        Date.valueOf(updateData.get("ngayBatDau").toString()) : null);
            }
            if (updateData.containsKey("ngayKetThuc")) {
                sql.append(", ngay_ket_thuc = ?");
                params.add(updateData.get("ngayKetThuc") != null ?
                        Date.valueOf(updateData.get("ngayKetThuc").toString()) : null);
            }
            if (updateData.containsKey("ghiChu")) {
                sql.append(", ghi_chu = ?");
                params.add(updateData.get("ghiChu"));
            }
            if (updateData.containsKey("nguoiThucHienId")) {
                sql.append(", nguoi_thuc_hien_id = ?");
                params.add(((Number) updateData.get("nguoiThucHienId")).intValue());
            }

            sql.append(" WHERE id = ?");
            params.add(taskId);

            PreparedStatement stmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            int affected = stmt.executeUpdate();

            if (affected > 0) {
                // Log lịch sử nếu thay đổi trạng thái
                if (updateData.containsKey("trangThai") && !updateData.get("trangThai").equals(oldStatus)) {
                    Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
                    String logSql = "INSERT INTO lich_su_nhiem_vu (nhiem_vu_id, tai_khoan_id, hanh_dong, gia_tri_cu, gia_tri_moi) " +
                            "VALUES (?, ?, 'status_changed', ?, ?)";
                    PreparedStatement logStmt = conn.prepareStatement(logSql);
                    logStmt.setInt(1, taskId);
                    logStmt.setInt(2, (int) user.get("id"));
                    logStmt.setString(3, oldStatus);
                    logStmt.setString(4, updateData.get("trangThai").toString());
                    logStmt.executeUpdate();
                }

                updateData.put("id", taskId);
                resp.getWriter().write(gson.toJson(updateData));
            } else {
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Không tìm thấy nhiệm vụ\"}");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Lỗi database: " + e.getMessage() + "\"}");
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

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Thiếu ID nhiệm vụ\"}");
            return;
        }

        int taskId = Integer.parseInt(idParam);

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            String sql = "DELETE FROM nhiem_vu WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, taskId);

            int affected = stmt.executeUpdate();

            if (affected > 0) {
                resp.setStatus(204);
            } else {
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Không tìm thấy nhiệm vụ\"}");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Lỗi database: " + e.getMessage() + "\"}");
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }
}