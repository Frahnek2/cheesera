# cheesera 🎞️

A minimalist, tactile analog film simulation, automated ingestion, and camera roll photo editor mobile app for iOS and Android.

Inspired by vintage analog rangefinders, physical darkrooms, and high-speed professional photofinishing labs, **cheesera** provides zero-latency real-time film simulation, before/after comparison scrubbing, custom 3D `.cube` LUT processing, Fujifilm recipe management, a **Disposable Camera** capture mode, a **Shake-to-Develop** chemical darkroom workflow, a **Watched Folder** automated ingestion service, and an **SD Card / Camera Fast-Triage** culling station.

---

## ✨ Features

- **100% Out-of-the-Box Zero-File Operation**: Built-in default film simulation presets (Kodak Portra 400, Kodak Tri-X 400, CineStill 800T, Fujifilm Classic Chrome, Kodak Ektachrome E100, Ilford HP5 Plus, Kodak Gold 200, Cheesera Velvet) and procedural sample photos so the app works immediately upon first launch without requiring network or external asset downloads.
- **📁 Watched Folder Auto-Ingestion**:
  - Monitors a user-selected directory or camera drop folder in the background.
  - **Rule-Based Chemistry Assignment**: Automatically matches files based on criteria:
    * Filename patterns (`(?i)^DSCF.*` -> Classic Chrome, `.*night.*` -> CineStill 800T, `.*mono.*` -> Tri-X 400).
    * Time of day (e.g. Golden hour 17h-20h -> Portra 400).
    * File extensions (`.jpg`, `.dng`, `.raw`).
  - Auto-attaches tags, develops, and adds photos directly to the main feed with zero manual interaction.
  - Live activity log and background monitoring toggle.
- **⚡ Camera / SD / SDHC Import & Fast Triage**:
  - Automatically detects connected removable storage (SD Cards, USB-C OTG cameras, DCIM folders) via `PlatformMediaSourceAdapter` and Storage Access Framework (SAF) tree picker.
  - **High-Speed Culling Deck**:
    * Tactile actions: **KEEP (✓)**, **REJECT (✗)**, **FLAG/MAYBE (★)**.
    * **Quick Recipe Apply Ribbon**: Grade photos on-the-fly or long-press to batch apply a recipe across all selected KEEPS!
    * Batch Ingestion: One-tap import of all approved keeps directly into the gallery.
- **📷 Disposable Camera Mode**:
  - Tactile vintage chassis with optical viewfinder, crosshair framing, and flash capacitor ready indicator.
  - Flash modes (`OFF`, `ON`, `AUTO`) with realistic flash burst simulation.
  - **Mechanical Exposure Counter**: Top LCD displaying remaining frames `EXP [ 27 ]` down to `[ 00 ]`.
  - **Thumb Advance Winder Mechanism**: Rotating winder gear with mechanical ratchet sound and haptic ticks; must advance film before each shot.
  - Direct "Develop Roll" seal button bringing finished rolls straight to the darkroom tank.
- **🧪 Shake-to-Develop Darkroom Workflow**:
  - Queue negatives into a 15-minute chemical developing bath tank.
  - **Physical Device Shake Agitation**: Uses `sensors_plus` to monitor accelerometer G-force; shaking the phone agitates chemicals with liquid bubble animation and haptics (plus on-screen manual "Agitate Tank" button for non-sensor environments).
  - **Persistent Progress**: Countdown timer (`14:58 REMAINING`) and developing state persist across app backgrounding and full phone restarts (`darkroom_queue.json`).
  - **⚡ Dev/Testing Toggle**: Includes an instant-complete skip toggle (`⚡ DEV: SKIP 15M` / `instantCompleteDev()`) directly accessible in the darkroom UI and service to immediately complete the 15-minute timer during development and testing.
- **Custom 3D .cube LUT Engine**:
  - Parse, validate, and apply standard Adobe `.cube` files (17x17x17, 33x33x33, 65x65x65).
  - In-memory caching and 3D trilinear interpolation (`sample(r, g, b)`).
  - `LutManager` with file picker import directly from device storage.
- **Fujifilm Camera Recipes (Fuji X Weekly Compatible)**:
  - Supports iconic camera parameters: Dynamic Range (DR100/200/400), Highlight & Shadow Tones (-2 to +4), Color Saturation (-4 to +4), Sharpness, Noise Reduction, Clarity, Grain Roughness & Size (Off/Weak/Strong, Small/Large), Color Chrome Effect, Color Chrome FX Blue, and White Balance Shift (Red / Blue).
