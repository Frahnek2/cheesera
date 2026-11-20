import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/utils/haptics_util.dart';
import '../../models/photo_item.dart';
import '../recipe_service/recipe_provider.dart';
import 'ingestion_rule_engine.dart';
import 'watched_folder_models.dart';

/// Service monitoring a user-selected folder (or camera SD card mount),
/// automatically matching and applying film simulation recipes & tags.
class WatchedFolderService extends ChangeNotifier {
  final RecipeProvider recipeProvider;
  final IngestionRuleEngine ruleEngine;
  final File? customConfigFile;

  String? _watchedDirectoryPath;
  bool _isMonitoring = false;
  List<IngestionRule> _rules = [];
  final Set<String> _ingestedFilePaths = {};
  final List<String> _activityLog = [];

  StreamSubscription? _dirWatcherSubscription;
  Timer? _pollingTimer;

  // Callback triggered when a new photo is ingested
  final void Function(PhotoItem item)? onPhotoIngested;

  WatchedFolderService({
    required this.recipeProvider,
    this.customConfigFile,
    this.onPhotoIngested,
  }) : ruleEngine = IngestionRuleEngine(recipeProvider: recipeProvider) {
    _rules = List.from(IngestionRule.defaultRules);
  }

  String? get watchedDirectoryPath => _watchedDirectoryPath;
  bool get isMonitoring => _isMonitoring;
  List<IngestionRule> get rules => List.unmodifiable(_rules);
  List<String> get activityLog => List.unmodifiable(_activityLog);
  int get ingestedCount => _ingestedFilePaths.length;

  Future<File?> _getConfigFile() async {
    if (customConfigFile != null) return customConfigFile!;
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/watched_folder_config.json');
    } catch (_) {
      return null;
    }
  }

  /// Initializes the service from persistent disk configuration.
  Future<void> initialize() async {
    await loadConfig();
    if (_watchedDirectoryPath != null && _isMonitoring) {
      _startMonitoring();
    }
  }

  /// Sets or updates the directory to monitor.
  Future<void> setWatchedDirectory(String path) async {
    _watchedDirectoryPath = path;
    _activityLog.insert(0, '[CONFIG] Watched folder set: $path');
    await persistConfig();
    if (_isMonitoring) {
      _startMonitoring();
    }
    notifyListeners();
  }

  /// Toggles automatic background monitoring on/off.
  void toggleMonitoring(bool enable) {
    _isMonitoring = enable;
    if (_isMonitoring) {
      _startMonitoring();
      _activityLog.insert(0, '[STATUS] Folder monitoring STARTED.');
    } else {
      _stopMonitoring();
      _activityLog.insert(0, '[STATUS] Folder monitoring PAUSED.');
    }
    persistConfig();
    notifyListeners();
  }

  void addRule(IngestionRule rule) {
    _rules.add(rule);
    persistConfig();
    notifyListeners();
  }

  void removeRule(String ruleId) {
    _rules.removeWhere((r) => r.id == ruleId);
    persistConfig();
    notifyListeners();
  }

  void toggleRule(String ruleId, bool enabled) {
    final idx = _rules.indexWhere((r) => r.id == ruleId);
    if (idx != -1) {
      _rules[idx] = _rules[idx].copyWith(isEnabled: enabled);
      persistConfig();
      notifyListeners();
    }
  }

  void _startMonitoring() {
    _stopMonitoring();
    if (_watchedDirectoryPath == null) return;

    final dir = Directory(_watchedDirectoryPath!);
    if (!dir.existsSync()) return;

    // 1. Direct OS file watcher
    try {
      _dirWatcherSubscription = dir.watch().listen((event) {
        if (event.type == FileSystemEvent.create || event.type == FileSystemEvent.modify) {
          final file = File(event.path);
          if (_isImageFile(file.path)) {
            _processFile(file);
          }
        }
      });
    } catch (_) {}

    // 2. Periodic safety scanner (crucial for external SD cards where OS watch events can be dropped)
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      scanNow();
    });

    // Run immediate scan on startup
    scanNow();
  }

  void _stopMonitoring() {
    _dirWatcherSubscription?.cancel();
    _dirWatcherSubscription = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Manually scans the watched directory for any new un-ingested photos.
  Future<List<PhotoItem>> scanNow() async {
    if (_watchedDirectoryPath == null) return [];
    final dir = Directory(_watchedDirectoryPath!);
    if (!dir.existsSync()) return [];

    final List<PhotoItem> newlyIngested = [];

    try {
      final entities = dir.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File && _isImageFile(entity.path)) {
          if (!_ingestedFilePaths.contains(entity.path)) {
            final photo = await _processFile(entity);
            if (photo != null) {
              newlyIngested.add(photo);
            }
          }
        }
      }
    } catch (e) {
      _activityLog.insert(0, '[SCAN ERROR] $e');
    }

    if (newlyIngested.isNotEmpty) {
      notifyListeners();
    }
    return newlyIngested;
  }

  Future<PhotoItem?> _processFile(File file) async {
    if (_ingestedFilePaths.contains(file.path)) return null;

    try {
      final bytes = await file.readAsBytes();
      final match = ruleEngine.evaluateFile(file: file, rules: _rules);

      final filename = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : file.path;

      final photo = PhotoItem(
        id: 'watched_${DateTime.now().millisecondsSinceEpoch}_${filename.hashCode}',
        title: filename,
        originalBytes: bytes,
        recipe: match.recipe,
        createdAt: DateTime.now(),
      );

      _ingestedFilePaths.add(file.path);
      final ruleName = match.matchedRule?.name ?? 'Default Fallback';
      _activityLog.insert(0, '[INGESTED] $filename -> ${match.recipe.preset.name} via "$ruleName"');

      HapticsUtil.selectionTick();
      if (onPhotoIngested != null) {
        onPhotoIngested!(photo);
      }

      await persistConfig();
      notifyListeners();
      return photo;
    } catch (_) {
      return null;
    }
  }

  bool _isImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.dng') ||
        lower.endsWith('.raw');
  }

  Future<void> persistConfig() async {
    try {
      final map = {
        'watchedDirectoryPath': _watchedDirectoryPath,
        'isMonitoring': _isMonitoring,
        'rules': _rules.map((r) => r.toJson()).toList(),
        'ingestedFilePaths': _ingestedFilePaths.toList(),
      };
      final file = await _getConfigFile();
      if (file != null) {
        await file.writeAsString(jsonEncode(map));
      }
    } catch (_) {}
  }

  Future<void> loadConfig() async {
    try {
      final file = await _getConfigFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        final map = jsonDecode(content);
        if (map is Map<String, dynamic>) {
          _watchedDirectoryPath = map['watchedDirectoryPath']?.toString();
          _isMonitoring = map['isMonitoring'] == true;
          if (map['rules'] is List) {
            _rules = (map['rules'] as List)
                .map((r) => IngestionRule.fromJson(Map<String, dynamic>.from(r)))
                .toList();
          }
          if (map['ingestedFilePaths'] is List) {
            _ingestedFilePaths.addAll((map['ingestedFilePaths'] as List).cast<String>());
          }
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  @override
  void dispose() {
    _stopMonitoring();
    super.dispose();
  }
}
