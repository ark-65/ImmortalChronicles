class LifeEventEntry {
  final String id;
  final int age;
  final String title;
  final String description;
  final Map<String, num> deltas;
  final List<String> tags;
  final bool regret;

  LifeEventEntry({
    required this.id,
    required this.age,
    required this.title,
    required this.description,
    this.deltas = const {},
    this.tags = const [],
    this.regret = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'age': age,
        'title': title,
        'description': description,
        'deltas': deltas,
        'tags': tags,
        'regret': regret,
      };

  factory LifeEventEntry.fromJson(Map<String, dynamic> json) => LifeEventEntry(
        id: json['id'],
        age: json['age'] ?? 0,
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        deltas: Map<String, num>.from(json['deltas'] ?? {}),
        tags: List<String>.from(json['tags'] ?? const []),
        regret: json['regret'] ?? false,
      );
}
