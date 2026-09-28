# PRD: Job Tracker (Self-Hosted)

**Versi:** 0.2
**Tanggal:** 28 September 2026
**Pemilik:** Wisnu

---

## 1. Ringkasan

Job Tracker adalah aplikasi web pribadi untuk mencatat dan memantau proses lamaran kerja dari awal hingga keputusan akhir.

Aplikasi berjalan secara **self-hosted** pada server `ejpi`, dideploy menggunakan Docker Compose, dan diakses melalui jaringan **Tailscale** dari laptop maupun HP.

Aplikasi menggunakan:

* **Frontend:** React + Vite + TypeScript
* **Backend:** Node.js + Fastify + TypeScript
* **Database:** PostgreSQL
* **ORM:** Drizzle ORM
* **API:** REST + JSON
* **Deployment:** Docker + Docker Compose

Aplikasi ditujukan untuk **satu pengguna** dan tidak membutuhkan sistem login pada versi awal karena akses dibatasi melalui Tailscale.

---

## 2. Masalah

Saat melamar banyak lowongan, data tersebar di email, chat, bookmark, dan catatan. Akibatnya:

* lupa status tiap lamaran,
* lupa waktu follow-up,
* sulit melihat gambaran keseluruhan,
* sulit mengetahui berapa lamaran yang sudah dikirim,
* sulit mengetahui berapa lamaran yang sudah masuk tahap interview atau offer.

Job Tracker menyediakan satu tempat untuk mencatat seluruh proses tersebut.

---

## 3. Tujuan dan Non-Tujuan

### 3.1 Tujuan

Untuk versi MVP:

1. Semua lamaran tercatat di satu tempat dengan status yang jelas.
2. Tidak ada lamaran yang terlewat follow-up.
3. Data tersimpan di server sendiri.
4. Database mudah dibackup dan direstore.
5. Aplikasi ringan dan dapat berjalan pada server dengan resource terbatas.
6. Aplikasi nyaman digunakan melalui laptop maupun HP.
7. Data dapat diekspor ke CSV.
8. Perubahan status lamaran mudah dipantau.

### 3.2 Non-Tujuan

Untuk versi MVP, aplikasi tidak mencakup:

* multi-user,
* berbagi data dengan pengguna lain,
* login dan manajemen akun,
* scraping lowongan otomatis,
* integrasi email,
* fitur AI,
* aplikasi mobile native,
* notifikasi push,
* integrasi kalender,
* sinkronisasi dengan layanan pihak ketiga.

---

## 4. Pengguna

### Primary User

Satu pengguna: **Wisnu**, seorang jobseeker.

### Platform

Aplikasi diakses melalui browser dari:

* laptop,
* desktop,
* smartphone.

### Bahasa

Antarmuka utama menggunakan **Bahasa Indonesia**.

---

## 5. User Stories

### Core

* Sebagai pencari kerja, saya ingin menambah lamaran baru dalam kurang dari 30 detik agar tidak malas mencatat.
* Saya ingin memindahkan lamaran antar status agar progresnya jelas.
* Saya ingin melihat lamaran yang follow-up-nya sudah lewat agar bisa segera menindaklanjuti.
* Saya ingin mencari lamaran berdasarkan nama perusahaan atau posisi.
* Saya ingin memfilter lamaran berdasarkan status.
* Saya ingin melihat jumlah lamaran per status.
* Saya ingin mengedit data lamaran setelah dibuat.
* Saya ingin menghapus lamaran yang tidak diperlukan.
* Saya ingin mengekspor data lamaran ke CSV.

### Secondary

* Saya ingin melihat riwayat perubahan status sebuah lamaran.
* Saya ingin mencatat sumber lowongan.
* Saya ingin memfilter berdasarkan sumber lowongan.
* Saya ingin menggunakan mode gelap.
* Saya ingin mengimpor data dari CSV.

---

# 6. Kebutuhan Fungsional

