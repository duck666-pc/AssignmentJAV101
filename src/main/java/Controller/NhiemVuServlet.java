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
import java.util.stream.Collectors;

@WebServlet(name = "NhiemVuServlet", urlPatterns = {"/nhiemvu"})
public class NhiemVuServlet extends HttpServlet {

    private Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd").create();
    private static List<NhiemVu> nhiemVuList = new ArrayList<>();
    private static int nextId = 1;

    static {
        // Nhiệm vụ mẫu
        nhiemVuList.add(new NhiemVu(nextId++, "Thiết kế giao diện", 1, 1, 2, new Date(), null, "Thiết kế UI/UX", "todo", 3));
        nhiemVuList.add(new NhiemVu(nextId++, "Phát triển Backend", 1, 1, 1, new Date(), null, "API REST", "inprogress", 5));
        nhiemVuList.add(new NhiemVu(nextId++, "Testing", 1, 1, 3, new Date(), null, "Kiểm thử chức năng", "done", 4));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");

        String duAnIdParam = req.getParameter("duAnId");
        String nguoiThucHienIdParam = req.getParameter("nguoiThucHienId");

        List<NhiemVu> filtered = nhiemVuList;

        if (duAnIdParam != null) {
            int duAnId = Integer.parseInt(duAnIdParam);
            filtered = filtered.stream()
                    .filter(nv -> nv.getDuAnId() == duAnId)
                    .collect(Collectors.toList());
        }

        if (nguoiThucHienIdParam != null) {
            int nguoiThucHienId = Integer.parseInt(nguoiThucHienIdParam);
            filtered = filtered.stream()
                    .filter(nv -> nv.getNguoiThucHienId() == nguoiThucHienId)
                    .collect(Collectors.toList());
        }

        resp.getWriter().write(gson.toJson(filtered));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        NhiemVu nv = gson.fromJson(req.getReader(), NhiemVu.class);

        if (nv.getTen() == null || nv.getTen().isEmpty()) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Thiếu tên nhiệm vụ\"}");
            return;
        }

        nv.setId(nextId++);
        if (nv.getTrangThai() == null) {
            nv.setTrangThai("todo");
        }
        if (nv.getDoUuTien() == 0) {
            nv.setDoUuTien(3);
        }
        nhiemVuList.add(nv);

        resp.getWriter().write(gson.toJson(nv));
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        int id = Integer.parseInt(req.getParameter("id"));
        NhiemVu update = gson.fromJson(req.getReader(), NhiemVu.class);

        for (NhiemVu nv : nhiemVuList) {
            if (nv.getId() == id) {
                if (update.getTen() != null) nv.setTen(update.getTen());
                if (update.getTrangThai() != null) nv.setTrangThai(update.getTrangThai());
                if (update.getNgayBatDau() != null) nv.setNgayBatDau(update.getNgayBatDau());
                if (update.getNgayKetThuc() != null) nv.setNgayKetThuc(update.getNgayKetThuc());
                if (update.getGhiChu() != null) nv.setGhiChu(update.getGhiChu());
                if (update.getDoUuTien() > 0) nv.setDoUuTien(update.getDoUuTien());
                if (update.getNguoiThucHienId() > 0) nv.setNguoiThucHienId(update.getNguoiThucHienId());

                resp.getWriter().write(gson.toJson(nv));
                return;
            }
        }

        resp.setStatus(404);
        resp.getWriter().write("{\"error\":\"Không tìm thấy nhiệm vụ\"}");
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));

        if (nhiemVuList.removeIf(nv -> nv.getId() == id)) {
            resp.setStatus(204);
        } else {
            resp.setStatus(404);
            resp.getWriter().write("{\"error\":\"Không tìm thấy nhiệm vụ\"}");
        }
    }
}