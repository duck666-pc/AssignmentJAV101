package controller;

import java.util.Date;

public class NhiemVu {
    private int id;
    private String ten;
    private int duAnId; // ID của dự án
    private int nguoiTaoId; // ID người tạo
    private int nguoiThucHienId; // ID người được giao việc
    private Date ngayBatDau;
    private Date ngayKetThuc;
    private String ghiChu;
    private String trangThai; // todo, inprogress, done
    private int doUuTien; // 1-5 (1: thấp, 5: cao)

    public NhiemVu() {}

    public NhiemVu(int id, String ten, int duAnId, int nguoiTaoId, int nguoiThucHienId,
                   Date ngayBatDau, Date ngayKetThuc, String ghiChu, String trangThai, int doUuTien) {
        this.id = id;
        this.ten = ten;
        this.duAnId = duAnId;
        this.nguoiTaoId = nguoiTaoId;
        this.nguoiThucHienId = nguoiThucHienId;
        this.ngayBatDau = ngayBatDau;
        this.ngayKetThuc = ngayKetThuc;
        this.ghiChu = ghiChu;
        this.trangThai = trangThai;
        this.doUuTien = doUuTien;
    }

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

    public int getDuAnId() {
        return duAnId;
    }

    public void setDuAnId(int duAnId) {
        this.duAnId = duAnId;
    }

    public Integer getNguoiTaoId() {
        return nguoiTaoId;
    }

    public void setNguoiTaoId(Integer nguoiTaoId) {
        this.nguoiTaoId = nguoiTaoId;
    }

    public int getNguoiThucHienId() {
        return nguoiThucHienId;
    }

    public void setNguoiThucHienId(int nguoiThucHienId) {
        this.nguoiThucHienId = nguoiThucHienId;
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

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public int getDoUuTien() {
        return doUuTien;
    }

    public void setDoUuTien(int doUuTien) {
        this.doUuTien = doUuTien;
    }
}
