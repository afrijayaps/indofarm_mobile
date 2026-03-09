# Flutter Architecture – IndoFarm Mobile

Arsitektur Flutter menggunakan struktur feature-based.

Tujuan:
- kode lebih rapi
- mudah dikembangkan
- AI IDE dapat memahami struktur project

---

# Struktur Folder

lib
 ├ core
 │   ├ api
 │   ├ storage
 │   ├ theme
 │   └ utils
 │
 ├ models
 │
 ├ services
 │
 ├ features
 │   ├ auth
 │   │   ├ login_page.dart
 │   │   └ auth_service.dart
 │   │
 │   ├ farms
 │   │   ├ farm_list_page.dart
 │   │   └ farm_service.dart
 │   │
 │   ├ recordings
 │   │   ├ recording_form_page.dart
 │   │   └ recording_service.dart
 │
 ├ widgets
 │
 └ main.dart

---

# Core

core/api
berisi HTTP client dan API configuration

core/storage
secure storage untuk token login

core/theme
theme aplikasi

core/utils
helper function

---

# Models

berisi model data dari API

contoh:
- user_model.dart
- farm_model.dart
- recording_model.dart

---

# Services

berisi service untuk komunikasi API

contoh:
- auth_service.dart
- farm_service.dart
- recording_service.dart

---

# Features

setiap fitur aplikasi memiliki folder sendiri.

contoh:

auth
farms
recordings

---

# Widgets

widget reusable.

contoh:

- primary_button.dart
- input_field.dart
- loading_indicator.dart