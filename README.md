# cheesera 🎞️

A minimalist, tactile analog film simulation and camera roll photo editor mobile app for iOS and Android.

Inspired by vintage analog rangefinders and darkroom chemistry, **cheesera** provides zero-latency real-time film simulation, before/after comparison scrubbing, silver halide grain synthesis, custom 3D `.cube` LUT processing, Fujifilm recipe management, a **Disposable Camera** capture mode, a **Shake-to-Develop** chemical darkroom workflow, and export to camera roll.

---

## ✨ Features

- **100% Out-of-the-Box Zero-File Operation**: Built-in default film simulation presets (Kodak Portra 400, Kodak Tri-X 400, CineStill 800T, Fujifilm Classic Chrome, Kodak Ektachrome E100, Ilford HP5 Plus, Kodak Gold 200, Cheesera Velvet) and procedural sample photos so the app works immediately upon first launch without requiring network or external asset downloads.
- **📷 Disposable Camera Mode**:
  - Tactile vintage chassis with optical viewfinder, crosshair framing, and flash capacitor ready indicator.
  - Flash modes (`OFF`, `ON`, `AUTO`) with realistic flash burst simulation.
  - **Mechanical Exposure Counter**: Top LCD displaying remaining frames `[ 27 ]` down to `[ 00 ]`.
  - **Thumb Advance Winder Mechanism**: Rotating winder gear with ratcheting tick sounds & haptics; must advance film before each shot.
  - Direct "Develop Roll" seal button bringing finished rolls straight to the darkroom tank.
- **🧪 Shake-to-Develop Darkroom Workflow**:
  - Queue negatives into a 15-minute chemical developing bath tank.
  - **Physical Device Shake Agitation**: Uses `sensors_plus` to monitor accelerometer G-force; shaking the phone agitates chemicals with liquid bubble animation and haptics (plus on-screen manual "Agitate Tank" button for non-sensor environments).
  - **Persistent Progress**: Countdown timer (`14:58 REMAINING`) and developing state persist across app backgrounding and full phone restarts (`darkroom_queue.json`).
  - **⚡ Dev/Testing Toggle**: Includes an instant-complete skip toggle (`⚡ DEV: SKIP 15M` / `instantCompleteDev()`) directly accessible in the darkroom UI and service to immediately complete the 15-minute timer during development and testing.
  - Developing negatives start milky and gradually reveal sharpness and color before final release to the main feed.
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