## 6.1 Must Have — MVP

| ID  | Kebutuhan                                                      |
| --- | -------------------------------------------------------------- |
| F1  | Tambah lamaran                                                 |
| F2  | Lihat detail lamaran                                           |
| F3  | Edit lamaran                                                   |
| F4  | Hapus lamaran                                                  |
| F5  | Status pipeline: Wishlist, Applied, Interview, Offer, Rejected |
| F6  | Tampilan Kanban                                                |
| F7  | Tampilan Tabel                                                 |
| F8  | Memindahkan lamaran antar status                               |
| F9  | Menyimpan tanggal follow-up                                    |
| F10 | Menandai lamaran overdue                                       |
| F11 | Pencarian teks                                                 |
| F12 | Filter berdasarkan status                                      |
| F13 | Ringkasan jumlah lamaran per status                            |
| F14 | Ringkasan jumlah overdue                                       |
| F15 | Ekspor semua data ke CSV                                       |
| F16 | UI responsif untuk HP                                          |

---

## 6.2 Should Have

| ID  | Kebutuhan                            |
| --- | ------------------------------------ |
| F17 | Riwayat perubahan status per lamaran |
| F18 | Timeline status                      |
| F19 | Field sumber lowongan                |
| F20 | Filter berdasarkan sumber            |
| F21 | Mode gelap                           |
| F22 | Impor dari CSV                       |

---

## 6.3 Could Have

Fitur setelah MVP:

* pengingat follow-up,
* notifikasi browser,
* lampiran dokumen,
* CV berdasarkan versi,
* surat lamaran,
* statistik rasio Applied → Interview,
* statistik rasio Interview → Offer,
* rata-rata waktu respons,
* status custom,
* login opsional jika aplikasi nantinya dibuka di luar Tailscale.

---

# 7. Status Pipeline

Status utama:

```text
wishlist
applied
interview
offer
rejected
```

### Arti Status

**Wishlist**
Lowongan menarik tetapi belum melamar.

**Applied**
Lamaran sudah dikirim.

**Interview**
Sudah masuk proses interview.

**Offer**
Mendapatkan offer.

**Rejected**
Lamaran ditolak atau proses selesai tanpa offer.

### Transisi

Status dapat berubah dari satu status ke status lain.

Contoh:

```text
Wishlist
   ↓
Applied
   ↓
Interview
   ↓
Offer
```

atau:

```text
Applied
   ↓
Rejected
```

Aplikasi tidak membatasi perpindahan status secara ketat agar pengguna dapat memperbaiki kesalahan pencatatan.

---

# 8. Model Data

## 8.1 Table: applications

| Kolom           | Tipe PostgreSQL | Constraint / Catatan                              |
| --------------- | --------------- | ------------------------------------------------- |
| id              | bigint          | Primary key, generated                            |
| company         | text            | wajib                                             |
| position        | text            | wajib                                             |
| job_url         | text            | opsional                                          |
| source          | text            | opsional                                          |
| location        | text            | opsional                                          |
| work_type       | text            | onsite / hybrid / remote                          |
| salary_min      | integer         | opsional                                          |
| salary_max      | integer         | opsional                                          |
| salary_currency | text            | default `IDR`                                     |
| status          | enum            | wishlist / applied / interview / offer / rejected |
| applied_date    | date            | opsional                                          |
| follow_up_date  | date            | opsional                                          |
| contact_name    | text            | opsional                                          |
| contact_info    | text            | opsional                                          |
| notes           | text            | opsional                                          |
| created_at      | timestamptz     | otomatis                                          |
| updated_at      | timestamptz     | otomatis                                          |

---

## 8.2 Table: status_history

| Kolom          | Tipe PostgreSQL | Catatan              |
| -------------- | --------------- | -------------------- |
| id             | bigint          | Primary key          |
| application_id | bigint          | FK → applications.id |
| from_status    | enum            | status sebelumnya    |
| to_status      | enum            | status baru          |
| changed_at     | timestamptz     | otomatis             |
| note           | text            | opsional             |

