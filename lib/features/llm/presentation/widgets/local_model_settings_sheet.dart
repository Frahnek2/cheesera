import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../../../services/llm/llm_curation_service.dart';
import '../../../../widgets/tactile_button.dart';

/// Modal sheet explaining on-device LLM setup instructions for iOS and Android,
/// and allowing selection of local GGUF models.
class LocalModelSettingsSheet extends StatefulWidget {
  final LlmCurationService llmService;

  const LocalModelSettingsSheet({
    super.key,
    required this.llmService,
  });

  @override
  State<LocalModelSettingsSheet> createState() => _LocalModelSettingsSheetState();
}

class _LocalModelSettingsSheetState extends State<LocalModelSettingsSheet> {
  int _selectedTab = 0; // 0: Status & Loader, 1: Android Setup, 2: iOS Setup

  Future<void> _pickModelFile() async {
    HapticsUtil.selectionTick();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gguf', 'bin'],
      );
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          final loaded = await widget.llmService.loadLocalModel(
            modelFilePath: path,
            modelDisplayName: result.files.first.name,
          );
          if (loaded) {
            HapticsUtil.heavyAffirmation();
            setState(() {});
          }
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.llmService;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.memory_rounded, color: AppColors.amberAccent, size: 20),
                const SizedBox(width: 8),
                Text('ON-DEVICE LOCAL LLM SETUP', style: AppTypography.filmHeadline.copyWith(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Runs 100% locally on Apple Neural Engine / Android NPU with zero cloud APIs.',
              style: AppTypography.caption,
            ),
            const Divider(color: AppColors.surfaceBorder, height: 20),

            // Tab bar
            Row(
              children: [
                _buildTab('STATUS & MODEL', 0),
                const SizedBox(width: 6),
                _buildTab('ANDROID SETUP', 1),
                const SizedBox(width: 6),
                _buildTab('iOS SETUP', 2),
              ],
            ),

            const SizedBox(height: 14),

            Expanded(
              child: ListView(
                children: [
                  if (_selectedTab == 0) ..._buildStatusTab(service),
                  if (_selectedTab == 1) ..._buildAndroidGuide(),
                  if (_selectedTab == 2) ..._buildIosGuide(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int idx) {
    final active = _selectedTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticsUtil.selectionTick();
          setState(() => _selectedTab = idx);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.surfaceHighlight : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? AppColors.amberAccent : AppColors.surfaceBorder),
          ),
          child: Center(
            child: Text(
              title,
              style: AppTypography.filmMetadata.copyWith(
                fontSize: 8,
                color: active ? AppColors.amberAccent : AppColors.textSecondary,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStatusTab(LlmCurationService service) {
    return [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: service.isModelLoaded ? AppColors.slideTeal : AppColors.amberAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  service.isModelLoaded ? 'ACTIVE ON-DEVICE MODEL' : 'FALLBACK ENGINE ACTIVE',
                  style: AppTypography.filmMetadata.copyWith(fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(service.activeModelName, style: AppTypography.filmHeadline.copyWith(fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              service.isModelLoaded
                  ? 'Local quantized GGUF weights running directly on hardware.'
                  : 'Photographic rule engine analyzing warmth, contrast & luminance automatically.',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      TactileButton(
        backgroundColor: AppColors.amberAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        borderRadius: 12,
        onPressed: _pickModelFile,
        child: const Center(
          child: Text(
            'LOAD LOCAL .GGUF / .BIN MODEL FILE',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ),
      ),
      if (service.isModelLoaded) ...[
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            service.unloadModel();
            setState(() {});
          },
          child: const Text('Unload Model & Return to Fallback', style: TextStyle(color: AppColors.filmRed)),
        ),
      ],
    ];
  }

  List<Widget> _buildAndroidGuide() {
    return [
      Text('ANDROID ON-DEVICE MODEL SETUP', style: AppTypography.filmHeadline.copyWith(fontSize: 14)),
      const SizedBox(height: 8),
      _buildStep('1. Supported Quantized Models', 'Recommended: SmolLM2-1.7B-Instruct-Q4_K_M.gguf (~1.0 GB) or Llama-3.2-1B-Instruct-Q4_K_M.gguf (~800 MB).'),
      _buildStep('2. Download Model to Storage', 'Place the .gguf file into your device\'s Download or Documents folder via USB or web download.'),
      _buildStep('3. Load via Cheesera File Picker', 'Tap "LOAD LOCAL .GGUF MODEL" and select the downloaded file. Cheesera validates magic bytes and mounts it directly into memory.'),
      _buildStep('4. NPU Acceleration', 'On Snapdragon devices (8 Gen 2/3), OpenCL / QNN hardware acceleration is automatically utilized.'),
    ];
  }

  List<Widget> _buildIosGuide() {
    return [
      Text('iOS ON-DEVICE MODEL SETUP', style: AppTypography.filmHeadline.copyWith(fontSize: 14)),
      const SizedBox(height: 8),
      _buildStep('1. Supported Quantized Models', 'Recommended: SmolLM2-1.7B-Q4_K_M.gguf or Gemma-2-2B-it-Q4_K_M.gguf (~1.4 GB).'),
      _buildStep('2. Transfer via Apple Files App / AirDrop', 'AirDrop the .gguf file to your iPhone or copy into "On My iPhone > Cheesera" using the Files app.'),
      _buildStep('3. Mount in Cheesera', 'Tap "LOAD LOCAL .GGUF MODEL" to select the file from the Files picker.'),
      _buildStep('4. Apple Silicon & Metal Support', 'Utilizes unified memory on A16/A17/M-series chips with zero network permissions requested.'),
    ];
  }

  Widget _buildStep(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.amberAccent)),
          const SizedBox(height: 2),
          Text(desc, style: AppTypography.caption.copyWith(height: 1.35)),
        ],
      ),
    );
  }
}
