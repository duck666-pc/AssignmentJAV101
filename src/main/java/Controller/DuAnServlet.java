package Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.*;
import java.util.*;

@WebServlet(name = "DuAnServlet", urlPatterns = {"/projects"})
public class DuAnServlet extends HttpServlet {

    private Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd").create();
    private static List<DuAn> duAnList = new ArrayList<>();
    private static int nextId = 1;

    static {
        duAnList.add(new DuAn(nextId++, "Website Bán Hàng", "Admin", new Date(), null, "Dự án phát triển web", "#667eea"));
        duAnList.add(new DuAn(nextId++, "App Mobile", "Admin", new Date(), null, "Phát triển ứng dụng di động", "#f093fb"));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(gson.toJson(duAnList));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        DuAn duAn = gson.fromJson(req.getReader(), DuAn.class);

        if (duAn.getTen() == null || duAn.getTen().isEmpty()) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Thiếu tên dự án\"}");
            return;
        }

        duAn.setId(nextId++);
        if (duAn.getMauSac() == null) {
            duAn.setMauSac("#667eea");
        }
        duAnList.add(duAn);

        resp.getWriter().write(gson.toJson(duAn));
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        int id = Integer.parseInt(req.getParameter("id"));
        DuAn update = gson.fromJson(req.getReader(), DuAn.class);

        for (DuAn da : duAnList) {
            if (da.getId() == id) {
                if (update.getTen() != null) da.setTen(update.getTen());
                if (update.getNguoiThucHien() != null) da.setNguoiThucHien(update.getNguoiThucHien());
                if (update.getNgayBatDau() != null) da.setNgayBatDau(update.getNgayBatDau());
                if (update.getNgayKetThuc() != null) da.setNgayKetThuc(update.getNgayKetThuc());
                if (update.getGhiChu() != null) da.setGhiChu(update.getGhiChu());
                if (update.getMauSac() != null) da.setMauSac(update.getMauSac());

                resp.getWriter().write(gson.toJson(da));
                return;
            }
        }

        resp.setStatus(404);
        resp.getWriter().write("{\"error\":\"Không tìm thấy dự án\"}");
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));

        if (duAnList.removeIf(da -> da.getId() == id)) {
            resp.setStatus(204);
        } else {
            resp.setStatus(404);
            resp.getWriter().write("{\"error\":\"Không tìm thấy dự án\"}");
        }
    }
}
