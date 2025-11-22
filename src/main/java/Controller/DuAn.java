package Controller;

import java.util.Date;

public class DuAn {
    private int id;
    private String ten;
    private String nguoiThucHien;
    private Date ngayBatDau;
    private Date ngayKetThuc;
    private String ghiChu;
    private String mauSac; // Màu sắc để phân biệt dự án

    public DuAn() {}

    public DuAn(int id, String ten, String nguoiThucHien, Date ngayBatDau, Date ngayKetThuc, String ghiChu, String mauSac) {
        this.id = id;
        this.ten = ten;
        this.nguoiThucHien = nguoiThucHien;
        this.ngayBatDau = ngayBatDau;
        this.ngayKetThuc = ngayKetThuc;
        this.ghiChu = ghiChu;
        this.mauSac = mauSac;
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

    public String getNguoiThucHien() {
        return nguoiThucHien;
    }

    public void setNguoiThucHien(String nguoiThucHien) {
        this.nguoiThucHien = nguoiThucHien;
    }

    public Date getNgayBatDau() {
        return ngayBatDau;
    }

    public void setNgayBatDau(Date ngayBatDau) {
        this.ngayBatDau = ngayBatDau;
    }

    public Date getNgayKetThuc() {
        return ngayKetThuc;
    }

    public void setNgayKetThuc(Date ngayKetThuc) {
        this.ngayKetThuc = ngayKetThuc;
    }

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }

    public String getMauSac() {
        return mauSac;
    }

    public void setMauSac(String mauSac) {
        this.mauSac = mauSac;
    }
}
