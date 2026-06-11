"use client";
import React, { useState } from 'react';
import styles from './page.module.css';

export default function AppointmentManagement() {
  const [activeTab, setActiveTab] = useState(0); // 0: Chờ duyệt, 1: Đã xác nhận, 2: Lịch sử/Đã hủy
  
  const mockAppointments = [
    { id: 'APT-001', ptName: 'Trần Thế Bảo', docName: 'BS. Nguyễn Văn An', spec: 'Khoa Tim mạch', time: '08:30 - Hôm nay', type: 'Khám trực tuyến', status: 0 },
    { id: 'APT-002', ptName: 'Lê Thị Thu Thảo', docName: 'BS. Lê Thị Bình', spec: 'Khoa Nội', time: '09:15 - Hôm nay', type: 'Khám tại phòng khám', status: 0 },
    { id: 'APT-003', ptName: 'Vũ Hoàng Minh', docName: 'BS. Trần Quốc Đạt', spec: 'Khoa Thần kinh', time: '14:00 - Hôm qua', type: 'Khám trực tuyến', status: 1 },
    { id: 'APT-004', ptName: 'Nguyễn Ngọc Anh', docName: 'BS. Phạm Minh Tâm', spec: 'Khoa Tim mạch', time: '10:00 - 29/05', type: 'Khám tại phòng khám', status: 2, reason: 'Bệnh nhân bận việc đột xuất' },
  ];

  const filteredApts = mockAppointments.filter(apt => apt.status === activeTab);

  return (
    <div className={styles.container}>
      <div className={styles.topControls}>
        <h1 className={styles.title}>Điều phối Lịch hẹn</h1>
        <div className={styles.actions}>
          <div className={styles.searchBox}>
            <svg className={styles.searchIcon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <circle cx="11" cy="11" r="8"></circle>
              <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
            <input type="text" placeholder="Tìm mã lịch, tên bệnh nhân..." className={styles.searchInput} />
          </div>
          <div className={styles.datePicker}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="16" height="16">
              <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
              <line x1="16" y1="2" x2="16" y2="6"></line>
              <line x1="8" y1="2" x2="8" y2="6"></line>
              <line x1="3" y1="10" x2="21" y2="10"></line>
            </svg>
            <span>Hôm nay</span>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="16" height="16">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
          </div>
        </div>
      </div>

      <div className={styles.tabsContainer}>
        {['Chờ duyệt', 'Đã xác nhận', 'Lịch sử/Đã hủy'].map((tab, idx) => (
          <button 
            key={idx}
            className={`${styles.tab} ${activeTab === idx ? styles.activeTab : ''}`}
            onClick={() => setActiveTab(idx)}
          >
            {tab}
          </button>
        ))}
      </div>

      <div className={styles.tableContainer}>
        {filteredApts.length === 0 ? (
          <div className={styles.emptyState}>
            <div className={styles.emptyIcon}>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="32" height="32">
                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                <line x1="16" y1="2" x2="16" y2="6"></line>
                <line x1="8" y1="2" x2="8" y2="6"></line>
                <line x1="3" y1="10" x2="21" y2="10"></line>
                <line x1="9" y1="15" x2="15" y2="15"></line>
              </svg>
            </div>
            <h3>Không có lịch hẹn nào</h3>
            <p>Không tìm thấy dữ liệu khớp với bộ lọc hiện tại.</p>
          </div>
        ) : (
          <table className={styles.dataTable}>
            <thead>
              <tr>
                <th>Mã lịch</th>
                <th>Bệnh nhân & Bác sĩ</th>
                <th>Thời gian</th>
                <th>Loại hình khám</th>
                {activeTab === 0 && <th className={styles.rightAlign}>Hành động</th>}
                {activeTab === 2 && <th className={styles.rightAlign}>Trạng thái</th>}
              </tr>
            </thead>
            <tbody>
              {filteredApts.map((apt) => (
                <tr key={apt.id}>
                  <td className={styles.textMuted}>{apt.id}</td>
                  <td>
                    <div className={styles.ptName}>{apt.ptName}</div>
                    <div className={styles.docName}>{apt.docName} - {apt.spec}</div>
                  </td>
                  <td>
                    <div className={styles.timeWrap}>
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="16" height="16">
                        <circle cx="12" cy="12" r="10"></circle>
                        <polyline points="12 6 12 12 16 14"></polyline>
                      </svg>
                      {apt.time}
                    </div>
                  </td>
                  <td>
                    <span className={`${styles.typeBadge} ${apt.type.includes('trực tuyến') ? styles.telehealth : styles.clinic}`}>
                      {apt.type}
                    </span>
                  </td>
                  {activeTab === 0 && (
                    <td className={styles.rightAlign}>
                      <div className={styles.actionGroup}>
                        <button className={styles.rejectBtn}>Từ chối</button>
                        <button className={styles.approveBtn}>
                          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="16" height="16">
                            <polyline points="20 6 9 17 4 12"></polyline>
                          </svg>
                          Phê duyệt
                        </button>
                      </div>
                    </td>
                  )}
                  {activeTab === 2 && (
                    <td className={styles.rightAlign}>
                      <div className={styles.reasonWrap}>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="16" height="16">
                          <circle cx="12" cy="12" r="10"></circle>
                          <line x1="12" y1="8" x2="12" y2="12"></line>
                          <line x1="12" y1="16" x2="12.01" y2="16"></line>
                        </svg>
                        Lý do hủy: {apt.reason}
                      </div>
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
