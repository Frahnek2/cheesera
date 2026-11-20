# cheesera 🎞️

A minimalist, tactile analog film simulation, automated ingestion, on-device local LLM curation, and camera roll photo editor mobile app for iOS and Android.

Inspired by vintage analog rangefinders, physical darkrooms, and high-speed professional photofinishing labs, **cheesera** provides zero-latency real-time film simulation, before/after comparison scrubbing, custom 3D `.cube` LUT processing, Fujifilm recipe management, a **Disposable Camera** capture mode, a **Shake-to-Develop** chemical darkroom workflow, a **Watched Folder** automated ingestion service, an **SD Card / Camera Fast-Triage** culling station, and **On-Device Local LLM Curation**.

---

## ✨ Features

- **100% Out-of-the-Box Zero-File Operation**: Built-in default film simulation presets (Kodak Portra 400, Kodak Tri-X 400, CineStill 800T, Fujifilm Classic Chrome, Kodak Ektachrome E100, Ilford HP5 Plus, Kodak Gold 200, Cheesera Velvet) and procedural sample photos so the app works immediately upon first launch without requiring network or external asset downloads.
- **🧠 On-Device Local LLM Curation (`LlmCurationService`)**:
  - **Single Photo Recipe Suggestion**: Analyzes on-device image measurements (Kelvin temperature, luminance, contrast, warmth, and dominant tones) and recommends the optimal film simulation recipe with human-like photographic rationale (e.g. recommending CineStill 800T for tungsten night shots or Portra 400 for golden hour skin tones).
  - **Natural Language Batch Curation**: Given an open-ended prompt (e.g. *"warm golden hour vibe"*, *"punchy street colors"*, *"minimalist compositions"*, *"moody night neon"*), ranks and filters contact sheet candidates, auto-selecting the best frames and applying matching recipes.
  - **Resilient Fallback Engine**: If no local model weights file is loaded yet, automatically falls back to an expert rule-based photographic heuristic engine with zero latency, zero internet connectivity, and zero cloud API keys needed.
  - **GGUF / MediaPipe Model Support**: Load quantized models (e.g. `SmolLM2-1.7B-Q4_K_M.gguf`, `Llama-3.2-1B-Instruct-Q4_K_M.gguf`, `Gemma-2-2B.gguf`) directly via the built-in model manager.
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

## 🤖 On-Device Local LLM Setup & Instructions

Cheesera runs 100% on-device local models without sending photos or data to third-party clouds.

### Recommended Quantized Models
- **`SmolLM2-1.7B-Instruct-Q4_K_M.gguf`** (~1.0 GB) — Fast inference, low memory footprint, excellent photographic reasoning.
- **`Llama-3.2-1B-Instruct-Q4_K_M.gguf`** (~800 MB) — Ultra-compact, instant cold-start on mobile.
- **`Gemma-2-2B-it-Q4_K_M.gguf`** (~1.4 GB) — Rich descriptive reasoning for creative batch culling.

### Android Setup Instructions
1. Download any compatible `.gguf` quantized model file to your Android device (e.g. to your `Download` or `Documents` directory).
2. In Cheesera, tap the **Chip Icon (`[ ]`)** in the top navigation bar to open **On-Device Local LLM Setup**.
3. Tap **"LOAD LOCAL .GGUF / .BIN MODEL FILE"** and select the downloaded file.
4. Cheesera validates the GGUF header and mounts the weights for on-device inference using your device's CPU/NPU (Qualcomm QNN / MediaPipe OpenCL acceleration).

### iOS Setup Instructions
1. AirDrop the `.gguf` file to your iPhone or iPad, or copy it into the Cheesera app directory in the native **Files app** (`On My iPhone > Cheesera`).
2. In Cheesera, tap the **Chip Icon** in the top bar.
3. Tap **"LOAD LOCAL .GGUF / .BIN MODEL FILE"** and pick the model from the system Document Browser.
4. The model runs using unified memory on Apple Silicon (A16/A17 Pro/M-series chips) with Apple Metal performance shaders.

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

### 🍎 iOS (`ios/Runner/Info.plist`)

| Key | Value | Purpose |
|---|---|---|
| `NSCameraUsageDescription` | `String` | Explains camera usage for shooting analog photographs. |
| `NSPhotoLibraryUsageDescription` | `String` | Reading photos from the user's Photos library. |
| `NSPhotoLibraryAddUsageDescription` | `String` | Saving developed film negatives into the native Camera Roll. |
| `UIFileSharingEnabled` | `<true/>` | Exposes the app's document folder in the iOS Files app and Finder. |
| `LSSupportsOpeningDocumentsInPlace` | `<true/>` | Allows the document picker to open and monitor external SD cards, USB-C drives, and local GGUF models. |
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
│   ├── llm/
│   │   ├── llm_models.dart             # RecipeSuggestionResult, BatchCurationResult, ImageAnalysisMetadata
│   │   ├── image_feature_extractor.dart# On-device visual & histogram analysis (warmth, contrast, temp)
│   │   ├── heuristic_curation_engine.dart # Photographic rule engine fallback (active when no model loaded)
│   │   ├── local_llm_adapter.dart      # GGUF model loader & prompt formatter
│   │   ├── llm_curation_service.dart   # Abstract LlmCurationService interface
│   │   └── default_llm_curation_service.dart # Production coordinator with seamless fallback
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
    ├── llm/
    │   └── presentation/
    │       └── widgets/
    │           ├── ai_recipe_suggestion_sheet.dart # AI suggestion modal with reason & apply button
    │           ├── ai_batch_curation_dialog.dart   # Prompt input with presets & ranking output
    │           └── local_model_settings_sheet.dart # Model file picker & setup instructions (iOS & Android)
    ├── triage/
    │   └── presentation/
    │       └── fast_triage_screen.dart # SD card rapid KEEP/REJECT/FLAG triage deck + AI Curation
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

- `test/llm_curation_service_test.dart`:
  - `ImageFeatureExtractor` testing golden hour vs night neon vs studio portrait detection.
  - `suggestRecipe` testing Portra 400 for golden hour and CineStill 800T for tungsten night.
  - `curateBatch` testing user prompt matching (*"warm golden hour vibe"*, *"moody night neon"*).
  - Model load/unload lifecycle and fallback verification.
- `test/ingestion_triage_test.dart`:
  - `IngestionRuleEngine` matching `DSCF*.JPG` -> Fujifilm Classic Chrome with tags.
  - Matching night keywords (`*night*`) -> CineStill 800T.
  - Fallback logic to Portra 400 on unmatched files.
  - `MockMediaSourceAdapter` volume discovery and external media enumeration.
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
