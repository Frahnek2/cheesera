import '../../models/film_preset.dart';
import '../../models/film_recipe.dart';

enum CriteriaType {
  filenamePattern, // e.g. "DSCF*", "PORTRA*", "NOIR*"
  fileExtension,   // e.g. "jpg", "png", "dng", "raw"
  timeOfDay,       // e.g. Golden hour (17-20) or Night (21-04)
  albumKeyword,    // folder or album name contains keyword
}

class IngestionCriteria {
  final CriteriaType type;
  final String pattern; // regex or glob
  final int? startHour; // 0-23
  final int? endHour;   // 0-23

  const IngestionCriteria({
    required this.type,
    this.pattern = '',
    this.startHour,
    this.endHour,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'pattern': pattern,
    'startHour': startHour,
    'endHour': endHour,
  };

  factory IngestionCriteria.fromJson(Map<String, dynamic> json) {
    return IngestionCriteria(
      type: CriteriaType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => CriteriaType.filenamePattern,
      ),
      pattern: json['pattern'] ?? '',
      startHour: json['startHour'],
      endHour: json['endHour'],
    );
  }
}

class IngestionRule {
  final String id;
  final String name;
  final bool isEnabled;
  final IngestionCriteria criteria;
  final String targetRecipeId;
  final List<String> tags;
  final bool autoDevelop;

  const IngestionRule({
    required this.id,
    required this.name,
    this.isEnabled = true,
    required this.criteria,
    required this.targetRecipeId,
    this.tags = const [],
    this.autoDevelop = false,
  });

  IngestionRule copyWith({
    String? id,
    String? name,
    bool? isEnabled,
    IngestionCriteria? criteria,
    String? targetRecipeId,
    List<String>? tags,
    bool? autoDevelop,
  }) {
    return IngestionRule(
      id: id ?? this.id,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
      criteria: criteria ?? this.criteria,
      targetRecipeId: targetRecipeId ?? this.targetRecipeId,
      tags: tags ?? this.tags,
      autoDevelop: autoDevelop ?? this.autoDevelop,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isEnabled': isEnabled,
    'criteria': criteria.toJson(),
    'targetRecipeId': targetRecipeId,
    'tags': tags,
    'autoDevelop': autoDevelop,
  };

  factory IngestionRule.fromJson(Map<String, dynamic> json) {
    return IngestionRule(
      id: json['id'] ?? 'rule_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] ?? 'Custom Ingestion Rule',
      isEnabled: json['isEnabled'] ?? true,
      criteria: json['criteria'] != null
          ? IngestionCriteria.fromJson(Map<String, dynamic>.from(json['criteria']))
          : const IngestionCriteria(type: CriteriaType.filenamePattern, pattern: '.*'),
      targetRecipeId: json['targetRecipeId'] ?? FilmPreset.portra400.id,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      autoDevelop: json['autoDevelop'] ?? false,
    );
  }

  // Pre-configured default rules for common photography setups
  static final List<IngestionRule> defaultRules = [
    IngestionRule(
      id: 'rule_fuji_classic',
      name: 'Fujifilm Camera (DSCF*) -> Classic Chrome',
      criteria: const IngestionCriteria(
        type: CriteriaType.filenamePattern,
        pattern: r'(?i)^DSCF.*',
      ),
      targetRecipeId: FilmPreset.classicChrome.id,
      tags: ['Fuji X', 'Documentary'],
    ),
    IngestionRule(
      id: 'rule_portra_keywords',
      name: 'Portra / Golden Hour -> Portra 400',
      criteria: const IngestionCriteria(
        type: CriteriaType.timeOfDay,
        startHour: 17,
        endHour: 20,
      ),
      targetRecipeId: FilmPreset.portra400.id,
      tags: ['Golden Hour', 'Portra'],
    ),
    IngestionRule(
      id: 'rule_night_shots',
      name: 'Night Shots (NIGHT* / 21h-04h) -> CineStill 800T',
      criteria: const IngestionCriteria(
        type: CriteriaType.filenamePattern,
        pattern: r'(?i).*(night|neon|dark).*',
      ),
      targetRecipeId: FilmPreset.cinestill800T.id,
      tags: ['CineStill', 'Night'],
    ),
    IngestionRule(
      id: 'rule_monochrome',
      name: 'B&W Keywords (BW* / MONO*) -> Tri-X 400',
      criteria: const IngestionCriteria(
        type: CriteriaType.filenamePattern,
        pattern: r'(?i).*(bw|mono|noir|trix).*',
      ),
      targetRecipeId: FilmPreset.triX400.id,
      tags: ['Black & White', 'Street'],
    ),
  ];
}
