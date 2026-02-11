import 'package:immortal_chronicles/models/technique.dart';

import 'enums.dart';

enum EquipmentSlot {
  weapon,
  helmet,
  armor,
  pants,
  boots,
  belt,
  ring,
  bracelet,
  necklace,
  earring,
}

class Equipment {
  final String id;
  final String name;
  final EquipmentSlot slot;
  final TechniqueGrade grade;
  final OpportunityTier rank;
  final Map<String, num> mainStats;
  final Map<String, num> subStats;
  final List<String> elements;
  final List<String> tags;
  final String description;

  const Equipment({
    required this.id,
    required this.name,
    required this.slot,
    required this.grade,
    required this.rank,
    this.mainStats = const {},
    this.subStats = const {},
    this.elements = const [],
    this.tags = const [],
    this.description = '',
  });

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        slot: EquipmentSlot.values.firstWhere(
          (e) => e.name == json['slot'],
          orElse: () => EquipmentSlot.weapon,
        ),
        grade: TechniqueGrade.values.firstWhere(
          (e) => e.name == json['grade'],
          orElse: () => TechniqueGrade.fan,
        ),
        rank: OpportunityTier.values.firstWhere(
          (e) => e.name == json['rank'],
          orElse: () => OpportunityTier.c,
        ),
        mainStats: Map<String, num>.from(json['mainStats'] ?? const {}),
        subStats: Map<String, num>.from(json['subStats'] ?? const {}),
        elements: (json['elements'] as List?)?.cast<String>() ?? const [],
        tags: (json['tags'] as List?)?.cast<String>() ?? const [],
        description: json['description'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slot': slot.name,
        'grade': grade.name,
        'rank': rank.name,
        'mainStats': mainStats,
        'subStats': subStats,
        'elements': elements,
        'tags': tags,
        'description': description,
      };
}
