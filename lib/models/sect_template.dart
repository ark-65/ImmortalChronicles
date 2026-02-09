class SectTemplate {
  final String id;
  final String name;
  final List<String> elements;
  final List<String> specialties;
  final List<String> weapons;
  final List<String> coreTechniqueIds;
  final String tier;

  const SectTemplate({
    required this.id,
    required this.name,
    required this.elements,
    required this.specialties,
    this.weapons = const [],
    this.coreTechniqueIds = const [],
    required this.tier,
  });

  factory SectTemplate.fromJson(Map<String, dynamic> json) => SectTemplate(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        elements: List<String>.from(json['elements'] ?? const []),
        specialties: List<String>.from(json['specialties'] ?? const []),
        weapons: List<String>.from(json['weapons'] ?? const []),
        coreTechniqueIds: List<String>.from(json['coreTechniqueIds'] ?? const []),
        tier: json['tier'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'elements': elements,
        'specialties': specialties,
        'weapons': weapons,
        'coreTechniqueIds': coreTechniqueIds,
        'tier': tier,
      };
}
