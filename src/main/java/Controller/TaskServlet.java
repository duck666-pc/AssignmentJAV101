package Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.google.gson.Gson;
import java.io.*;
import java.util.*;

@WebServlet(name = "TaskServlet", urlPatterns = {"/tasks"})
public class TaskServlet extends HttpServlet {

    private Gson gson = new Gson();
    private List<Task> taskList = new ArrayList<>();
    private int nextId = 1;

    // Lấy danh sách task
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(gson.toJson(taskList));
    }

    // Thêm task mới
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Task task = gson.fromJson(req.getReader(), Task.class);

        if (task.title == null || task.title.isEmpty()) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Thiếu tiêu đề\"}");
            return;
        }

        task.id = nextId++;
        task.status = "todo";
        taskList.add(task);

        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(gson.toJson(task));
    }

    // Cập nhật task
    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        Task update = gson.fromJson(req.getReader(), Task.class);

        for (Task t : taskList) {
            if (t.id == id) {
                if (update.title != null) t.title = update.title;
                if (update.status != null) t.status = update.status;
                if (update.dueDate != null) t.dueDate = update.dueDate;

                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write(gson.toJson(t));
                return;
            }
        }

        resp.setStatus(404);
        resp.getWriter().write("{\"error\":\"Không tìm thấy\"}");
    }

    // Xóa task
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));

        if (taskList.removeIf(t -> t.id == id)) {
            resp.setStatus(204);
        } else {
            resp.setStatus(404);
            resp.getWriter().write("{\"error\":\"Không tìm thấy\"}");
        }
    }

    // Class Task đơn giản
    public static class Task {
        public int id;
        public String title;
        public String dueDate;
        public String status;
    }
}
