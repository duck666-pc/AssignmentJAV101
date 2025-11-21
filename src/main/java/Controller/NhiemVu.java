package Controller;

import java.util.Date;

public class NhiemVu {
    private String ten;
    private String duAn;
    private String nguoiTao;
    private Date ngayBatDau;
    private Date ngayKetThuc;
    private String ghiChu;

    public String getTen() {
        return ten;
    }

    public void setTen(String ten) {
        this.ten = ten;
    }

    public String getDuAn() {
        return duAn;
    }

    public void setDuAn(String duAn) {
        this.duAn = duAn;
    }

    public String getNguoiThucHien() {
        return nguoiTao;
    }

    public void setNguoiThucHien(String nguoiThucHien) {
        this.nguoiTao = nguoiTao;
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
}
