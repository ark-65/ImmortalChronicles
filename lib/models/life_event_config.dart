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
    this.effects = const {},
    this.choices = const [],
    this.weight = 1,
  });
}
