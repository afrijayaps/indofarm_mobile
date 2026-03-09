# Mobile API v1 (Flutter + Sanctum)

Dokumen ini menjelaskan kontrak API mobile v1 untuk aplikasi Android (`mobile_app`).

Last updated: 2026-03-08

## 1) Base URL dan Auth
- Base URL: `https://<domain>/api/v1`
- Auth: `Bearer <token>` dari endpoint login Sanctum.
- Header:
  - `Accept: application/json`
  - `Content-Type: application/json`

## 2) Kontrak Response

### Success
```json
{
  "success": true,
  "data": {},
  "meta": {}
}
```

### Error
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Pesan error",
    "fields": {}
  },
  "meta": {}
}
```

## 3) Endpoint v1

### POST `/auth/login`
Request:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "device_name": "android-app"
}
```

Response `200`:
- `data.token`
- `data.token_type` (`Bearer`)
- `data.user`
- `data.workspace`

Kemungkinan error:
- `401 INVALID_CREDENTIALS`
- `403 USER_INACTIVE|WORKSPACE_INACTIVE|ROLE_NOT_ALLOWED`
- `409 PHONE_VERIFICATION_REQUIRED`
- `429 LOGIN_LOCKED`

### POST `/auth/logout`
- Butuh token.
- Menghapus token aktif.

### GET `/me`
- Butuh token.
- Return profil user + workspace.

### GET `/farms`
- Butuh token.
- Tenant-isolated berdasarkan `owner_id` user.
- Mendukung pagination (`meta.pagination`).

### GET `/farms/{farm}/summary`
Query opsional:
- `days` (default `7`)

Return:
- info farm ringkas
- periode summary
- latest recording date
- metrics operasional ringkas

### POST `/farms/{farm}/recordings`
Payload minimum:
```json
{
  "cage_id": 1,
  "tanggal": "2026-03-08",
  "pakan_pagi_kg": 6,
  "pakan_sore_kg": 4,
  "telur_rows": [
    { "jenis": "utuh", "kg": 5.6, "butir": 90 }
  ]
}
```

Catatan:
- Reuse logic existing recording + inventory sync.
- Jika inventory module ON, endpoint akan auto-sync inventory.
- Response `201` berisi:
  - `data.recording`
  - `meta.inventory_applied`
  - `meta.inventory_warnings`

### GET `/inventory/stock-balances?farm_id=...`
- Butuh token.
- Akses hanya untuk `owner/manager` dan module inventory aktif.
- Mendukung pagination (`meta.pagination`).

## 4) Policy Akses Mobile
- Role yang diizinkan API mobile: `owner`, `manager`, `operator`.
- `super_admin` tidak diekspos ke mobile v1.
- User wajib aktif.
- Workspace wajib aktif.
- Jika OTP + force verification gate aktif dan nomor belum terverifikasi:
  - API return `409 PHONE_VERIFICATION_REQUIRED`
  - `meta.redirect` berisi URL target verifikasi.

## 5) Test Coverage Backend
Suite khusus mobile:
- `Tests\\Feature\\Api\\V1\\MobileApiAuthTest`
- `Tests\\Feature\\Api\\V1\\MobileApiOperationsTest`

Command:
```bash
php artisan test --filter='(MobileApiAuthTest|MobileApiOperationsTest)'
```

Regression check yang ikut diverifikasi saat implementasi:
```bash
php artisan test --filter='(PhoneVerificationStartupGateTest|InventoryRecordingSyncServiceTest|InventoryStockMovementServiceTest)'
```
