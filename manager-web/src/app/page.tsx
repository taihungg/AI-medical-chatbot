import React from 'react';
import styles from './page.module.css';

export default function Dashboard() {
  const kpiData = [
    { title: 'Tổng bệnh nhân', value: '1,248', change: '+12%', isPositive: true },
    { title: 'Lịch khám hôm nay', value: '42', change: '+5%', isPositive: true },
    { title: 'Chờ duyệt', value: '15', change: '-2%', isPositive: false },
    { title: 'Doanh thu (VNĐ)', value: '12.5M', change: '+18%', isPositive: true },
  ];

  return (
    <div className={styles.dashboardContainer}>
      <div className={styles.header}>
        <h1 className={styles.pageTitle}>Tổng quan Phòng khám</h1>
        <div className={styles.dateSelector}>
          <span>Hôm nay, 11/06/2026</span>
        </div>
      </div>

      <div className={styles.kpiGrid}>
        {kpiData.map((kpi, index) => (
          <div key={index} className={styles.kpiCard}>
            <h3 className={styles.kpiTitle}>{kpi.title}</h3>
            <div className={styles.kpiValueRow}>
              <span className={styles.kpiValue}>{kpi.value}</span>
              <span className={`${styles.kpiChange} ${kpi.isPositive ? styles.positive : styles.negative}`}>
                {kpi.change}
              </span>
            </div>
          </div>
        ))}
      </div>

      <div className={styles.chartsGrid}>
        <div className={styles.chartCard}>
          <h3 className={styles.cardTitle}>Lưu lượng bệnh nhân (Tuần)</h3>
          <div className={styles.chartPlaceholder}>
            {/* Chart Area */}
            <div className={styles.barGroup}>
              <div className={styles.bar} style={{ height: '60%' }}></div>
              <div className={styles.bar} style={{ height: '80%' }}></div>
              <div className={styles.bar} style={{ height: '40%' }}></div>
              <div className={styles.bar} style={{ height: '90%' }}></div>
              <div className={styles.bar} style={{ height: '70%' }}></div>
              <div className={styles.bar} style={{ height: '100%' }}></div>
              <div className={styles.bar} style={{ height: '50%' }}></div>
            </div>
          </div>
        </div>

        <div className={styles.chartCard}>
          <div className={styles.cardHeader}>
            <h3 className={styles.cardTitle}>Lịch hẹn sắp tới</h3>
            <button className={styles.viewAllBtn}>Xem tất cả</button>
          </div>
          <div className={styles.appointmentList}>
            {[1, 2, 3].map((_, idx) => (
              <div key={idx} className={styles.appointmentItem}>
                <div className={styles.aptTime}>
                  <span className={styles.timeText}>08:30</span>
                  <span className={styles.periodText}>Sáng</span>
                </div>
                <div className={styles.aptInfo}>
                  <span className={styles.patientName}>Nguyễn Văn {String.fromCharCode(65 + idx)}</span>
                  <span className={styles.doctorName}>Khám tổng quát - BS. Lê Bình</span>
                </div>
                <div className={styles.aptStatus}>Đã xác nhận</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