Foreign key menggunakan:

```text
ON DELETE CASCADE
```

sehingga history otomatis ikut dihapus ketika application dihapus.

---

# 9. Database

## 9.1 Database Engine

**PostgreSQL**

PostgreSQL digunakan sebagai database utama dan dijalankan sebagai service terpisah di Docker Compose.

### Database Service

```text
Service name: db
Container name: job-tracker-db
Database name: jobtracker
User: jobtracker
```

PostgreSQL tidak perlu mengekspos port ke host.

Backend mengakses database melalui internal Docker network.

Contoh:

```text
postgresql://jobtracker:<password>@db:5432/jobtracker
```

---

## 9.2 ORM

Menggunakan:

**Drizzle ORM**

Alasan:

* ringan,
* TypeScript-first,
* schema database dekat dengan kode,
* migration jelas,
* cocok untuk aplikasi kecil hingga menengah,
* tidak membutuhkan abstraction layer yang terlalu besar.

---

# 10. Frontend

## 10.1 Stack

* React
* Vite
* TypeScript
* React Router
* TanStack Query
* React Hook Form
* Zod
* Tailwind CSS
* shadcn/ui
* dnd-kit

---

## 10.2 Struktur UI

### Dashboard / Home

Halaman utama menampilkan:

```text
----------------------------------------------------
 Job Tracker                         + Tambah Lamaran
----------------------------------------------------

 Wishlist      Applied      Interview      Offer   Rejected
    12            18            5            2       31

 ⚠ 4 follow-up overdue

 [ Search... ] [ Status ] [ Source ]   [Kanban] [Table]

----------------------------------------------------
```

---

# 11. Tampilan Kanban

Kanban memiliki lima kolom:

```text
┌───────────┐
│ Wishlist  │
├───────────┤
│ Company A │
│ Company B │
│ Company C │
└───────────┘

┌───────────┐
│ Applied   │
├───────────┤
│ Company D │
│ Company E │
└───────────┘

┌───────────┐
│ Interview │
└───────────┘

┌───────────┐
│ Offer     │
└───────────┘

┌───────────┐
│ Rejected  │
└───────────┘
```

Card minimal menampilkan:

* company,
* position,
* location,
* follow-up date,
* source,
* indikator overdue.

Pengguna dapat:

1. drag-and-drop card ke kolom lain,
2. atau mengubah status melalui detail lamaran.

Perpindahan card harus langsung tersimpan ke backend.

---

# 12. Tampilan Tabel

Tampilan tabel menyediakan data lengkap secara ringkas.

Kolom utama:

```text
Company
Position
Status
Source
Location
Applied Date
Follow-up
Updated
Actions
```

Fitur:

* sorting,
* filtering,
* search,
* edit,
* delete,
* buka detail.

---

# 13. Detail Lamaran

Detail lamaran dibuka melalui drawer atau modal.

Field:

```text
Company *
Position *
Job URL
Source
Location
Work Type
Salary Min
Salary Max
Currency
Status
Applied Date
Follow-up Date
Contact Name
Contact Info
Notes
```

Aksi:

```text
Save
Delete
Change Status
View History
```

---

# 14. Quick Add

Pengguna harus dapat membuat lamaran dengan cepat.

Field minimal:

```text
Company *
Position *
Job URL
Status
```

Default:

```text
status = wishlist
```

Setelah lamaran dibuat, field lain dapat dilengkapi dari halaman detail.

Target waktu:

**< 30 detik untuk membuat record baru.**

---

# 15. Overdue

Lamaran dikategorikan **overdue** apabila:

```text
follow_up_date < current_date
```

dan lamaran belum ditutup atau masih membutuhkan tindak lanjut.

Untuk MVP, status yang dianggap masih aktif:

```text
wishlist
applied
interview
```

