package Controller;

import java.util.List;
import java.util.ArrayList;

public class TaiKhoan {
    private int id;
    private String ten;
    private String email;
    private String matKhau;
    private String vaiTro; // admin, user
    private List<Integer> duAnIds; // Danh sách ID dự án tham gia

    public TaiKhoan() {
        this.duAnIds = new ArrayList<>();
    }

    public TaiKhoan(int id, String ten, String email, String matKhau, String vaiTro) {
        this.id = id;
        this.ten = ten;
        this.email = email;
        this.matKhau = matKhau;
        this.vaiTro = vaiTro;
        this.duAnIds = new ArrayList<>();
    }

    // Getters và Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTen() {
        return ten;
    }

    public void setTen(String ten) {
        this.ten = ten;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getMatKhau() {
        return matKhau;
    }

    public void setMatKhau(String matKhau) {
        this.matKhau = matKhau;
    }

    public String getVaiTro() {
        return vaiTro;
    }

    public void setVaiTro(String vaiTro) {
        this.vaiTro = vaiTro;
    }

    public List<Integer> getDuAnIds() {
        return duAnIds;
    }

    public void setDuAnIds(List<Integer> duAnIds) {
        this.duAnIds = duAnIds != null ? duAnIds : new ArrayList<>();
    }

    // Phương thức thêm/xóa dự án
    public void themDuAn(int duAnId) {
        if (this.duAnIds == null) {
            this.duAnIds = new ArrayList<>();
        }
        if (!this.duAnIds.contains(duAnId)) {
            this.duAnIds.add(duAnId);
        }
    }

    public void xoaDuAn(int duAnId) {
        if (this.duAnIds != null) {
            this.duAnIds.remove(Integer.valueOf(duAnId));
        }
    }

    public boolean thamGiaDuAn(int duAnId) {
        return this.duAnIds != null && this.duAnIds.contains(duAnId);
    }
}
