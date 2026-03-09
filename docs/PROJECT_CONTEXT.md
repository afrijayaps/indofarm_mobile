# INDOFARM.APP

IndoFarm adalah aplikasi manajemen operasional peternakan ayam layer.

Tujuan aplikasi:
Membantu pemilik farm dan operator kandang mencatat dan memonitor performa peternakan secara digital.

Arsitektur sistem:

Backend:
Laravel + Filament
REST API
Sanctum Authentication

Mobile App:
Flutter

Database:
MySQL / MariaDB

---

# Jenis Pengguna

1. Owner
Pemilik farm yang memonitor performa farm.

Fitur owner:
- melihat semua farm
- melihat performa produksi
- melihat laporan
- melihat grafik performa

2. Operator
Petugas kandang yang melakukan input data harian.

Fitur operator:
- input recording harian
- input produksi telur
- input mortalitas
- input pakan
- input suhu dan kelembaban

---

# Struktur Sistem

Farm
 └ Flock
    └ Daily Recording

Daily Recording berisi:
- produksi telur
- mortalitas
- pakan
- suhu
- kelembaban
- jam lampu

---

# Tujuan Mobile App

Mobile app digunakan oleh:

- operator untuk input data di kandang
- owner untuk monitoring performa farm