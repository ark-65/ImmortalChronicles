import 'enums.dart';

enum TechniqueGrade { fan, ling, xian, sheng, dao }

enum TechniqueType { cultivation, martialArt }

enum ProficiencyStage { chuKui, xiaoYou, dengTang, dengFeng }

class Technique {
  final String id;
  final String name;
  final TechniqueType type;
  final TechniqueGrade grade;
  final OpportunityTier rank;
  final List<String> elements;
  final List<String> tags; // e.g., defense_phys, defense_mag, speed
  final String description;
  ProficiencyStage stage;
  int exp;
  int expRequired;

  Technique({
    required this.id,
    required this.name,
    required this.type,
    required this.grade,
    required this.rank,
    required this.elements,
    this.tags = const [],
    this.description = '',
    required this.stage,
    required this.exp,
    required this.expRequired,
  });

  String get gradeLabel {
    switch (grade) {
      case TechniqueGrade.fan:
        return '凡级';
      case TechniqueGrade.ling:
        return '灵级';
      case TechniqueGrade.xian:
        return '仙级';
      case TechniqueGrade.sheng:
        return '圣级';
      case TechniqueGrade.dao:
        return '道级';
    }
  }

  String get stageLabel {
    switch (stage) {
      case ProficiencyStage.chuKui:
        return '初窥门径';
      case ProficiencyStage.xiaoYou:
        return '小有所成';
      case ProficiencyStage.dengTang:
        return '登堂入室';
      case ProficiencyStage.dengFeng:
        return '登峰造极';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'grade': grade.name,
        'rank': rank.name,
        'elements': elements,
        'tags': tags,
        'description': description,
        'stage': stage.name,
        'exp': exp,
        'expRequired': expRequired,
      };

  factory Technique.fromJson(Map<String, dynamic> json) => Technique(
        id: json['id'] ?? '',
        name: json['name'],
        type: TechniqueType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => TechniqueType.martialArt,
        ),
        grade: TechniqueGrade.values.firstWhere(
          (e) => e.name == json['grade'],
          orElse: () => TechniqueGrade.fan,
        ),
        rank: OpportunityTier.values.firstWhere(
          (e) => e.name == json['rank'],
          orElse: () => OpportunityTier.c,
        ),
        elements: List<String>.from(json['elements'] ?? []),
        tags: List<String>.from(json['tags'] ?? const []),
        description: json['description'] ?? '',
        stage: ProficiencyStage.values.firstWhere(
          (e) => e.name == json['stage'],
          orElse: () => ProficiencyStage.chuKui,
        ),
        exp: json['exp'] ?? 0,
        expRequired: json['expRequired'] ?? 100,
      );
}
