class WeaponType {
  final String id;
  final String name;
  final String description;

  WeaponType({
    required this.id,
    required this.name,
    this.description = '',
  });

  factory WeaponType.fromJson(Map<String, dynamic> json) => WeaponType(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };
}