- **RecipeProvider with Remote Sync & Offline Fallback**:
  - Three-tier resilient architecture: Remote X Weekly API -> Offline Disk Cache -> Built-in Defaults.
- **Photo Editor & Preview Screen**:
  - Interactive **Before / After Split Slider** with draggable tactile center divider.
  - Quick **"HOLD: RAW"** thumb button for immediate comparison against untouched negative.
  - Multi-aspect ratio framing (3:2 35mm, 4:5 Large Format, 1:1 Square, 65:24 X-Pan).
- **Export to Camera Roll**: Renders full-resolution images with real-time color grading, Box-Muller Gaussian grain synthesis, optical vignette falloff, and saves directly to the native device Camera Roll (`Cheesera` album) or system share sheet.

---

## 📱 Platform Permissions & OS Manifest Requirements

### 🤖 Android (`android/app/src/main/AndroidManifest.xml`)

| Permission / Flag | Purpose |
|---|---|
| `<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>` | Standard photo library access on Android 13+ (API 33+). |
| `<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>` | Legacy external storage read for Android 12 and below. |
| `<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29"/>` | Legacy camera roll write for Android 10 and below. |
| `<uses-permission android:name="android.permission.CAMERA"/>` | Capturing photos in Disposable and standard camera modes. |
| `<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>` | Direct filesystem access for external SD cards (`/storage/XXXX-XXXX`) and USB-C OTG card readers. |
| `<uses-feature android:name="android.hardware.usb.host" android:required="false"/>` | Enables USB-C camera card readers and tethered cameras. |
| `android:requestLegacyExternalStorage="true"` | Allows smooth file access when targeting Android 10/11. |

> **Note on Storage Access Framework (SAF)**: On modern Android versions (11+), Cheesera uses `ACTION_OPEN_DOCUMENT_TREE` via the directory picker, allowing users to grant scoped access to external camera SD cards without requiring full root disk privileges.

### 🍎 iOS (`ios/Runner/Info.plist`)

| Key | Value | Purpose |
|---|---|---|
| `NSCameraUsageDescription` | `String` | Explains camera usage for shooting analog photographs. |
| `NSPhotoLibraryUsageDescription` | `String` | Reading photos from the user's Photos library. |
| `NSPhotoLibraryAddUsageDescription` | `String` | Saving developed film negatives into the native Camera Roll. |
| `UIFileSharingEnabled` | `<true/>` | Exposes the app's document folder in the iOS Files app and Finder. |
| `LSSupportsOpeningDocumentsInPlace` | `<true/>` | **Critical for SD cards**: Allows the document picker to open and monitor external SD cards and USB-C drives connected via Apple's Lightning/USB-C Camera Adapter. |
| `UISupportsDocumentBrowser` | `<true/>` | Enables the system document browser for directory selection. |

---

