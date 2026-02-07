import 'enums.dart';

class LifeEventChoice {
  final String id;
  final String label;
  final Map<String, dynamic> effects;
  final String? followup;

  const LifeEventChoice({
    required this.id,
    required this.label,
    this.effects = const {},
    this.followup,
  });

  factory LifeEventChoice.fromJson(Map<String, dynamic> json) {
    return LifeEventChoice(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      effects: Map<String, dynamic>.from(json['effects'] ?? const {}),
      followup: json['followup'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'effects': effects,
        'followup': followup,
      };
}

class LifeEventConfig {
  final String id;
  final String title;
  final String description;
  final List<World> worlds;
  final List<Region>? regions;
  final int? minAge;
  final int? maxAge;
  final Map<String, dynamic> conditions;
  // 前置需求，避免滥用 conditions 字典，常见如 requiresRootAwakened / requiresCultivationStarted
  final List<String> prerequisites;
  final Map<String, dynamic> effects;
  final List<LifeEventChoice> choices;
  final int weight;

  const LifeEventConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.worlds,
    this.regions,
    this.minAge,
    this.maxAge,
    this.conditions = const {},
    this.prerequisites = const [],
    this.effects = const {},
    this.choices = const [],
    this.weight = 1,
  });

  factory LifeEventConfig.fromJson(Map<String, dynamic> json) {
    List<World> parseWorlds(dynamic v) {
      if (v is List) {
        return v
            .map((e) => World.values.firstWhere(
                  (w) => w.name == e,
                  orElse: () => World.mortal,
                ))
            .toList();
      }
      return [World.mortal];
    }

    List<Region>? parseRegions(dynamic v) {
      if (v is List) {
        return v
            .map((e) => Region.values.firstWhere(
                  (r) => r.name == e,
                  orElse: () => Region.ren,
                ))
            .toList();
      }
      return null;
    }

    List<LifeEventChoice> parseChoices(dynamic v) {
      if (v is List) {
        return v
            .map((e) => LifeEventChoice.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return const [];
    }

    return LifeEventConfig(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      worlds: parseWorlds(json['worlds']),
      regions: parseRegions(json['regions']),
      minAge: json['minAge'],
      maxAge: json['maxAge'],
      conditions: Map<String, dynamic>.from(json['conditions'] ?? const {}),
      prerequisites:
          List<String>.from(json['prerequisites'] ?? const <String>[]),
      effects: Map<String, dynamic>.from(json['effects'] ?? const {}),
      choices: parseChoices(json['choices']),
      weight: (json['weight'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'worlds': worlds.map((e) => e.name).toList(),
        'regions': regions?.map((e) => e.name).toList(),
        'minAge': minAge,
        'maxAge': maxAge,
        'conditions': conditions,
        'prerequisites': prerequisites,
        'effects': effects,
        'choices': choices.map((c) => c.toJson()).toList(),
        'weight': weight,
      };
}
