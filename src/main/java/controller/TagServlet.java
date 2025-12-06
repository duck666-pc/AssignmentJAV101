package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.google.gson.Gson;
import util.DatabaseConfig;

import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet(name = "TagServlet", urlPatterns = {"/tag"})
public class TagServlet extends HttpServlet {

    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        String action = req.getParameter("action");

        if ("getTaskTags".equals(action)) {
            getTaskTags(req, resp);
        } else {
            getAllTags(resp);
        }
    }

    private void getAllTags(HttpServletResponse resp) throws IOException {
        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            String sql = "SELECT * FROM nhan_tag ORDER BY ten ASC";
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();

            List<Map<String, Object>> tags = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> tag = new HashMap<>();
                tag.put("id", rs.getInt("id"));
                tag.put("ten", rs.getString("ten"));
                tag.put("mauSac", rs.getString("mau_sac"));
                tags.add(tag);
            }

            resp.getWriter().write(gson.toJson(tags));

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }

    private void getTaskTags(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String taskId = req.getParameter("taskId");

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            String sql = "SELECT nt.* FROM nhan_tag nt " +
                    "INNER JOIN nhiem_vu_tag nvt ON nt.id = nvt.nhan_tag_id " +
                    "WHERE nvt.nhiem_vu_id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(taskId));
            ResultSet rs = stmt.executeQuery();

            List<Map<String, Object>> tags = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> tag = new HashMap<>();
                tag.put("id", rs.getInt("id"));
                tag.put("ten", rs.getString("ten"));
                tag.put("mauSac", rs.getString("mau_sac"));
                tags.add(tag);
            }

            resp.getWriter().write(gson.toJson(tags));

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

        String action = req.getParameter("action");

        if ("addTagToTask".equals(action)) {
            addTagToTask(req, resp);
        } else if ("removeTagFromTask".equals(action)) {
            removeTagFromTask(req, resp);
        } else {
            createTag(req, resp);
        }
    }

    private void createTag(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Map<String, Object> tagData = gson.fromJson(req.getReader(), Map.class);

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            String sql = "INSERT INTO nhan_tag (ten, mau_sac) VALUES (?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, tagData.get("ten").toString());
            stmt.setString(2, tagData.get("mauSac") != null ?
                    tagData.get("mauSac").toString() : "#000000");

            stmt.executeUpdate();
            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                tagData.put("id", rs.getInt(1));
                resp.getWriter().write(gson.toJson(tagData));
            }

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }

    private void addTagToTask(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String taskId = req.getParameter("taskId");
        String tagId = req.getParameter("tagId");

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            String sql = "INSERT INTO nhiem_vu_tag (nhiem_vu_id, nhan_tag_id) VALUES (?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(taskId));
            stmt.setInt(2, Integer.parseInt(tagId));
            stmt.executeUpdate();

            resp.getWriter().write("{\"success\":true}");

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            DatabaseConfig.closeConnection(conn);
        }
    }

    private void removeTagFromTask(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String taskId = req.getParameter("taskId");
        String tagId = req.getParameter("tagId");

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            String sql = "DELETE FROM nhiem_vu_tag WHERE nhiem_vu_id = ? AND nhan_tag_id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(taskId));
            stmt.setInt(2, Integer.parseInt(tagId));
            stmt.executeUpdate();

            resp.getWriter().write("{\"success\":true}");

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

        String tagId = req.getParameter("id");

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            String sql = "DELETE FROM nhan_tag WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(tagId));

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                resp.setStatus(204);
            } else {
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Tag không tồn tại\"}");
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
