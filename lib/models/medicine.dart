class Medicine {
  final String id;
  final String name;
  final String grade; // 凡/灵/仙/圣/道 或品质
  final String effect; // 文本描述
  final Map<String, num> bonuses; // 属性或寿元加成
  final int rarity; // 1-10 越高越稀有

  const Medicine({
    required this.id,
    required this.name,
    required this.grade,
    required this.effect,
    this.bonuses = const {},
    this.rarity = 1,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        grade: json['grade'] ?? '凡',
        effect: json['effect'] ?? '',
        bonuses: Map<String, num>.from(json['bonuses'] ?? const {}),
        rarity: (json['rarity'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'grade': grade,
        'effect': effect,
        'bonuses': bonuses,
        'rarity': rarity,
      };
}
