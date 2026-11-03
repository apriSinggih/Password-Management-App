lib/
├── core/
│   ├── constants/          # Konstanta aplikasi (warna, kunci storage)
│   ├── security/           # Logic enkripsi AES, hashing, & secure storage
│   └── utils/              # Helper clipboard & generator password
├── features/
│   ├── auth/               # Layar Master Password, Biometrik, Login
│   │   ├── presentation/
│   │   └── providers/
│   ├── vault/              # Layar daftar password, tambah/edit akun
│   │   ├── domain/         # Model data kredensial
│   │   ├── presentation/
│   │   └── providers/
│   └── settings/           # Pengaturan Auto-lock, Backup, Biometrik
└── main.dart