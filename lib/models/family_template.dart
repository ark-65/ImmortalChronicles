class FamilyTemplate {
  final String id;
  final String name;
  final List<String> elements;
  final List<String> weapons;
  final List<String> coreTechniqueIds;
  final String tier; // 霸主/圣地/天/地/人 或 下界一至九品

  const FamilyTemplate({
    required this.id,
    required this.name,
    required this.elements,
    required this.weapons,
    required this.coreTechniqueIds,
    required this.tier,
  });

  factory FamilyTemplate.fromJson(Map<String, dynamic> json) => FamilyTemplate(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        elements: List<String>.from(json['elements'] ?? const []),
        weapons: List<String>.from(json['weapons'] ?? const []),
        coreTechniqueIds: List<String>.from(json['coreTechniqueIds'] ?? const []),
        tier: json['tier'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'elements': elements,
        'weapons': weapons,
        'coreTechniqueIds': coreTechniqueIds,
        'tier': tier,
      };
}
