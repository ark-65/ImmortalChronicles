enum TechniqueGrade { fan, ling, xian, sheng, dao }

enum ProficiencyStage { chuKui, xiaoYou, dengTang, dengFeng }

class Technique {
  final String name;
  final TechniqueGrade grade;
  ProficiencyStage stage;
  int exp;
  int expRequired;

  Technique({
    required this.name,
    required this.grade,
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
        'name': name,
        'grade': grade.name,
        'stage': stage.name,
        'exp': exp,
        'expRequired': expRequired,
      };

  factory Technique.fromJson(Map<String, dynamic> json) => Technique(
        name: json['name'],
        grade: TechniqueGrade.values
            .firstWhere((e) => e.name == json['grade'], orElse: () => TechniqueGrade.fan),
        stage: ProficiencyStage.values
            .firstWhere((e) => e.name == json['stage'], orElse: () => ProficiencyStage.chuKui),
        exp: json['exp'] ?? 0,
        expRequired: json['expRequired'] ?? 100,
      );
}
