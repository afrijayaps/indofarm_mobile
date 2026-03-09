# IndoFarm Mobile Features

Aplikasi mobile digunakan oleh owner, manager, dan operator farm.

Tujuan aplikasi:
- monitoring farm
- input recording harian
- melihat performa produksi

---

# Role User

Owner
- melihat semua farm
- melihat dashboard performa
- melihat laporan

Manager
- melihat farm yang dikelola
- melihat recording
- melihat summary performa

Operator
- input recording harian
- melihat recording sebelumnya

---

# Fitur Utama Mobile

1 Login

User login menggunakan email dan password.

Endpoint:
POST /auth/login

---

2 Dashboard

Menampilkan:
- list farm
- summary produksi
- info populasi

Endpoint:
GET /farms

---

3 Farm Detail

Menampilkan:
- info farm
- summary performa

Endpoint:
GET /farms/{farm}/summary

---

4 Recording Harian

Operator menginput:

- telur
- mortalitas
- pakan
- suhu
- kelembaban

Endpoint:
POST /farms/{farm}/recordings

---

5 Inventory (opsional module)

Menampilkan stok farm.

Endpoint:
GET /inventory/stock-balances