import '../models/technique.dart';

List<Technique> fanTechPool = List.generate(
  200,
  (i) => Technique(
    name: '凡级功法${i + 1}',
    grade: TechniqueGrade.fan,
    stage: ProficiencyStage.chuKui,
    exp: 0,
    expRequired: 100,
  ),
);

List<Technique> lingTechPool = List.generate(
  150,
  (i) => Technique(
    name: '灵级功法${i + 1}',
    grade: TechniqueGrade.ling,
    stage: ProficiencyStage.chuKui,
    exp: 0,
    expRequired: 120,
  ),
);

List<Technique> xianTechPool = List.generate(
  100,
  (i) => Technique(
    name: '仙级功法${i + 1}',
    grade: TechniqueGrade.xian,
    stage: ProficiencyStage.chuKui,
    exp: 0,
    expRequired: 150,
  ),
);

List<Technique> shengTechPool = List.generate(
  50,
  (i) => Technique(
    name: '圣级功法${i + 1}',
    grade: TechniqueGrade.sheng,
    stage: ProficiencyStage.chuKui,
    exp: 0,
    expRequired: 180,
  ),
);

List<Technique> daoTechPool = List.generate(
  20,
  (i) => Technique(
    name: '道级功法${i + 1}',
    grade: TechniqueGrade.dao,
    stage: ProficiencyStage.chuKui,
    exp: 0,
    expRequired: 220,
  ),
);

/// 全部功法池（便于随机抽取）
List<Technique> allTechPool() => [
      ...fanTechPool,
      ...lingTechPool,
      ...xianTechPool,
      ...shengTechPool,
      ...daoTechPool,
    ];
