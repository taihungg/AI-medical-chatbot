import React from 'react';
import styles from './Header.module.css';

export default function Header() {
  return (
    <header className={styles.headerContainer}>
      <div className={styles.leftSection}>
        <h1 className={styles.brand}>AI Care Bridge</h1>
        <div className={styles.searchBox}>
          <svg className={styles.searchIcon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="11" cy="11" r="8"></circle>
            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
          </svg>
          <input 
            type="text" 
            placeholder="Tìm kiếm bệnh nhân, bác sĩ, lịch hẹn..." 
            className={styles.searchInput}
          />
        </div>
      </div>
      
      <div className={styles.rightSection}>
        <button className={styles.iconButton}>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
            <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
          </svg>
          <span className={styles.badge}>3</span>
        </button>
        <div className={styles.profileSection}>
          <div className={styles.avatar}>HQ</div>
          <div className={styles.userInfo}>
            <span className={styles.userName}>Trần Quốc Hùng</span>
            <span className={styles.userRole}>Quản trị viên</span>
          </div>
        </div>
      </div>
    </header>
  );
}
