# SecureVault

Password manager Android berbasis Flutter yang bekerja sepenuhnya offline. Semua kredensial dienkripsi secara lokal, tanpa server, cloud sync, analytics, atau pengumpulan data.

> **Peringatan:** Master password tidak dapat dipulihkan. Jika lupa, seluruh data di brankas tidak dapat dibuka. Simpan master password dan file backup di tempat yang aman.

## Fitur

- Brankas kredensial dengan pencarian, kategori, tag, dan riwayat password
- Master password dengan PBKDF2-HMAC-SHA256 (120.000 iterasi)
- Enkripsi AES-256-GCM per entri kredensial
- Unlock biometrik opsional
- Autentikasi dua faktor berbasis TOTP
- Auto-lock otomatis saat aplikasi ditinggalkan
- Generator password dengan pengaturan panjang, karakter, dan indikator kekuatan
- Salin username/password/URL ke clipboard dengan pembersihan otomatis
- Backup dan restore kredensial terenkripsi (`.svbackup`)
- Ganti master password dengan enkripsi ulang seluruh data
- Proteksi screenshot dan recent-app preview dengan `FLAG_SECURE`
- Backup otomatis Android dinonaktifkan (`allowBackup="false"`)
- UI Neobrutalism dengan font Lexend dan JetBrains Mono

## Keamanan Data

| Data | Lokasi penyimpanan | Perlindungan |
|---|---|---|
| Kredensial | SQLite `secure_vault.db`, tabel `credentials` | Payload JSON dienkripsi AES-256-GCM |
| Secret TOTP dan metadata sensitif | SQLite, tabel `meta` | Payload dienkripsi dengan kunci vault |
| Salt, verifier, kunci biometrik, pengaturan | `FlutterSecureStorage` | Dilindungi penyimpanan aman Android/Keystore |
| Backup | File `.svbackup` | Entri tetap terenkripsi dan memerlukan master password backup |

- Kunci vault diturunkan dari master password + salt 16 byte, hanya disimpan di memori selama brankas terbuka, lalu dihapus saat terkunci.
- Verifier adalah teks uji terenkripsi untuk memvalidasi master password tanpa menyimpan password asli.
- Database bukan SQLCipher. Yang dienkripsi adalah payload kredensial; kolom `id` dan `updated_at` tetap berupa metadata biasa.
- Aplikasi tidak mengirim data ke internet dan tidak memiliki backend.

## Teknologi

- Flutter/Dart (Dart SDK `^3.13.7`)
- `provider` untuk state management
- `sqflite` untuk database lokal
- `cryptography` untuk PBKDF2 dan AES-256-GCM
- `flutter_secure_storage` untuk kunci dan pengaturan sensitif
- `local_auth` untuk biometrik
- `share_plus`, `file_picker`, dan `path_provider` untuk backup/restore
- `url_launcher`, `clipboard`, dan `intl` untuk fitur pendukung

## Struktur Proyek

```text
lib/
├── core/
│   ├── constants/       # Konstanta aplikasi dan kategori
│   ├── security/        # Crypto, secure storage, biometrik, TOTP
│   ├── theme/           # Tema dan palet Neobrutalism
│   ├── utils/           # Generator password, clipboard helper
│   └── widgets/         # Widget UI bersama
├── features/
│   ├── auth/            # Setup, unlock, 2FA, biometric
│   ├── settings/        # Pengaturan, backup/restore
│   └── vault/           # Domain, repository, provider, dan layar vault
├── app.dart             # Root app, routing, auto-lock lifecycle
└── main.dart            # Dependency wiring dan bootstrap
```

## Menjalankan

Prasyarat: Flutter dengan Dart SDK yang sesuai `pubspec.yaml`, Android SDK, dan perangkat/emulator Android.

```bash
flutter pub get
flutter run
```

## Pengujian dan Analisis

```bash
flutter analyze
flutter test
```

## Build APK

```bash
flutter build apk --debug
flutter build apk --release
```

APK debug dihasilkan di:

```text
build/app/outputs/flutter-apk/app-debug.apk
```
