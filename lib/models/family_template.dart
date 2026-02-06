class FamilyTemplate {
  final String id;
  final String name;
  final List<String> elements;
  final List<String> weapons;
  final List<String> coreTechniques;
  final String tier; // 霸主/圣地/天/地/人 或 下界一至九品

  const FamilyTemplate({
    required this.id,
    required this.name,
    required this.elements,
    required this.weapons,
    required this.coreTechniques,
    required this.tier,
  });
}
