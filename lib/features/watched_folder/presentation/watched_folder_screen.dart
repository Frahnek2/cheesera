import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/haptics_util.dart';
import '../../../models/film_preset.dart';
import '../../../services/watched_folder/watched_folder_models.dart';
import '../../../services/watched_folder/watched_folder_service.dart';
import '../../../widgets/tactile_button.dart';

/// Screen to configure and inspect automatic folder monitoring and rule-based ingestion.
class WatchedFolderScreen extends StatefulWidget {
  final WatchedFolderService watchedFolderService;

  const WatchedFolderScreen({
    super.key,
    required this.watchedFolderService,
  });

  @override
  State<WatchedFolderScreen> createState() => _WatchedFolderScreenState();
}

class _WatchedFolderScreenState extends State<WatchedFolderScreen> {
  @override
  void initState() {
    super.initState();
    widget.watchedFolderService.addListener(_onServiceChange);
  }

  @override
  void dispose() {
    widget.watchedFolderService.removeListener(_onServiceChange);
    super.dispose();
  }

  void _onServiceChange() {
    if (mounted) setState(() {});
  }

  Future<void> _chooseFolder() async {
    HapticsUtil.selectionTick();
    try {
      final path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Folder to Watch for Auto-Ingestion',
      );
      if (path != null) {
        await widget.watchedFolderService.setWatchedDirectory(path);
      }
    } catch (_) {}
  }

  void _showAddRuleDialog() {
    final nameController = TextEditingController();
    final patternController = TextEditingController(text: r'DSCF.*');
    String selectedRecipeId = FilmPreset.classicChrome.id;
    CriteriaType criteriaType = CriteriaType.filenamePattern;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('NEW INGESTION RULE', style: AppTypography.filmHeadline.copyWith(fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Rule Name'),
              ),
              const SizedBox(height: 10),
              DropdownButton<CriteriaType>(
                value: criteriaType,
                isExpanded: true,
                dropdownColor: AppColors.surfaceDark,
                items: CriteriaType.values.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setDialogState(() => criteriaType = v);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: patternController,
                decoration: const InputDecoration(labelText: 'Pattern / Matcher (e.g. DSCF*)'),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedRecipeId,
                isExpanded: true,
                dropdownColor: AppColors.surfaceDark,
                items: FilmPreset.allPresets.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text(p.name));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedRecipeId = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.amberAccent, foregroundColor: Colors.black),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  widget.watchedFolderService.addRule(
                    IngestionRule(
                      id: 'rule_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      criteria: IngestionCriteria(type: criteriaType, pattern: patternController.text.trim()),
                      targetRecipeId: selectedRecipeId,
                    ),
                  );
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('ADD RULE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.watchedFolderService;

    return Scaffold(
      backgroundColor: AppColors.darkroomBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('WATCHED FOLDER SERVICE', style: AppTypography.brandLogo.copyWith(fontSize: 14)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.amberAccent),
            tooltip: 'Scan Now',
            onPressed: () async {
              HapticsUtil.selectionTick();
              final count = await service.scanNow();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Scan complete: ${count.length} new photos ingested.'),
                  backgroundColor: AppColors.surfaceElevated,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Directory Card & Monitoring Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.folder_open_rounded, color: AppColors.amberAccent, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MONITORED DIRECTORY', style: AppTypography.filmMetadata.copyWith(fontSize: 9)),
                            Text(
                              service.watchedDirectoryPath ?? 'No directory selected',
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      TactileButton(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        borderRadius: 8,
                        onPressed: _chooseFolder,
                        child: const Text('BROWSE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AUTO-MONITORING (BACKGROUND)', style: AppTypography.filmMetadata.copyWith(fontSize: 9)),
                          Text(
                            service.isMonitoring ? 'Active (Scanning every 4s)' : 'Paused',
                            style: AppTypography.caption.copyWith(
                              color: service.isMonitoring ? AppColors.slideTeal : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: service.isMonitoring,
                        activeColor: AppColors.slideTeal,
                        onChanged: (val) {
                          HapticsUtil.selectionTick();
                          service.toggleMonitoring(val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Ingestion Rules Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('MATCHING CRITERIA RULES (${service.rules.length})', style: AppTypography.filmMetadata.copyWith(fontSize: 10)),
                TactileButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  borderRadius: 6,
                  onPressed: _showAddRuleDialog,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: AppColors.amberAccent),
                      SizedBox(width: 4),
                      Text('ADD RULE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.amberAccent)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ...service.rules.map((rule) {
              final preset = FilmPreset.findById(rule.targetRecipeId);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: rule.isEnabled ? AppColors.surfaceBorder : AppColors.surfaceDark),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: preset.badgeColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rule.name,
                            style: AppTypography.filmHeadline.copyWith(
                              fontSize: 13,
                              color: rule.isEnabled ? AppColors.textPrimary : AppColors.textDisabled,
                            ),
                          ),
                          Text(
                            'Matches "${rule.criteria.pattern}" -> ${preset.name}',
                            style: AppTypography.caption.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: rule.isEnabled,
                      activeColor: AppColors.amberAccent,
                      onChanged: (val) => service.toggleRule(rule.id, val),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // Ingestion Activity Log
            Text('INGESTION ACTIVITY LOG', style: AppTypography.filmMetadata.copyWith(fontSize: 10)),
            const SizedBox(height: 8),
            Container(
              height: 160,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF090A0C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: service.activityLog.isEmpty
                  ? Center(
                      child: Text('No activity yet. Ingestion log appears here.', style: AppTypography.caption),
                    )
                  : ListView.builder(
                      itemCount: service.activityLog.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          service.activityLog[i],
                          style: AppTypography.knobValue.copyWith(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