Status berikut dianggap selesai:

```text
offer
rejected
```

Overdue harus terlihat pada:

* dashboard summary,
* Kanban card,
* detail lamaran,
* tabel.

---

# 16. Dashboard Summary

Dashboard menampilkan:

```text
Wishlist:    X
Applied:     X
Interview:   X
Offer:       X
Rejected:    X

Overdue:     X
Total:       X
```

Summary diambil dari backend agar angka konsisten dengan database.

Endpoint:

```http
GET /api/summary
```

---

# 17. Search dan Filter

## Search

Endpoint mendukung:

```http
GET /api/applications?q=frontend
```

Search minimal mencakup:

* company,
* position,
* notes.

## Filter status

```http
GET /api/applications?status=applied
```

Kombinasi:

```http
GET /api/applications?status=interview&q=backend
```

---

# 18. Status History

Setiap perubahan status dicatat.

Contoh:

```text
28 Sep 2026
Wishlist → Applied

25 Sep 2026
Applied → Interview

20 Sep 2026
Wishlist → Applied
```

History menyimpan:

* status sebelumnya,
* status baru,
* waktu perubahan,
* catatan opsional.

---

# 19. API

API menggunakan:

**REST + JSON**

Base URL:

```text
/api
```

---

## 19.1 Applications

### GET

```http
GET /api/applications
```

Query parameter:

```text
status
q
source
```

Contoh:

```http
GET /api/applications?status=applied&q=frontend
```

### POST

```http
POST /api/applications
```

Request:

```json
{
  "company": "Example Company",
  "position": "Frontend Engineer",
  "job_url": "https://example.com/job",
  "status": "wishlist"
}
```

### GET detail

```http
GET /api/applications/:id
```

### PATCH

```http
PATCH /api/applications/:id
```

Contoh:

```json
{
  "status": "interview"
}
```

### DELETE

```http
DELETE /api/applications/:id
```

---

## 19.2 Summary

```http
GET /api/summary
```

Response:

```json
{
  "wishlist": 12,
  "applied": 18,
  "interview": 5,
  "offer": 2,
  "rejected": 31,
  "overdue": 4,
  "total": 68
}
```

---

## 19.3 History

```http
GET /api/applications/:id/history
```

---

## 19.4 CSV Export

```http
GET /api/export.csv
```

Response:

```text
Content-Type: text/csv
```

Semua field aplikasi diekspor.

---

## 19.5 CSV Import

Untuk fitur Should Have:

```http
POST /api/import.csv
```

Import harus:

* memvalidasi header,
* memvalidasi tipe data,
* memvalidasi status,
* menolak row invalid atau memberikan laporan error,
* tidak merusak data existing.

---

## 19.6 Health Check

```http
GET /api/health
```

Response:

```json
{
  "status": "ok"
}
```

Digunakan untuk Docker healthcheck.

---

# 20. Validasi

Validasi dilakukan di backend.

Menggunakan:

**Zod**

Validasi minimal:

* company tidak kosong,
* position tidak kosong,
* status harus valid,
* salary tidak negatif,
* URL valid apabila diberikan,
* tanggal valid,
* field text memiliki batas panjang yang wajar.

Frontend menggunakan schema yang sama dari package shared jika memungkinkan.

---

# 21. Keamanan

Aplikasi **tidak dibuka ke internet publik**.

Akses diberikan melalui:

```text
Tailscale
```

Aplikasi tidak memiliki login pada MVP.

Security requirement:

* parameterized query melalui ORM,
* validasi seluruh request,
* jangan menyimpan secret di repository,
* password PostgreSQL disimpan melalui environment variable,
* PostgreSQL tidak diekspos ke host,
* hanya port aplikasi yang dipublikasikan,
* jangan membuka port tambahan.

---

# 22. Runtime Dependency

UI tidak boleh bergantung pada CDN.

Semua dependency frontend harus dibundle oleh Vite.

