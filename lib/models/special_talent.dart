class SpecialTalent {
  final String name;
  final String description;
  final double rarity;
  final Map<String, dynamic> effects;

  const SpecialTalent({
    required this.name,
    required this.description,
    required this.rarity,
    required this.effects,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'rarity': rarity,
        'effects': effects,
      };

  factory SpecialTalent.fromJson(Map<String, dynamic> json) => SpecialTalent(
        name: json['name'],
        description: json['description'],
        rarity: (json['rarity'] as num).toDouble(),
        effects: Map<String, dynamic>.from(json['effects'] ?? {}),
      );
}
