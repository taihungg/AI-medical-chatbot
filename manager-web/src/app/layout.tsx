import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import styles from "./layout.module.css";
import Sidebar from "@/components/Sidebar";
import Header from "@/components/Header";

// Sử dụng font Inter thay cho Geist để có giao diện hiện đại chuẩn Web UI
const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "AI Medical Manager",
  description: "Dashboard for Clinic Management",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="vi">
      <body className={inter.className}>
        <div className={styles.layoutContainer}>
          <Sidebar />
          <div className={styles.mainContent}>
            <Header />
            <main className={styles.pageContainer}>
              {children}
            </main>
          </div>
        </div>
      </body>
    </html>
  );
}