Tidak boleh ada:

```html
<script src="https://cdn..."></script>
```

atau:

```html
<link href="https://fonts.googleapis.com/...">
```

Aplikasi harus tetap berfungsi tanpa akses internet setelah image/container tersedia.

---

# 23. Deployment Architecture

Docker Compose terdiri dari dua service:

```text
job-tracker
job-tracker-db
```

Architecture:

```text
                   Tailscale
                       │
                       ▼
                 Port 3100
                       │
                       ▼
             ┌─────────────────┐
             │   job-tracker    │
             │                 │
             │ React/Vite      │
             │ Fastify API     │
             │ Drizzle ORM     │
             └────────┬────────┘
                      │
                Docker Network
                      │
                      ▼
             ┌─────────────────┐
             │ job-tracker-db  │
             │   PostgreSQL    │
             └────────┬────────┘
                      │
                      ▼
                Docker Volume
```

---

# 24. Docker

## Application

Container:

```text
job-tracker
```

Host port:

```text
3100
```

Container port:

```text
3100
```

Restart:

```text
unless-stopped
```

Memory limit:

```text
256 MB
```

---

## PostgreSQL

Container:

```text
job-tracker-db
```

Database:

```text
jobtracker
```

PostgreSQL menyimpan data menggunakan persistent Docker volume.

PostgreSQL tidak membuka port langsung ke host.

---

# 25. Docker Compose

Struktur dasar:

```yaml
services:
  app:
    container_name: job-tracker
    build: .
    ports:
      - "3100:3100"
    environment:
      NODE_ENV: production
      DATABASE_URL: ${DATABASE_URL}
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    mem_limit: 256m

  db:
    image: postgres:18-alpine
    container_name: job-tracker-db
    environment:
      POSTGRES_DB: jobtracker
      POSTGRES_USER: jobtracker
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    mem_limit: 384m
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U jobtracker -d jobtracker"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

Nilai secret tidak boleh hardcoded di repository.

---

# 26. Akses

Aplikasi dapat diakses melalui alamat Tailscale:

```text
http://100.100.205.45:3100
```

Alamat tersebut hanya tersedia dari perangkat yang tersambung ke jaringan Tailscale yang sesuai.

---

# 27. Port Constraint

Port yang sudah digunakan server dan **tidak boleh dipakai ulang**:

```text
22
53
80
443
139
445
8000
9443
20128
```

Port aplikasi:

```text
3100
```

Port PostgreSQL tidak dipublish.

Container/service existing:

```text
Portainer
9router
```

Tidak boleh diganggu, dihentikan, dihapus, atau diubah konfigurasi sebagai bagian dari deployment Job Tracker.

---

# 28. Resource Requirement

Target:

### Application container

```text
idle RAM < 150 MB
mem_limit: 256 MB
```

### Database

PostgreSQL memiliki resource limit terpisah dan harus dijaga agar tidak menghabiskan memory server.

Server memiliki resource terbatas sehingga dependency yang berat harus dihindari.

Target utama:

```text
API response < 300 ms
```

untuk dataset ratusan lamaran.

---

# 29. Performance

Aplikasi harus dapat menangani setidaknya:

```text
1.000+ applications
```

tanpa redesign arsitektur.

Query yang sering digunakan harus menggunakan index yang sesuai.

Index minimal:

```text
applications.status
applications.company
applications.position
applications.follow_up_date
applications.source
```

Untuk pencarian sederhana pada MVP, PostgreSQL `ILIKE` dapat digunakan.

---

# 30. Backup

Backup terdiri dari dua jenis.

## 30.1 Database Backup

Gunakan PostgreSQL dump:

```bash
docker exec job-tracker-db \
  pg_dump -U jobtracker jobtracker \
  > backups/jobtracker_YYYYMMDD_HHMMSS.sql
