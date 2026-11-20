import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ExportResultType {
  savedToGallery,
  openedShareSheet,
  error,
}

class ExportResult {
  final ExportResultType type;
  final String message;
  final String? filePath;

  const ExportResult({
    required this.type,
    required this.message,
    this.filePath,
  });
}

/// Service managing export to camera roll and sharing.
class ExportService {
  ExportService._();

  /// Saves rendered image bytes directly to the device's native Camera Roll / Photos album.
  /// If native gallery access fails or platform is desktop/web, falls back cleanly to system share sheet.
  static Future<ExportResult> exportToCameraRoll(
    Uint8List imageBytes, {
    String filenamePrefix = 'cheesera_film',
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${filenamePrefix}_$timestamp.jpg';

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // Mobile device: attempt saving with Gal to native camera roll
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          final requested = await Gal.requestAccess();
          if (!requested) {
            // User denied gallery write permission -> fallback to share sheet
            await Share.shareXFiles([XFile(filePath)], text: 'Exported with Cheesera Film');
            return ExportResult(
              type: ExportResultType.openedShareSheet,
              message: 'Gallery permission denied. Opened share sheet instead.',
              filePath: filePath,
            );
          }
        }

        await Gal.putImage(filePath, album: 'Cheesera');
        return ExportResult(
          type: ExportResultType.savedToGallery,
          message: 'Saved to Camera Roll in "Cheesera" album.',
          filePath: filePath,
        );
      } else {
        // Desktop / Simulator fallback: share sheet or file path
        await Share.shareXFiles([XFile(filePath)], text: 'Exported with Cheesera Film');
        return ExportResult(
          type: ExportResultType.openedShareSheet,
          message: 'Opened system share sheet.',
          filePath: filePath,
        );
      }
    } catch (e) {
      return ExportResult(
        type: ExportResultType.error,
        message: 'Export failed: $e',
      );
    }
  }

  /// Direct share via system share sheet
  static Future<void> sharePhoto(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/cheesera_share_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    await Share.shareXFiles([XFile(filePath)], text: 'Shot with Cheesera Film Simulation');
  }
}
