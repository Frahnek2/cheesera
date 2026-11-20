import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'cube_lut.dart';
import 'cube_lut_parser.dart';
import 'lut_processor.dart';

enum LutSource { bundled, userImported }

class LutMetadata {
  final String id;
  final String title;
  final LutSource source;
  final int size;
  final String? assetPath;
  final String? filePath;

  const LutMetadata({
    required this.id,
    required this.title,
    required this.source,
    required this.size,
    this.assetPath,
    this.filePath,
  });
}

/// Manages both bundled and user-imported 3D .cube LUTs with in-memory caching.
class LutManager {
  final LutProcessor lutProcessor;
  final Map<String, Lut3D> _cache = {};
  final List<LutMetadata> _registry = [];

  LutManager({
    LutProcessor? lutProcessor,
  }) : lutProcessor = lutProcessor ?? const DefaultLutProcessor() {
    _registerBundledLuts();
  }

  List<LutMetadata> get availableLuts => List.unmodifiable(_registry);

  void _registerBundledLuts() {
    _registry.addAll([
      const LutMetadata(
        id: 'lut_portra_sample',
        title: 'Portra 400 (Bundled 3D)',
        source: LutSource.bundled,
        size: 2,
        assetPath: 'assets/luts/portra_sample.cube',
      ),
      const LutMetadata(
        id: 'lut_classic_chrome',
        title: 'Classic Chrome (Bundled 3D)',
        source: LutSource.bundled,
        size: 2,
        assetPath: 'assets/luts/classic_chrome.cube',
      ),
      const LutMetadata(
        id: 'lut_fuji_eterna',
        title: 'Eterna Cinema (Bundled 3D)',
        source: LutSource.bundled,
        size: 2,
        assetPath: 'assets/luts/fuji_eterna.cube',
      ),
    ]);
  }

  /// Loads and caches a LUT by ID.
  Future<Lut3D?> getLut(String id) async {
    if (_cache.containsKey(id)) {
      return _cache[id]!;
    }

    final meta = _registry.firstWhere(
      (m) => m.id == id,
      orElse: () => throw ArgumentError('LUT with ID $id not found in registry.'),
    );

    Lut3D? parsed;
    if (meta.source == LutSource.bundled && meta.assetPath != null) {
      try {
        final content = await rootBundle.loadString(meta.assetPath!);
        parsed = CubeLutParser.parse(content);
      } catch (_) {
        // Fallback if running outside full Flutter asset bundle
        parsed = Lut3D.identity(size: meta.size, title: meta.title);
      }
    } else if (meta.filePath != null) {
      final file = File(meta.filePath!);
      if (await file.exists()) {
        final content = await file.readAsString();
        parsed = CubeLutParser.parse(content);
      }
    }

    if (parsed != null) {
      _cache[id] = parsed;
    }
    return parsed;
  }

  /// Manually registers an in-memory or dynamically parsed Lut3D.
  void registerCustomLut(String id, Lut3D lut, {String? filePath}) {
    _cache[id] = lut;
    _registry.removeWhere((m) => m.id == id);
    _registry.add(
      LutMetadata(
        id: id,
        title: lut.title,
        source: LutSource.userImported,
        size: lut.size,
        filePath: filePath,
      ),
    );
  }

  /// Imports a user .cube LUT from raw bytes with a custom title.
  LutMetadata importLutFromBytes({
    required Uint8List bytes,
    required String filename,
    String? customTitle,
  }) {
    final lut = CubeLutParser.parseBytes(bytes);
    final id = 'custom_lut_${DateTime.now().millisecondsSinceEpoch}';
    final effectiveTitle = customTitle ?? (lut.title.isNotEmpty ? lut.title : filename);

    final finalLut = Lut3D(
      title: effectiveTitle,
      size: lut.size,
      domainMin: lut.domainMin,
      domainMax: lut.domainMax,
      table: lut.table,
    );

    registerCustomLut(id, finalLut);
    return _registry.firstWhere((m) => m.id == id);
  }

  /// Prompts the user to pick a custom .cube file from device storage, parses and stores it.
  Future<LutMetadata?> pickAndImportCustomLut() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['cube'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;
      final file = result.files.first;

      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }
      if (bytes == null) return null;

      // Copy to persistent documents directory
      String? savedPath;
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        final lutsDir = Directory('${docsDir.path}/custom_luts');
        if (!await lutsDir.exists()) {
          await lutsDir.create(recursive: true);
        }
        savedPath = '${lutsDir.path}/${file.name}';
        await File(savedPath).writeAsBytes(bytes);
      } catch (_) {
        // Fallback: in-memory only
      }

      final meta = importLutFromBytes(
        bytes: bytes,
        filename: file.name,
      );

      if (savedPath != null) {
        _registry.removeWhere((m) => m.id == meta.id);
        _registry.add(
          LutMetadata(
            id: meta.id,
            title: meta.title,
            source: LutSource.userImported,
            size: meta.size,
            filePath: savedPath,
          ),
        );
      }

      return meta;
    } catch (e) {
      return null;
    }
  }

  /// Applies a 3D LUT to an image buffer at the specified intensity.
  Future<Uint8List> applyLutToImage({
    required Uint8List sourceImageBytes,
    required String lutId,
    double intensity = 1.0,
  }) async {
    final lut = await getLut(lutId);
    if (lut == null) return sourceImageBytes;
    return lutProcessor.applyLut(
      sourceImageBytes: sourceImageBytes,
      lut: lut,
      intensity: intensity,
    );
  }
}