```

## 30.2 CSV Export

Pengguna juga dapat melakukan backup dari UI:

```text
Export CSV
```

Backup database menjadi metode backup utama.

CSV menjadi backup tambahan yang mudah dibaca manusia dan spreadsheet.

---

# 31. Restore

Restore dilakukan menggunakan PostgreSQL tools.

Contoh:

```bash
cat backups/jobtracker_backup.sql | \
docker exec -i job-tracker-db \
psql -U jobtracker -d jobtracker
```

Dokumentasi restore harus tersedia di `README.md`.

---

# 32. Reliability

Docker Compose harus menggunakan:

```yaml
restart: unless-stopped
```

Aplikasi harus hidup kembali setelah:

* container restart,
* Docker restart,
* reboot server.

Database harus healthcheck sebelum backend bergantung penuh pada database.

Migration database harus dijalankan dengan aman pada deployment.

---

# 33. Project Structure

Struktur repository:

```text
job-tracker/
│
├── apps/
│   ├── web/
│   │   ├── src/
│   │   │   ├── components/
│   │   │   ├── features/
│   │   │   │   ├── applications/
│   │   │   │   ├── kanban/
│   │   │   │   ├── dashboard/
│   │   │   │   └── history/
│   │   │   ├── hooks/
│   │   │   ├── lib/
│   │   │   ├── pages/
│   │   │   ├── types/
│   │   │   └── main.tsx
│   │   ├── index.html
│   │   └── vite.config.ts
│   │
│   └── api/
│       └── src/
│           ├── db/
│           │   ├── schema/
│           │   ├── migrations/
│           │   └── client.ts
│           ├── routes/
│           ├── services/
│           ├── validators/
│           ├── lib/
│           └── server.ts
│
├── packages/
│   └── shared/
│       ├── schemas/
│       └── types/
│
├── Dockerfile
├── docker-compose.yml
├── package.json
├── pnpm-workspace.yaml
├── .env.example
├── .gitignore
└── README.md
```

---

# 34. Dependency Guidelines

Jangan menambahkan dependency tanpa alasan yang jelas.

Prinsip:

* pilih library yang lightweight,
* prioritaskan ecosystem TypeScript,
* hindari framework tambahan yang tidak diperlukan,
* hindari duplicate library dengan fungsi sama,
* jangan menambah state management global jika TanStack Query + local React state sudah cukup.

---

# 35. Testing

## Backend

Gunakan:

* Vitest
* Supertest

Minimal test:

* create application,
* get application,
* update application,
* delete application,
* change status,
* summary calculation,
* overdue calculation,
* CSV export.

## Frontend

Gunakan:

* Vitest,
* React Testing Library.

## End-to-End

Gunakan:

**Playwright**

Skenario minimal:

```text
Open app
→ Add application
→ Verify card appears
→ Move status
→ Refresh
→ Verify status persists
```

---

# 36. Error Handling

API harus menghasilkan HTTP status yang tepat.

Contoh:

```text
200 OK
201 Created
204 No Content
400 Bad Request
404 Not Found
409 Conflict
500 Internal Server Error
```

Response error:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Company is required"
  }
}
```

Frontend harus menampilkan error yang dapat dipahami pengguna.

---

# 37. UX Requirements

### Add Application

Pengguna harus dapat membuat aplikasi dengan cepat.

### Feedback

Setiap tindakan penting harus memiliki feedback:

```text
Saved
Updated
Deleted
Status updated
Export started
```

### Delete

Delete harus meminta konfirmasi.

### Loading

Tampilan loading harus tersedia ketika request membutuhkan waktu.

### Empty State

Saat belum ada lamaran:

```text
Belum ada lamaran.

Tambahkan lamaran pertama kamu.
```

### Error State

Saat API tidak tersedia:

```text
Tidak dapat terhubung ke server.
Coba lagi.
```

---

# 38. Responsive Requirements

UI harus digunakan dengan nyaman pada:

```text
Desktop
Tablet
Mobile
```

