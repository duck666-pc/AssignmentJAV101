package util;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class EmailUtil {
    private static final String FROM_EMAIL = "your-email@gmail.com";
    private static final String PASSWORD = "your-app-password";
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";

    public static boolean sendEmail(String toEmail, String subject, String body) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.ssl.trust", SMTP_HOST);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);

            String htmlBody = "<!DOCTYPE html>" +
                    "<html><head><meta charset='UTF-8'></head><body style='font-family: Arial, sans-serif;'>" +
                    "<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>" +
                    "<div style='background: #1a1a1a; color: white; padding: 20px; border-radius: 8px 8px 0 0;'>" +
                    "<h2 style='margin: 0;'>📋 Task Manager</h2></div>" +
                    "<div style='background: #f8f9fa; padding: 30px; border-radius: 0 0 8px 8px;'>" +
                    body +
                    "</div>" +
                    "<div style='text-align: center; margin-top: 20px; color: #999; font-size: 12px;'>" +
                    "<p>© 2025 Task Manager. All rights reserved.</p>" +
                    "</div></div></body></html>";

            message.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(message);

            logEmail(toEmail, subject, body, "success");

            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            logEmail(toEmail, subject, body, "failed");
            return false;
        }
    }

    private static void logEmail(String toEmail, String subject, String body, String status) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            String sql = "INSERT INTO email_log (nguoi_nhan, tieu_de, noi_dung, trang_thai) VALUES (?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, toEmail);
            stmt.setString(2, subject);
            stmt.setString(3, body);
            stmt.setString(4, status);
            stmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void sendWelcomeEmail(String toEmail, String userName) {
        String subject = "Chào mừng đến với Task Manager!";
        String body = "<h3>Xin chào " + userName + "!</h3>" +
                "<p>Cảm ơn bạn đã đăng ký tài khoản tại Task Manager.</p>" +
                "<p>Bạn có thể bắt đầu quản lý công việc của mình ngay bây giờ!</p>" +
                "<p><a href='http://localhost:8080/task-manager' style='display: inline-block; padding: 10px 20px; background: #1a1a1a; color: white; text-decoration: none; border-radius: 6px;'>Đăng nhập ngay</a></p>";

        sendEmail(toEmail, subject, body);
    }

    public static boolean sendTaskReminderEmail(String toEmail, String taskName, String dueDate) {
        String subject = "⏰ Nhắc nhở: Nhiệm vụ sắp đến hạn";
        String body = "<h3>Nhiệm vụ sắp đến hạn!</h3>" +
                "<p><strong>Nhiệm vụ:</strong> " + taskName + "</p>" +
                "<p><strong>Hạn chót:</strong> " + dueDate + "</p>" +
                "<p>Đừng quên hoàn thành nhiệm vụ này đúng hạn nhé!</p>" +
                "<p><a href='http://localhost:8080/task-manager/trangchu.jsp' style='display: inline-block; padding: 10px 20px; background: #1a1a1a; color: white; text-decoration: none; border-radius: 6px;'>Xem chi tiết</a></p>";

        sendEmail(toEmail, subject, body);
        return false;
    }

    public static void sendTaskAssignmentEmail(String toEmail, String taskName, String projectName, String assignedBy) {
        String subject = "📝 Bạn được giao nhiệm vụ mới";
        String body = "<h3>Nhiệm vụ mới được giao!</h3>" +
                "<p><strong>Nhiệm vụ:</strong> " + taskName + "</p>" +
                "<p><strong>Dự án:</strong> " + projectName + "</p>" +
                "<p><strong>Người giao:</strong> " + assignedBy + "</p>" +
                "<p><a href='http://localhost:8080/task-manager/trangchu.jsp' style='display: inline-block; padding: 10px 20px; background: #1a1a1a; color: white; text-decoration: none; border-radius: 6px;'>Xem chi tiết</a></p>";

        sendEmail(toEmail, subject, body);
    }
}
