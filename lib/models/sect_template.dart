class SectTemplate {
  final String id;
  final String name;
  final List<String> elements;
  final List<String> specialties;
  final List<String> weapons;
  final String tier;

  const SectTemplate({
    required this.id,
    required this.name,
    required this.elements,
    required this.specialties,
    this.weapons = const [],
    required this.tier,
  });

  factory SectTemplate.fromJson(Map<String, dynamic> json) => SectTemplate(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        elements: List<String>.from(json['elements'] ?? const []),
        specialties: List<String>.from(json['specialties'] ?? const []),
        weapons: List<String>.from(json['weapons'] ?? const []),
        tier: json['tier'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'elements': elements,
        'specialties': specialties,
        'weapons': weapons,
        'tier': tier,
      };
}
