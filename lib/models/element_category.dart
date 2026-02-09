class ElementCategory {
  final String id;
  final String name;
  final List<String> elements;

  ElementCategory({
    required this.id,
    required this.name,
    required this.elements,
  });

  factory ElementCategory.fromJson(Map<String, dynamic> json) => ElementCategory(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        elements: List<String>.from(json['elements'] ?? []),
      );
}
