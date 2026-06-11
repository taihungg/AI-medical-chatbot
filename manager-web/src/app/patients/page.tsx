"use client";
import React, { useState } from 'react';
import styles from './page.module.css';

export default function PatientManagement() {
  const [selectedFilter, setSelectedFilter] = useState('Tất cả');
  
  const filters = ['Tất cả', 'Khách mới', 'Tái khám', 'Cần theo dõi'];

  const mockPatients = [
    { id: 'BN-8801', name: 'Trần Thế Bảo', phone: '0901234567', gender: 'Nam', age: 45, category: 'Khách mới', status: 'Khẩn cấp' },
    { id: 'BN-8802', name: 'Lê Thị Thu Thảo', phone: '0987654321', gender: 'Nữ', age: 32, category: 'Tái khám', status: 'Ổn định' },
    { id: 'BN-8803', name: 'Vũ Hoàng Minh', phone: '0911223344', gender: 'Nam', age: 50, category: 'Cần theo dõi', status: 'Khẩn cấp' },
    { id: 'BN-8804', name: 'Nguyễn Ngọc Anh', phone: '0933445566', gender: 'Nữ', age: 28, category: 'Khách mới', status: 'Ổn định' },
  ];

  return (
    <div className={styles.container}>
      <h1 className={styles.title}>Quản lý Bệnh nhân</h1>

      <div className={styles.topControls}>
        <div className={styles.searchBox}>
          <svg className={styles.searchIcon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="11" cy="11" r="8"></circle>
            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
          </svg>
          <input type="text" placeholder="Tìm kiếm theo tên, SĐT bệnh nhân..." className={styles.searchInput} />
        </div>
        <button className={styles.addBtn}>+ Thêm Bệnh nhân</button>
      </div>

      <div className={styles.tabsRow}>
        {filters.map((filter) => (
          <button 
            key={filter}
            className={`${styles.pillTab} ${selectedFilter === filter ? styles.pillActive : ''}`}
            onClick={() => setSelectedFilter(filter)}
          >
            {filter}
          </button>
        ))}
      </div>

      <div className={styles.tableContainer}>
        <table className={styles.dataTable}>
          <thead>
            <tr>
              <th>Bệnh nhân</th>
              <th>Thông tin cơ bản</th>
              <th>Phân loại</th>
              <th>Tình trạng</th>
              <th className={styles.rightAlign}>Hành động</th>
            </tr>
          </thead>
          <tbody>
            {mockPatients.map((pt) => (
              <tr key={pt.id}>
                <td>
                  <div className={styles.ptInfo}>
                    <div className={styles.avatar}>
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="20" height="20">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                      </svg>
                    </div>
                    <div>
                      <div className={styles.ptName}>{pt.name}</div>
                      <div className={styles.ptId}>{pt.id}</div>
                    </div>
                  </div>
                </td>
                <td>{pt.gender}, {pt.age} tuổi</td>
                <td>
                  <span className={styles.categoryBadge}>{pt.category}</span>
                </td>
                <td>
                  <span className={`${styles.statusBadge} ${pt.status === 'Khẩn cấp' ? styles.statusUrgent : styles.statusStable}`}>
                    {pt.status === 'Khẩn cấp' ? (
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="14" height="14">
                        <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
                        <line x1="12" y1="9" x2="12" y2="13"></line>
                        <line x1="12" y1="17" x2="12.01" y2="17"></line>
                      </svg>
                    ) : (
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="14" height="14">
                        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                        <polyline points="22 4 12 14.01 9 11.01"></polyline>
                      </svg>
                    )}
                    {pt.status}
                  </span>
                </td>
                <td className={styles.rightAlign}>
                  <button className={styles.actionBtn}>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="20" height="20">
                      <polyline points="9 18 15 12 9 6"></polyline>
                    </svg>
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
