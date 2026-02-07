class StageConfig {
  final String id;
  final int minAge;
  final int maxAge;
  final bool allowCombat;
  final bool allowLiteracy;
  final bool allowCultivation;

  const StageConfig({
    required this.id,
    required this.minAge,
    required this.maxAge,
    required this.allowCombat,
    required this.allowLiteracy,
    required this.allowCultivation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'minAge': minAge,
        'maxAge': maxAge,
        'allowCombat': allowCombat,
        'allowLiteracy': allowLiteracy,
        'allowCultivation': allowCultivation,
      };

  factory StageConfig.fromJson(Map<String, dynamic> json) => StageConfig(
        id: json['id'] ?? '',
        minAge: json['minAge'] ?? 0,
        maxAge: json['maxAge'] ?? 0,
        allowCombat: json['allowCombat'] ?? false,
        allowLiteracy: json['allowLiteracy'] ?? false,
        allowCultivation: json['allowCultivation'] ?? false,
      );
}

const stageConfigs = [
  StageConfig(
    id: 'infant',
    minAge: 0,
    maxAge: 5,
    allowCombat: false,
    allowLiteracy: false,
    allowCultivation: false,
  ),
  StageConfig(
    id: 'child',
    minAge: 6,
    maxAge: 12,
    allowCombat: true,
    allowLiteracy: true,
    allowCultivation: false,
  ),
  StageConfig(
    id: 'teen',
    minAge: 13,
    maxAge: 20,
    allowCombat: true,
    allowLiteracy: true,
    allowCultivation: true,
  ),
  StageConfig(
    id: 'adult',
    minAge: 21,
    maxAge: 2000,
    allowCombat: true,
    allowLiteracy: true,
    allowCultivation: true,
  ),
];

StageConfig currentStage(int age) =>
    stageConfigs.firstWhere((s) => age >= s.minAge && age <= s.maxAge,
        orElse: () => stageConfigs.last);
