# cheesera 🎞️

A minimalist, tactile analog film simulation and camera roll photo editor mobile app for iOS and Android.

Inspired by vintage analog rangefinders and darkroom chemistry, **cheesera** provides zero-latency real-time film simulation, before/after comparison scrubbing, silver halide grain synthesis, and export to camera roll.

---

## ✨ Features

- **100% Out-of-the-Box Zero-File Operation**: Built-in default film simulation presets (Kodak Portra 400, Kodak Tri-X 400, CineStill 800T, Fujifilm Classic Chrome, Kodak Ektachrome E100, Ilford HP5 Plus, Kodak Gold 200, Cheesera Velvet) and procedural sample photos so the app works immediately upon first launch without requiring network or external asset downloads.
- **Home Gallery & Feed View**: Tactile analog film negative feed showing film codes, ISO ratings, aspect ratios, and custom recipes.
- **Photo Editor & Preview Screen**:
  - Interactive **Before / After Split Slider** with draggable tactile center divider.
  - Quick **"HOLD: RAW"** thumb button for immediate comparison against the untouched negative.
  - Horizontal **Film Cassette Strip** for instant preset switching.
  - **Chemistry & Optics Drawer**: Fine-tune exposure compensation, contrast, color temperature / warmth, tint (green/magenta), silver halide grain amount/size, matte shadow fade, and optical vignette.
  - Multi-aspect ratio framing (3:2 35mm, 4:5 Large Format, 1:1 Square, 65:24 X-Pan).
- **Export to Camera Roll**: Renders full-resolution images with real-time color grading, Box-Muller Gaussian grain synthesis, optical vignette falloff, and saves directly to the native device Camera Roll (`Cheesera` album) or system share sheet.
- **Clear FilmEngine & LutProcessor Abstraction**:
  - `Lut3D`: Grid table supporting trilinear interpolation for 3D LUTs.
  - `CubeLutParser`: Full parser for Adobe `.cube` specification files.
  - `LutProcessor`: Abstract contract allowing plug-and-play addition of GPU fragment shaders, CPU SIMD, or external `.cube` files.
  - `ColorMatrixUtils`: 4x5 composite GPU matrix calculations for 60/120 FPS buttery smooth real-time scrubbing.
- **Tactile Minimalism**: Darkroom obsidian aesthetic (`#0D0E11`), micro-haptics (`HapticFeedback` tick and detent snaps), and uncluttered Swiss typography.

---

## 🏛️ Clean Architecture Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # Darkroom obsidian, amber & film badge tones
│   │   └── app_typography.dart     # Monospace metadata & Swiss editorial text styles
│   ├── theme/
│   │   └── app_theme.dart          # Darkroom system theme & navigation styling
│   └── utils/
│       ├── haptics_util.dart       # Tactile dial ticks, snaps, and shutter haptics
│       └── sample_images_data.dart # Procedural synthetic photographs (zero assets needed)
├── models/
│   ├── film_preset.dart            # Built-in iconic film stocks & 4x5 grading matrices
│   ├── film_recipe.dart            # Recipe state (exposure, warmth, grain, vignette)
│   └── photo_item.dart             # Negative item model with metadata & frame ratios
├── services/
│   ├── film_engine/
│   │   ├── cube_lut.dart           # Lut3D data model with 3D trilinear interpolation
│   │   ├── cube_lut_parser.dart    # Adobe .cube file parser
│   │   ├── lut_processor.dart      # LutProcessor interface & default implementation
│   │   ├── color_matrix_utils.dart # Fast GPU ColorFilter 4x5 composite matrix math
│   │   └── film_engine.dart        # Full rendering pipeline (isolate-backed export)
│   ├── storage/
│   │   └── export_service.dart     # Camera roll saver (Gal) & fallback share sheet
│   └── media/
│       └── photo_service.dart      # Camera & gallery picker + sample photo seeder
├── widgets/
│   ├── tactile_button.dart         # Depressible tactile button with micro-haptics
│   ├── tactile_slider.dart         # Slider with 0.0 center detent snap & numerical readout
│   ├── grain_canvas.dart           # Real-time procedural silver halide grain overlay
│   ├── before_after_slider.dart    # Draggable before/after comparison slider
│   └── film_frame_card.dart        # Analog negative card with film rebate details
└── features/
    ├── home/
    │   └── presentation/
    │       ├── home_screen.dart    # Gallery feed with camera & library import
    │       └── widgets/
    │           ├── home_header.dart
    │           └── recipe_catalog_sheet.dart
    └── editor/
        └── presentation/
            ├── editor_screen.dart  # Tactile photo editor & live preview
            └── widgets/
                ├── preset_strip.dart
                ├── recipe_adjustment_sheet.dart
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
  gal: ^2.3.1             # Direct export to native Camera Roll / Photos album
  share_plus: ^10.0.0     # Native system share sheet fallback
  path_provider: ^2.1.4   # Temporary file management during export
  cupertino_icons: ^1.0.8 # iOS styled iconography
```

---

## 🚀 Getting Started

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run on iOS Simulator or Device**:
   ```bash
   flutter run -d ios
   ```

3. **Run on Android Emulator or Device**:
   ```bash
   flutter run -d android
   ```

4. **Run Unit Tests**:
   ```bash
   flutter test
   ```

---

## 🔌 Plugging in Full 3D `.cube` LUTs

Cheesera has been architected from day one to support external Adobe `.cube` LUT files.

To parse and apply any `.cube` file:
```dart
import 'package:cheesera/services/film_engine/cube_lut_parser.dart';
import 'package:cheesera/services/film_engine/film_engine.dart';

// 1. Parse .cube string or byte data
final lut3D = CubeLutParser.parse(cubeFileContentString);

// 2. Process an image through the LutProcessor
final processedBytes = await filmEngine.lutProcessor.applyLut(
  sourceImageBytes: originalBytes,
  lut: lut3D,
  intensity: 1.0,
);
```