## 🏛️ Clean Architecture Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart             # Darkroom obsidian, amber & film badge tones
│   │   └── app_typography.dart         # Monospace metadata & Swiss editorial text styles
│   ├── theme/
│   │   └── app_theme.dart              # Darkroom system theme & navigation styling
│   └── utils/
│       ├── haptics_util.dart           # Tactile dial ticks, snaps, and shutter haptics
│       └── sample_images_data.dart     # Procedural synthetic photographs (zero assets needed)
├── models/
│   ├── disposable_roll.dart            # Disposable 27-exposure roll model
│   ├── film_preset.dart                # Built-in iconic film stocks & 4x5 grading matrices
│   ├── film_recipe.dart                # Continuous + authentic Fujifilm camera recipe model
│   └── photo_item.dart                 # Negative item model with metadata & frame ratios
├── services/
│   ├── darkroom/
│   │   ├── darkroom_models.dart        # DevelopingBatch model with persistence & progress
│   │   ├── darkroom_service.dart       # Chemical tank queue, 15m timer & dev skip toggle
│   │   └── shake_detector.dart         # Accelerometer shake gesture listener (sensors_plus)
│   ├── external_media/
│   │   ├── media_volume.dart           # MediaVolume model (SD cards, USB cameras, DCIM)
│   │   └── media_source_adapter.dart   # Platform adapter + SAF picker + mock adapter
│   ├── film_engine/
│   │   ├── cube_lut.dart               # Lut3D data model with 3D trilinear interpolation
│   │   ├── cube_lut_parser.dart        # Adobe .cube file parser (scientific notation, comments)
│   │   ├── lut_processor.dart          # LutProcessor interface & default implementation
│   │   ├── lut_manager.dart            # Manages bundled & user-imported custom .cube LUTs
│   │   ├── color_matrix_utils.dart     # Fast GPU ColorFilter 4x5 composite matrix math
│   │   └── film_engine.dart            # Full rendering pipeline (isolate-backed export)
│   ├── recipe_service/
│   │   ├── recipe_serializer.dart      # JSON & Fuji X Weekly string parser/serializer
│   │   ├── recipe_remote_adapter.dart  # X Weekly remote fetch adapter with error resilience
│   │   ├── recipe_cache_storage.dart   # Offline disk cache persistence
│   │   └── recipe_provider.dart        # Reactive state provider with 3-tier fallback
│   ├── storage/
│   │   └── export_service.dart         # Camera roll saver (Gal) & fallback share sheet
│   ├── watched_folder/
│   │   ├── watched_folder_models.dart  # IngestionCriteria, IngestionRule & Config
│   │   ├── ingestion_rule_engine.dart  # Evaluates file names/dates/patterns to match recipes
│   │   └── watched_folder_service.dart # File system watcher & periodic polling service
│   └── media/
│       └── photo_service.dart          # Camera & gallery picker + sample photo seeder
├── widgets/
│   ├── tactile_button.dart             # Depressible tactile button with micro-haptics
│   ├── tactile_slider.dart             # Slider with 0.0 center detent snap & numerical readout
│   ├── grain_canvas.dart               # Real-time procedural silver halide grain overlay
│   ├── before_after_slider.dart        # Draggable before/after comparison slider
│   └── film_frame_card.dart            # Analog negative card with film rebate details
└── features/
    ├── darkroom/
    │   └── presentation/
    │       └── darkroom_screen.dart    # Chemical bath tank, countdown timer & dev skip toggle
    ├── disposable_camera/
    │   └── presentation/
    │       └── disposable_camera_screen.dart # Viewfinder, counter [27], flash & winder
    ├── triage/
    │   └── presentation/
    │       └── fast_triage_screen.dart # SD card rapid KEEP/REJECT/FLAG triage deck
    ├── watched_folder/
    │   └── presentation/
    │       └── watched_folder_screen.dart # Folder monitoring configuration & activity log
    ├── home/
    │   └── presentation/
    │       ├── home_screen.dart        # Gallery feed with camera & library import
    │       └── widgets/
    │           ├── home_header.dart
    │           └── recipe_catalog_sheet.dart
    └── editor/
        └── presentation/
            ├── editor_screen.dart      # Tactile photo editor & live preview
            └── widgets/
                ├── preset_strip.dart
                ├── recipe_adjustment_sheet.dart
                ├── film_hud_overlay.dart
                └── export_modal.dart
```

---

## 🧪 Unit Tests

- `test/ingestion_triage_test.dart`:
  - `IngestionRuleEngine` matching `DSCF*.jpg` to Classic Chrome with camera tags.
  - Matching night neon keywords to CineStill 800T.
  - Fallback logic when no specific rules match.
  - `MockMediaSourceAdapter` volume detection and photo enumeration.
- `test/darkroom_service_test.dart`:
  - Disposable roll exposure decrementing (27 exposures max, remaining countdown).
  - 15-minute chemical developing batch queue and progress calculations.
  - Shake agitation counter increments and haptics.
  - **Dev instant-complete toggle (`instantCompleteDev`) test**: Verifies 15-minute timer finishes immediately when triggered.
  - Persistent queue JSON serialization across app restarts.
- `test/cube_lut_test.dart`:
  - 3D Trilinear interpolation math at corners and midpoints.
  - Adobe `.cube` specification compliance: comments, scientific notation (`1.0e+00`), `DOMAIN_MIN/MAX`.
  - Rejection of 1D LUTs with informative error.
  - Custom LUT byte parsing and registration in `LutManager`.
- `test/recipe_serializer_test.dart`:
  - Bidirectional JSON serialization of continuous and Fujifilm camera parameters.
  - Parsing real-world Fuji X Weekly community recipe strings.
- `test/recipe_provider_test.dart`:
  - Remote sync and offline cache write verification.
  - Network unreachable fallback to local offline cache.
  - Corrupted cache fallback to built-in defaults.
