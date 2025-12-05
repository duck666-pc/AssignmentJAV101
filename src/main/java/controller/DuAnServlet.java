package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import util.DatabaseConfig;

import java.io.*;
import java.sql.*;
import java.sql.Date;
import java.util.*;

@WebServlet(name = "DuAnServlet", urlPatterns = {"/duan"})
public class DuAnServlet extends HttpServlet {

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

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            String sql = "SELECT da.*, tk.ten as nguoi_tao_ten, " +
                    "(SELECT COUNT(*) FROM nhiem_vu WHERE du_an_id = da.id) as tong_nhiem_vu, " +
                    "(SELECT COUNT(*) FROM nhiem_vu WHERE du_an_id = da.id AND trang_thai = 'done') as nhiem_vu_hoan_thanh " +
                    "FROM du_an da " +
                    "LEFT JOIN tai_khoan tk ON da.nguoi_tao_id = tk.id " +
                    "WHERE da.nguoi_tao_id = ? OR ? = 'admin' " +
                    "ORDER BY da.ngay_cap_nhat DESC";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            stmt.setString(2, vaiTro);

            ResultSet rs = stmt.executeQuery();
            List<Map<String, Object>> projects = new ArrayList<>();

            while (rs.next()) {
                Map<String, Object> project = new HashMap<>();
                project.put("id", rs.getInt("id"));
                project.put("ten", rs.getString("ten"));
                project.put("mo_ta", rs.getString("mo_ta"));
                project.put("nguoiThucHien", rs.getString("nguoi_thuc_hien"));
                project.put("nguoiTaoId", rs.getInt("nguoi_tao_id"));
                project.put("nguoiTaoTen", rs.getString("nguoi_tao_ten"));
                project.put("ngayBatDau", rs.getDate("ngay_bat_dau"));
                project.put("ngayKetThuc", rs.getDate("ngay_ket_thuc"));
                project.put("ghiChu", rs.getString("ghi_chu"));
                project.put("mauSac", rs.getString("mau_sac"));
                project.put("trangThai", rs.getString("trang_thai"));
                project.put("tongNhiemVu", rs.getInt("tong_nhiem_vu"));
                project.put("nhiemVuHoanThanh", rs.getInt("nhiem_vu_hoan_thanh"));
                project.put("ngayTao", rs.getTimestamp("ngay_tao"));
                project.put("ngayCapNhat", rs.getTimestamp("ngay_cap_nhat"));
                projects.add(project);
            }

            resp.getWriter().write(gson.toJson(projects));

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Lỗi database: " + e.getMessage() + "\"}");
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

        Map<String, Object> projectData = gson.fromJson(req.getReader(), Map.class);

        if (projectData.get("ten") == null || projectData.get("ten").toString().trim().isEmpty()) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Thiếu tên dự án\"}");
            return;
        }

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            String sql = "INSERT INTO du_an (ten, mo_ta, nguoi_thuc_hien, nguoi_tao_id, " +
                    "ngay_bat_dau, ngay_ket_thuc, ghi_chu, mau_sac, trang_thai) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, projectData.get("ten").toString());
            stmt.setString(2, projectData.get("mo_ta") != null ? projectData.get("mo_ta").toString() : null);
            stmt.setString(3, projectData.get("nguoiThucHien") != null ?
                    projectData.get("nguoiThucHien").toString() : user.get("ten").toString());
            stmt.setInt(4, userId);
            stmt.setDate(5, projectData.get("ngayBatDau") != null ?
                    Date.valueOf(projectData.get("ngayBatDau").toString()) : null);
            stmt.setDate(6, projectData.get("ngayKetThuc") != null ?
                    Date.valueOf(projectData.get("ngayKetThuc").toString()) : null);
            stmt.setString(7, projectData.get("ghiChu") != null ? projectData.get("ghiChu").toString() : null);
            stmt.setString(8, projectData.get("mauSac") != null ?
                    projectData.get("mauSac").toString() : "#1a1a1a");
            stmt.setString(9, projectData.get("trangThai") != null ?
                    projectData.get("trangThai").toString() : "active");

            int affected = stmt.executeUpdate();

            if (affected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    int newId = rs.getInt(1);
                    projectData.put("id", newId);
                    resp.getWriter().write(gson.toJson(projectData));
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
            resp.getWriter().write("{\"error\":\"Thiếu ID dự án\"}");
            return;
        }

        int projectId = Integer.parseInt(idParam);
        Map<String, Object> updateData = gson.fromJson(req.getReader(), Map.class);

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            StringBuilder sql = new StringBuilder("UPDATE du_an SET ngay_cap_nhat = GETDATE()");
            List<Object> params = new ArrayList<>();

            if (updateData.containsKey("ten")) {
                sql.append(", ten = ?");
                params.add(updateData.get("ten"));
            }
            if (updateData.containsKey("mo_ta")) {
                sql.append(", mo_ta = ?");
                params.add(updateData.get("mo_ta"));
            }
            if (updateData.containsKey("nguoiThucHien")) {
                sql.append(", nguoi_thuc_hien = ?");
                params.add(updateData.get("nguoiThucHien"));
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
            if (updateData.containsKey("mauSac")) {
                sql.append(", mau_sac = ?");
                params.add(updateData.get("mauSac"));
            }
            if (updateData.containsKey("trangThai")) {
                sql.append(", trang_thai = ?");
                params.add(updateData.get("trangThai"));
            }

            sql.append(" WHERE id = ?");
            params.add(projectId);

            PreparedStatement stmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            int affected = stmt.executeUpdate();

            if (affected > 0) {
                updateData.put("id", projectId);
                resp.getWriter().write(gson.toJson(updateData));
            } else {
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Không tìm thấy dự án\"}");
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
            resp.getWriter().write("{\"error\":\"Thiếu ID dự án\"}");
            return;
        }

        int projectId = Integer.parseInt(idParam);

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();

            // Cập nhật tasks về null trước khi xóa project
            String updateTasksSql = "UPDATE nhiem_vu SET du_an_id = NULL WHERE du_an_id = ?";
            PreparedStatement updateStmt = conn.prepareStatement(updateTasksSql);
            updateStmt.setInt(1, projectId);
            updateStmt.executeUpdate();

            // Xóa project
            String sql = "DELETE FROM du_an WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, projectId);

            int affected = stmt.executeUpdate();

            if (affected > 0) {
                resp.setStatus(204);
            } else {
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Không tìm thấy dự án\"}");
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
