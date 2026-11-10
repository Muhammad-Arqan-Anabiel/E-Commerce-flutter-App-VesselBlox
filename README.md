# VesselBlox Mobile 🚀
> **#1 Trusted Robux & Gamepass Marketplace Application**  
> Aplikasi mobile e-commerce modern berbasis **Flutter** untuk transaksi Robux dan Gamepass Roblox secara aman, cepat, dan transparan.

---

## 📖 Tentang Aplikasi
**VesselBlox Mobile** adalah platform marketplace inovatif yang dirancang khusus untuk komunitas pemain Roblox. Aplikasi ini memudahkan pengguna dalam menghitung estimasi harga, memesan Robux melalui berbagai metode resmi (Gamepass, Gifting, dan Group Funds), belanja gamepass dari game-game populer, hingga melacak status pesanan secara langsung (*real-time*).

Aplikasi hadir dengan antarmuka futuristik bertema gelap (*Dark/Void Aesthetic*), performa ringan, serta tata letak responsif di berbagai ukuran layar (Smartphone, Tablet, hingga Desktop/Web).

---

## ✨ Fitur Utama

- 🧮 **Kalkulator Robux Real-Time**: Hitung otomatis harga Robux lengkap dengan simulasi potongan pajak Roblox (tax calculation) dan diskon kupon.
- 📦 **Pilihan Multi-Metode Transaksi**:
  - **Gamepass**: Pembelian Robux via pembuatan gamepass sendiri.
  - **Group Funds**: Pengiriman Robux instan melalui payout grup Roblox.
  - **Gifting**: Pengiriman item atau gamepass langsung ke akun pengguna.
- 🎮 **Katalog Gamepass Populer**: Menyediakan gamepass resmi untuk game ternama seperti *Blox Fruits, Blade Ball, Fisch, Pet Simulator 99, Rivals*, dan game populer lainnya.
- 🛒 **Sistem Keranjang Belanja**: Tambahkan berbagai gamepass ke keranjang dan selesaikan pesanan dalam satu kali transaksi.
- 🔍 **Pelacakan Status Pesanan (Order Tracking)**: Cek status proses pesanan secara transparan hanya dengan memasukkan Order ID.
- 💬 **Pusat Bantuan & Live Ticket Chat**: Layanan pesan/tiket terintegrasi untuk berkonsultasi langsung dengan admin/CS mengenai transaksi.
- 🎟️ **Sistem Referral & Promo**: Masukkan kode referral teman untuk menikmati potongan harga spesial.
- 🌐 **Dukungan Multi-Bahasa**: Tersedia dalam Bahasa Indonesia dan Bahasa Inggris.
- 📱 **Desain Responsif & Multi-Platform**: Tampilan adaptif untuk smartphone, tablet, maupun browser.

---

## 🌐 Live Web Demo
Aplikasi ini sudah aktif dan dapat langsung dicoba tanpa instalasi:  
🔗 [**https://muhammad-arqan-anabiel.github.io/E-Commerce-flutter-App-VesselBlox/**](https://muhammad-arqan-anabiel.github.io/E-Commerce-flutter-App-VesselBlox/)

---

## 📱 Scan QR Code (Buka di HP)
Arahkan kamera HP (Android / iPhone) Anda ke QR Code di bawah untuk membuka aplikasi:

<p align="center">
  <img src="qr_code_live_app.png" alt="Scan QR Code to Open App" width="220" />
</p>

---

## 📸 Preview Tampilan Aplikasi

| Tampilan Smartphone | Tampilan Tablet | Menu Group Funds |
| :---: | :---: | :---: |
| <img src="Mobile Viewer/iPhone-14-PRO.webp" width="240" /> | <img src="Mobile Viewer/Galaxy-Tab-S7.webp" width="300" /> | <img src="Mobile Viewer/Galaxy-Tab-S7-group-fund.webp" width="300" /> |

---

## 🛠️ Teknologi yang Digunakan
- **Framework**: [Flutter](https://flutter.dev/) (Dart 3)
- **Tema Desain**: Custom Material Dark Theme (*Void Black & Ash Contrast*)
- **Penyimpanan Lokal**: `shared_preferences` (menyimpan pengaturan bahasa & keranjang)
- **Format & Lokalisasi**: `intl` (format mata uang Rupiah & multi-bahasa)
- **Koneksi Jaringan**: `http` package
- **CI/CD Deployment**: GitHub Actions & GitHub Pages

---

## 💻 Panduan Menjalankan Secara Lokal

1. **Clone repository ini:**
   ```bash
   git clone https://github.com/Muhammad-Arqan-Anabiel/E-Commerce-flutter-App-VesselBlox.git
   cd E-Commerce-flutter-App-VesselBlox
   ```

2. **Ambil semua dependency:**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi sesuai target:**
   - **Browser (Chrome/Brave)**:
     ```bash
     flutter run -d chrome
     ```
   - **Desktop Linux**:
     ```bash
     flutter run -d linux
     ```
   - **HP Android / Emulator**:
     ```bash
     flutter run
     ```
