"use client";
import React, { useState } from 'react';
import styles from './page.module.css';

export default function DoctorManagement() {
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  
  const mockDoctors = [
    { id: 'BS-01', name: 'Nguyễn Văn An', spec: 'Khoa Tim mạch', phone: '0901234567', status: 'Đang làm việc' },
    { id: 'BS-02', name: 'Lê Thị Bình', spec: 'Khoa Nội', phone: '0987654321', status: 'Nghỉ phép' },
    { id: 'BS-03', name: 'Trần Quốc Đạt', spec: 'Khoa Thần kinh', phone: '0911223344', status: 'Đang làm việc' },
    { id: 'BS-04', name: 'Phạm Minh Tâm', spec: 'Khoa Ngoại', phone: '0933445566', status: 'Đang làm việc' },
  ];

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1 className={styles.title}>Quản lý Bác sĩ</h1>
        <div className={styles.actions}>
          <div className={styles.searchBox}>
            <svg className={styles.searchIcon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <circle cx="11" cy="11" r="8"></circle>
              <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
            <input type="text" placeholder="Tìm kiếm theo tên, SĐT..." className={styles.searchInput} />
          </div>
          <button className={styles.filterBtn}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon>
            </svg>
            Lọc
          </button>
          <button className={styles.addBtn} onClick={() => setIsDrawerOpen(true)}>
            + Thêm Bác sĩ
          </button>
        </div>
      </div>

      <div className={styles.tableContainer}>
        <table className={styles.dataTable}>
          <thead>
            <tr>
              <th>Bác sĩ</th>
              <th>Chuyên khoa</th>
              <th>Số điện thoại</th>
              <th>Trạng thái</th>
              <th className={styles.rightAlign}>Hành động</th>
            </tr>
          </thead>
          <tbody>
            {mockDoctors.map((doc) => (
              <tr key={doc.id}>
                <td>
                  <div className={styles.docInfo}>
                    <div className={styles.avatar}>
                      {doc.name.split(' ').pop()?.[0]}
                    </div>
                    <div>
                      <div className={styles.docName}>{doc.name}</div>
                      <div className={styles.docId}>{doc.id}</div>
                    </div>
                  </div>
                </td>
                <td>
                  <span className={styles.specBadge}>{doc.spec}</span>
                </td>
                <td>{doc.phone}</td>
                <td>
                  <span className={`${styles.statusBadge} ${doc.status === 'Đang làm việc' ? styles.statusActive : styles.statusInactive}`}>
                    {doc.status}
                  </span>
                </td>
                <td className={styles.rightAlign}>
                  <button className={styles.actionBtn}>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <polyline points="9 18 15 12 9 6"></polyline>
                    </svg>
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        
        <div className={styles.pagination}>
          <span>Hiển thị 1-4 trên tổng 4</span>
          <div className={styles.pageButtons}>
            <button disabled>Trước</button>
            <button disabled>Sau</button>
          </div>
        </div>
      </div>

      {/* Right Drawer cho Thêm Bác sĩ */}
      {isDrawerOpen && (
        <>
          <div className={styles.overlay} onClick={() => setIsDrawerOpen(false)}></div>
          <div className={styles.drawer}>
            <div className={styles.drawerHeader}>
              <h2>Thêm Bác sĩ mới</h2>
              <button onClick={() => setIsDrawerOpen(false)}>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
                  <line x1="18" y1="6" x2="6" y2="18"></line>
                  <line x1="6" y1="6" x2="18" y2="18"></line>
                </svg>
              </button>
            </div>
            <div className={styles.drawerBody}>
              <div className={styles.uploadArea}>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="32" height="32">
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                  <polyline points="17 8 12 3 7 8"></polyline>
                  <line x1="12" y1="3" x2="12" y2="15"></line>
                </svg>
                <p>Kéo thả ảnh hoặc click để tải lên</p>
                <span>JPG, PNG. Tối đa 2MB.</span>
              </div>
              
              <div className={styles.formGroup}>
                <label>Họ và Tên *</label>
                <input type="text" placeholder="Nhập tên bác sĩ..." />
              </div>
              
              <div className={styles.formGroup}>
                <label>Số điện thoại *</label>
                <input type="text" placeholder="Ví dụ: 0912..." className={styles.inputError} />
                <span className={styles.errorText}>Số điện thoại không hợp lệ</span>
              </div>
              
              <div className={styles.formGroup}>
                <label>Chuyên khoa *</label>
                <select>
                  <option>Chọn chuyên khoa...</option>
                  <option>Khoa Nội</option>
                  <option>Khoa Ngoại</option>
                  <option>Khoa Tim mạch</option>
                </select>
              </div>
            </div>
            <div className={styles.drawerFooter}>
              <button className={styles.cancelBtn} onClick={() => setIsDrawerOpen(false)}>Hủy</button>
              <button className={styles.saveBtn}>Lưu thông tin</button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
