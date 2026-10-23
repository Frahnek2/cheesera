#  Cheesera

**Cheesera** is a hybrid mobile photography application for iOS and Android that combines real-time **Fujifilm Film Simulation recipes**, **AI-powered scene detection**, and a retro **Disposable Camera experience**.

Built with a modern cross-platform mobile stack, Cheesera brings the art of analog color science into the modern smartphone workflow.

---

##  Features

### 1.  Instant Editor (Main Feature)
- **Fujifilm Film Simulations:** Render native-style film simulation profiles (*Classic Chrome, Velvia, Provia, Eterna, Acros, and more*) using 3D LUT (`.cube`) hardware acceleration.
- **Custom Recipe Compatibility:** Import and fine-tune custom recipes (compatible with popular web recipes like FujiXWeekly) with parameters for:
  - Highlight & Shadow Tone Curves
  - Exposure Compensation & Dynamic Range
  - Saturation, Sharpness, and Noise Reduction
  - White Balance Shift (Red / Blue offset coordinates)
  - Film Grain intensity and roughness
- **GPU-Accelerated Engine:** Real-time filter previews running on background shader threads for smooth rendering.

### 2.  AI Vibe & Scene Assistant
- **Automatic Scene Analysis:** Uses vision processing to analyze contrast, color palette, lighting conditions, and subject matter (*e.g., Golden Hour, Moody Urban, Portrait*).
- **Smart Recipe Recommendation:** Automatically pairs your photo with the best Fujifilm simulation or custom recipe matching the photo's vibe.

### 3.  Retro Disposable Camera (Secondary Feature)
- **Huji-Style Analog Viewfinder:** Complete with plastic viewfinder UI frame, mechanical shutter sounds, and exposure counters.
- **Delayed "Developing" Queue:** Experience authentic analog anticipation—photos sit in a developing process with options for instant or delayed reveal.
- **Analog Quirks:** Automatically generates subtle vintage date timestamps and randomized light leak effects.

---

##  Tech Stack

- **Framework:** Flutter (Dart)
- **Target Platforms:** iOS & Android
- **Image Processing:** Custom Shaders / Color LUT lookup engines
- **AI Integration:** Vision API / Lightweight On-Device Vision Engine
- **Build & CI/CD:** GitHub Actions / Codemagic

---

##  Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version)
- Android Studio / Xcode (or Linux toolchain setup with `xcross` for iOS deployment)

### Installation & Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Frahnek2/cheesera.git
   cd cheesera
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Add Fujifilm LUT Assets**
   Place your official Fujifilm `.cube` files inside the `assets/luts/` directory:
   ```text
   assets/
   └── luts/
       ├── classic_chrome.cube
       ├── velvia.cube
       └── eterna.cube
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

---

##  Project Structure

```text
cheesera/
├── assets/
│   ├── luts/            # Base 3D LUT (.cube) files
│   ├── recipes/         # Built-in custom JSON recipe definitions
│   └── light_leaks/     # Disposable camera overlay assets
├── lib/
│   ├── core/            # Shaders, LUT parsers, and image pipeline
│   ├── features/
│   │   ├── editor/      # Main Instant Editor UI & sliders
│   │   ├── assistant/   # AI Vibe & Scene Detection logic
│   │   └── disposable/  # Retro viewfinder UI & developing queue
│   └── main.dart
└── pubspec.yaml
```

---

##  License

Copyright (c) 2026 Franciszek Skalski. All rights reserved.

This project is released under a **Proprietary License**. See the [LICENSE](LICENSE) file for usage restrictions and intellectual property details.