Pada mobile:

* Kanban dapat digeser horizontal,
* form tidak terlalu lebar,
* tombol utama mudah ditekan,
* drawer/modal harus nyaman digunakan,
* tabel dapat berubah menjadi layout card atau horizontal scroll.

---

# 39. Dark Mode

Dark mode termasuk Should Have.

Implementasi menggunakan:

```text
class-based dark mode
```

Preferensi dapat disimpan secara lokal menggunakan browser storage.

Tidak membutuhkan backend.

---

# 40. Acceptance Criteria — MVP

### CRUD

* [ ] User dapat menambah lamaran.
* [ ] User dapat melihat lamaran.
* [ ] User dapat mengedit lamaran.
* [ ] User dapat menghapus lamaran.
* [ ] Data tetap ada setelah browser refresh.

### Status

* [ ] Lima status tersedia.
* [ ] Card dapat dipindahkan antar status.
* [ ] Status tersimpan ke PostgreSQL.
* [ ] Status tetap benar setelah refresh.

### Follow-up

* [ ] User dapat mengatur tanggal follow-up.
* [ ] Follow-up yang telah lewat ditandai overdue.
* [ ] Jumlah overdue muncul di dashboard.

### Search

* [ ] Search berdasarkan teks berfungsi.
* [ ] Filter status berfungsi.
* [ ] Filter dapat digunakan bersama search.

### Dashboard

* [ ] Jumlah per status akurat.
* [ ] Total aplikasi akurat.
* [ ] Jumlah overdue akurat.

### Export

* [ ] CSV dapat diunduh.
* [ ] CSV dapat dibuka di spreadsheet.
* [ ] Header CSV benar.
* [ ] Semua application ikut diekspor.

### Persistence

* [ ] Data tetap ada setelah `docker compose down`.
* [ ] Data tetap ada setelah `docker compose up`.
* [ ] Data tetap ada setelah restart container.
* [ ] Data tetap ada setelah reboot server.

### Deployment

* [ ] Application berjalan pada port 3100.
* [ ] Tidak ada port existing yang terganggu.
* [ ] PostgreSQL tidak diekspos ke internet/host.
* [ ] Container otomatis restart.
* [ ] Database healthcheck berfungsi.

### Resource

* [ ] Application container idle < 150 MB RAM.
* [ ] API normal untuk ratusan lamaran.
* [ ] Tidak ada dependency CDN saat runtime.

---

# 41. Milestone

## M1 — Foundation

Target:

* repository setup,
* monorepo setup,
* React + Vite,
* Fastify,
* PostgreSQL,
* Drizzle,
* schema database,
* migration,
* REST API CRUD,
* validation,
* health check,
* basic tests.

Output:

```text
Database berjalan
API berjalan
CRUD berjalan
```

---

## M2 — UI

Target:

* dashboard,
* Kanban,
* table,
* add form,
* edit form,
* detail drawer,
* responsive layout.

Output:

```text
UI dapat melakukan CRUD melalui API.
```

---

## M3 — Core Features

Target:

* drag-and-drop,
* status persistence,
* follow-up,
* overdue,
* search,
* filter,
* summary,
* CSV export.

Output:

```text
MVP feature-complete.
```

---

## M4 — Deployment

Target:

* production Dockerfile,
* Docker Compose,
* PostgreSQL volume,
* environment variables,
* healthcheck,
* restart policy,
* deployment ke `ejpi`,
* backup,
* restore test.

Output:

```text
Production-ready self-hosted application.
```

---

## M5 — Optional

Target:

* status history,
* timeline,
* source filtering,
* dark mode,
* CSV import.

---

# 42. Risiko

