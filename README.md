# Divisi Teknologi Informasi – PT TASPEN (Persero)
**Tanggal:** 24 Desember 2024  
**Penulis:** Andhika Nayaka Arya Wibowo  

---

## Pekerjaan yang Dilakukan

### Frontend Consume API
- Menggunakan API untuk mendapatkan dan menampilkan data (Get List).
- Menyelesaikan persetujuan pengajuan Viewer melalui Syahrizal.

---

## Perubahan pada Pengajuan Cuti dan SPT (Surat Perintah Tugas) via Mobile

### SPT (Surat Perintah Tugas)
1. **Nama:**
   - Dapat membuat SPT untuk diri sendiri atau orang lain (tidak terbatas pada akun login).
   - Nama-nama diambil dari API berdasarkan nomor karyawan dan dapat dihapus jika diperlukan.

2. **Approver (Atasan):**
   - Data atasan diambil dari API berdasarkan nomor dan nama karyawan.

3. **Tanggal:**
   - Duty date hanya berlaku untuk 3 hari kerja. Jika melewati, harus membuat SPT baru.

4. **Start Time & End Time:**
   - Mengatur waktu mulai dan selesai tugas di luar kantor.

5. **Description:**
   - Informasi tugas yang dilakukan.

6. **Transport Facilities:**
   - Fasilitas transportasi yang digunakan (Pribadi/Kantor).

7. **Status:**
   - Draft
   - Waiting
   - Returned
   - Approved
   - Rejected

8. **Aksi:**
   - Reset
   - Save
   - Send to Approver

### SPT Approver
1. **Aksi:**
   - Approve: Menyetujui SPT.
   - Return: Dikembalikan ke user untuk diedit dan dikirim ulang.
   - Reject: SPT yang ditolak tidak bisa diedit kembali.
   - Print: Mengambil data dari API untuk mencetak surat.

2. **Informasi SPT:**
   - Tanggal, Waktu, Nama, NIK (nomor induk karyawan), Jabatan, Tim (jika lebih dari satu orang), Status (Need Approve, Approved, Rejected).

---

### Pengajuan Cuti
1. **Jenis Cuti:**
   - **Cuti Tahunan:**
     - Kuota: 12 hari.
     - Informasi penggunaan dan sisa kuota (bisa ditambah dari tahun sebelumnya jika tidak terpakai).
   - **Cuti Alasan Penting:**
     - Maksimum 12 hari kerja.
   - **Izin:**
     - Maksimum 5 kali pengajuan mendadak (tidak mengurangi kuota cuti).
   - **Izin Sakit:**
     - Bukti wajib diunggah (maksimum 2 MB).
     - Alamat selama izin sakit.
     - Tanggal izin dan deskripsi singkat.
   - **Izin Ibadah:**
     - Bukti wajib diunggah (maksimum 2 MB).
     - Alamat selama izin.
     - Catatan: Hanya dapat dilakukan sekali selama masa kerja.

2. **Status Cuti:**
   - Draft, Waiting, Approved, Rejected.

3. **Aksi:**
   - Reset
   - Save
   - Send to Approver

---

### Catatan Penting
- Semua proses pengajuan cuti dan izin dilakukan melalui aplikasi berbasis API.
- Data harus diverifikasi oleh reviewer (1-3 level) sebelum disetujui oleh approver.
- Format bukti yang diunggah harus memenuhi batas maksimum ukuran file (2 MB).
# taspen-mobile
