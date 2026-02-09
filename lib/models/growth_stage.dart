class GrowthStage {
  final String id;
  final int minAge;
  final int maxAge;
  final bool allowCombat;
  final bool allowLiteracy;
  final bool allowCultivation;

  GrowthStage({
    required this.id,
    required this.minAge,
    required this.maxAge,
    this.allowCombat = false,
    this.allowLiteracy = false,
    this.allowCultivation = false,
  });

  factory GrowthStage.fromJson(Map<String, dynamic> json) => GrowthStage(
        id: json['id'] ?? '',
        minAge: (json['minAge'] as num?)?.toInt() ?? 0,
        maxAge: (json['maxAge'] as num?)?.toInt() ?? 999,
        allowCombat: json['allowCombat'] == true,
        allowLiteracy: json['allowLiteracy'] == true,
        allowCultivation: json['allowCultivation'] == true,
      );
}
