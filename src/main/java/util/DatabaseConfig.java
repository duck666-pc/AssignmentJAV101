package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConfig {
    // SQL Server connection string
    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=taskmanager;encrypt=true;trustServerCertificate=true";
    private static final String USER = "sa";
    private static final String PASSWORD = "123456";

    static {
        try {
            // Load SQL Server JDBC Driver
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            System.out.println("✓ SQL Server JDBC Driver loaded successfully");
        } catch (ClassNotFoundException e) {
            System.err.println("✗ SQL Server JDBC Driver not found!");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("✓ Database connected successfully");
            return conn;
        } catch (SQLException e) {
            System.err.println("✗ Failed to connect to database: " + e.getMessage());
            throw e;
        }
    }

    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
                System.out.println("✓ Connection closed");
            } catch (SQLException e) {
                System.err.println("✗ Error closing connection: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }

    // Test connection
    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            System.out.println("Database connection test: SUCCESS");
        } catch (SQLException e) {
            System.err.println("Database connection test: FAILED");
            e.printStackTrace();
        }
    }
}
