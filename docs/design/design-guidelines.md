# 🎨 Neobrutalism UI Design System & Specification

Dokumen ini berisi panduan desain antarmuka (UI/UX) bertema **Neobrutalism** untuk aplikasi **Password Manager**. Gaya Neobrutalism mengutamakan kontras tinggi, garis luar tegas (*bold borders*), bayangan tajam (*hard offset shadows*), serta kombinasi warna pop yang mencolok namun tetap fungsional dan aman.

---

## 1. Prinsip Desain (Design Principles)

1. **High Contrast & Hard Borders:** Semua elemen interaktif wajib memiliki garis tepi (*stroke/border*) hitam tebal (2px - 4px).
2. **Zero Blur Shadows:** Tidak ada efek *drop shadow* halus atau *gaussian blur*. Bayangan berbentuk solid hitam dengan pergeseran (*offset*) simetris/diagonal (4px - 6px).
3. **Vibrant & Muted Palette Combo:** Mengombinasikan warna latar belakang netral/pastel dengan warna-warna aksen *pop* yang tajam.
4. **Bold Typography:** Penggunaan bobot huruf tebal (*heavy/bold/black*) untuk hierarki judul dan aksi utama.
5. **Playful & Direct UI:** Elemen visual terlihat tegas, berani, jujur, dan mudah dikenali pengguna.

---

## 2. Palette Warna (Color Palette)

### A. Primary & Accent Colors (Neobrutalist Pop)
* **Electric Yellow (Primary Accent):** `#FFE600` — Tombol aksi utama, highlight penting.
* **Neobrutal Purple (Secondary Accent):** `#8B5CF6` — Banner, tag kategori, indikator vault.
* **Vibrant Mint Green (Success/Safe):** `#00F5A0` — Indikator password kuat, status aktif.
* **Hot Coral / Red (Warning/Danger):** `#FF4757` — Indikator password lemah, aksi hapus/reset.
* **Cyan Sky (Utility/Info):** `#00D2FF` — Tombol copy, badge informasi, info tambahan.

### B. Base & Neutral Colors
* **Pure Black (Border & Hard Shadow):** `#000000` — Wajib untuk border dan bayangan.
* **Canvas Background (Light Mode):** `#F4F0EA` (Off-white / Warm Gray).
* **Card Surface:** `#FFFFFF` (Putih murni untuk menjaga legibilitas data).
* **Canvas Background (Dark Neobrutalism):** `#18181B` dengan aksen `#000000` border & neon accents.

---

## 3. Tipografi (Typography)

* **Font Family Utama:** *Plus Jakarta Sans* / *Lexend* / *Space Grotesk* / *Inter*
* **Font Family Kode/Password:** *JetBrains Mono* / *Fira Code* (Font monospaced untuk kredensial & password).

| Element | Size / Line Height | Weight | Style |
| :--- | :--- | :--- | :--- |
| **H1 (Screen Titles)** | 28px / 34px | Black (900) | Uppercase / Bold |
| **H2 (Section Headers)** | 20px / 26px | Extra Bold (800) | Normal |
| **Body (Labels/Text)** | 14px / 20px | Medium (500) | Normal |
| **Password Display** | 16px / 22px | Bold (700) | Monospace |
| **Button Text** | 16px / 20px | Heavy (800) | Uppercase |

---

## 4. Spesifikasi Elemen UI (UI Component Specs)

### A. Kartu Kredensial (Credential Card)
* **Background:** `#FFFFFF`
* **Border:** `3px solid #000000`
* **Border Radius:** `12px`
* **Box Shadow:** `4px 4px 0px #000000`
* **Padding:** `16px`

### B. Tombol Utama (Primary Button)
* **Background:** `#FFE600`
* **Text Color:** `#000000`
* **Border:** `3px solid #000000`
* **Border Radius:** `8px`
* **Box Shadow (Default):** `5px 5px 0px #000000`
* **Box Shadow (Pressed):** `0px 0px 0px #000000` *(translate: offset X: 5px, Y: 5px saat ditekan)*

### C. Input Field (Master Password / Search)
* **Background:** `#FFFFFF`
* **Border:** `3px solid #000000`
* **Border Radius:** `8px`
* **Box Shadow (Focused):** `4px 4px 0px #8B5CF6` (Aksen ungu)
* **Placeholder Color:** `#71717A`

---

## 5. Implementasi Flutter (Reusable Widget Specs)

Berikut adalah struktur panduan pembuatan komponen kustom Neobrutalism pada Flutter.

### Implementation Example: `NeobrutalContainer`

```dart
import 'package:flutter/material.dart';

class NeobrutalContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Offset shadowOffset;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const NeobrutalContainer({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black,
    this.borderWidth = 3.0,
    this.shadowOffset = const Offset(4, 4),
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid Shadow Layer
        Positioned.fill(
          child: Container(
            margin: EdgeInsets.only(
              left: shadowOffset.dx,
              top: shadowOffset.dy,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
        // Main Foreground Card
        Container(
          margin: EdgeInsets.only(
            right: shadowOffset.dx,
            bottom: shadowOffset.dy,
          ),
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}