# cheesera 🎞️

A minimalist, tactile analog film simulation and camera roll photo editor mobile app for iOS and Android.

Inspired by vintage analog rangefinders and darkroom chemistry, **cheesera** provides zero-latency real-time film simulation, before/after comparison scrubbing, silver halide grain synthesis, custom 3D `.cube` LUT processing, Fujifilm recipe management, and export to camera roll.

---

## ✨ Features

- **100% Out-of-the-Box Zero-File Operation**: Built-in default film simulation presets (Kodak Portra 400, Kodak Tri-X 400, CineStill 800T, Fujifilm Classic Chrome, Kodak Ektachrome E100, Ilford HP5 Plus, Kodak Gold 200, Cheesera Velvet) and procedural sample photos so the app works immediately upon first launch without requiring network or external asset downloads.
- **Custom 3D .cube LUT Engine**:
  - **Bundled & User-Imported LUTs**: Parse, validate, and apply any standard Adobe `.cube` file (e.g. 17x17x17, 33x33x33, 65x65x65).
  - Fast in-memory caching and 3D trilinear interpolation (`sample(r, g, b)`).
  - Integrated `LutManager` with file picker import directly from device storage.
- **Fujifilm Camera Recipes (Fuji X Weekly Compatible)**:
  - Supports all iconic camera parameters: Dynamic Range (DR100/DR200/DR400), Highlight & Shadow Tones (-2 to +4), Color Saturation (-4 to +4), Sharpness, Noise Reduction, Clarity, Grain Roughness & Size (Off/Weak/Strong, Small/Large), Color Chrome Effect, Color Chrome FX Blue, and White Balance Shift (Red / Blue).
  - Save custom recipes to local vault with custom names and authors.
- **RecipeProvider with Remote Sync & Offline Fallback**:
  - Three-tier resilient architecture:
    1. **Remote X Weekly Adapter**: Fetches community recipes from remote JSON/API feeds.
    2. **Offline Disk Cache**: Persists recipes locally so the app is always fully functional offline without internet.
    3. **Built-in Defaults**: Falls back gracefully to pre-calibrated defaults if offline or if remote parsing fails.
- **Photo Editor & Preview Screen**:
  - Interactive **Before / After Split Slider** with draggable tactile center divider.
  - Quick **"HOLD: RAW"** thumb button for immediate comparison against the untouched negative.
  - Horizontal **Film Cassette Strip** for instant preset switching.
  - **Chemistry & Optics Drawer**: Tabs for continuous color grading, authentic Fujifilm camera parameters, and 3D .cube LUT selection.
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
│   ├── film_preset.dart                # Built-in iconic film stocks & 4x5 grading matrices
│   ├── film_recipe.dart                # Continuous + authentic Fujifilm camera recipe model
│   └── photo_item.dart                 # Negative item model with metadata & frame ratios
├── services/
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
    ├── home/
    │   └── presentation/
    │       ├── home_screen.dart        # Gallery feed with camera & library import
    │       └── widgets/
    │           ├── home_header.dart
    │           └── recipe_catalog_sheet.dart # Recipe vault with X Weekly sync indicator
    └── editor/
        └── presentation/
            ├── editor_screen.dart      # Tactile photo editor & live preview
            └── widgets/
                ├── preset_strip.dart
                ├── recipe_adjustment_sheet.dart # Continuous, Fuji & 3D LUT controls
                ├── film_hud_overlay.dart
                └── export_modal.dart
```

---

## 📦 Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  image: ^4.2.0           # Bitmap manipulation, grain synthesis, and export
  image_picker: ^1.1.2    # Camera capture and photo library import
  file_picker: ^8.0.0     # Importing custom .cube 3D LUT files from storage
  gal: ^2.3.1             # Direct export to native Camera Roll / Photos album
  share_plus: ^10.0.0     # Native system share sheet fallback
  path_provider: ^2.1.4   # Local cache & document storage
  http: ^1.2.0            # Remote fetching from X Weekly community APIs
  cupertino_icons: ^1.0.8 # iOS styled iconography
```

---

## 🧪 Unit Tests

- `test/cube_lut_test.dart`:
  - 3D Trilinear interpolation math at corners and midpoints.
  - Adobe `.cube` specification compliance: comments, scientific notation (`1.0e+00`), `DOMAIN_MIN/MAX`.
  - Rejection of 1D LUTs with informative error.
  - Error detection on data size/table count mismatches.
  - Custom LUT byte parsing and registration in `LutManager`.
- `test/recipe_serializer_test.dart`:
  - Bidirectional JSON serialization of continuous and Fujifilm camera parameters.
  - Graceful fallback on malformed or empty payloads.
  - Parsing real-world Fuji X Weekly community recipe strings.
- `test/recipe_provider_test.dart`:
  - Successful remote sync and offline cache write.
  - Network unreachable fallback to local offline cache.
  - Corrupted cache fallback to built-in defaults.
  - Saving and deleting custom user recipes.