| Risiko                        | Mitigasi                                           |
| ----------------------------- | -------------------------------------------------- |
| RAM server terbatas           | Batasi resource container, pilih dependency ringan |
| Database gagal start          | PostgreSQL healthcheck                             |
| Data hilang                   | Persistent volume + pg_dump berkala                |
| Backup tidak dapat direstore  | Lakukan restore test berkala                       |
| WiFi putus                    | Gunakan LAN bila memungkinkan                      |
| Server reboot                 | `restart: unless-stopped`                          |
| Akses tidak sengaja terbuka   | Jangan expose PostgreSQL, gunakan Tailscale        |
| Dependency terlalu berat      | Review dependency sebelum ditambahkan              |
| Search lambat saat data besar | Tambahkan index sesuai kebutuhan                   |

---

# 43. Open Questions

Hal berikut belum wajib diselesaikan untuk MVP:

1. Apakah lima status cukup atau perlu `screening` / `ghosted`?
2. Apakah UI tetap Bahasa Indonesia saja?
3. Apakah reminder follow-up masuk setelah MVP?
4. Apakah status custom diperlukan pada fase berikutnya?

Untuk MVP, default:

```text
5 status
Bahasa Indonesia
Tanpa reminder
Tanpa status custom
```

---

# 44. Technical Stack Final

## Frontend

```text
React
Vite
TypeScript
React Router
TanStack Query
React Hook Form
Zod
Tailwind CSS
shadcn/ui
dnd-kit
```

## Backend

```text
Node.js
Fastify
TypeScript
Zod
```

## Database

```text
PostgreSQL
Drizzle ORM
Drizzle Kit
```

## Testing

```text
Vitest
React Testing Library
Supertest
Playwright
```

## Deployment

```text
Docker
Docker Compose
Tailscale
```

---

# 45. Architecture Principles

1. **Simple over clever.**
2. **Type safety end-to-end.**
3. **Database adalah source of truth.**
4. **Frontend tidak menyimpan business logic penting.**
5. **Backend melakukan validasi.**
6. **Tidak ada dependency eksternal saat runtime.**
7. **PostgreSQL persistent dan dapat dibackup.**
8. **Tidak menyentuh service/container server yang sudah ada.**
9. **Tidak membuka port selain yang diperlukan aplikasi.**
10. **Setiap milestone harus dapat dijalankan dan dites sebelum lanjut.**

---

# 46. Catatan untuk Agent / Vibe Coding

Agent yang membangun aplikasi wajib:

* mengerjakan milestone secara berurutan,
* menjalankan aplikasi setelah setiap milestone,
* menjalankan test sebelum lanjut,
* membuat migration database,
* tidak menggunakan SQLite,
* tidak mengganti PostgreSQL dengan database lain,
* tidak menambahkan authentication pada MVP,
* tidak membuat sistem multi-user,
* tidak menambahkan AI,
* tidak melakukan scraping,
* tidak membuka port tambahan,
* tidak menghentikan atau mengubah container existing,
* menyimpan konfigurasi rahasia melalui environment variable,
* tidak menyimpan data aplikasi di image layer,
* memastikan PostgreSQL menggunakan persistent Docker volume,
* memastikan backup dan restore terdokumentasi,
* menyertakan `README.md`.

---

# 47. Definition of Done

Job Tracker dianggap selesai untuk MVP ketika:

```text
✅ React frontend berjalan
✅ Fastify API berjalan
✅ PostgreSQL berjalan
✅ Drizzle migration berjalan
✅ CRUD applications berjalan
✅ Kanban berjalan
✅ Table view berjalan
✅ Drag & drop status berjalan
✅ Follow-up berjalan
✅ Overdue berjalan
✅ Search berjalan
✅ Filter berjalan
✅ Summary berjalan
✅ CSV export berjalan
✅ Responsive mobile berjalan
✅ Docker deployment berjalan
✅ PostgreSQL persistent
✅ Backup tersedia
✅ Restore telah diuji
✅ Auto restart berjalan
✅ Healthcheck berjalan
✅ Tidak ada dependency CDN
✅ Tidak mengganggu service existing
```

**End of PRD**
