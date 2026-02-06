import 'dart:math';

import '../data/realms.dart';
import 'enums.dart';
import 'life_event_entry.dart';
import 'special_talent.dart';
import 'technique.dart';

class PlayerState {
  String name;
  int age;
  int ap;
  World world;
  Region region;
  int strength;
  int intelligence;
  int charm;
  int luck;
  int family;
  int exp;
  int expRequired;
  int breakthroughFailStreak;
  String realm; // 当前境界名称
  String talentLevelName; // 灵根描述
  bool hasLiteracy;
  bool alive;
  String? ending;
  TalentLevel talentLevel;
  List<SpecialTalent> specialTalents;
  List<Technique> techniques;
  List<LifeEventEntry> lifeEvents;
  List<String> pendingEvents;
  int seed;
  String? familyTemplateId;
  String? sectId;

  int get familyScore => (family * 5).clamp(0, 100);

  int get apPerYear {
    int base = 1;
    final hasQiYun = specialTalents.any((t) => t.name == '气运之子');
    if (hasQiYun) base += 1;
    if (familyScore >= 95) base += 1;
    return base;
  }

  int get maxLifespan => realmLifespan[realm] ?? 60;

  PlayerState({
    required this.name,
    required this.age,
    required this.ap,
    required this.world,
    required this.region,
    required this.strength,
    required this.intelligence,
    required this.charm,
    required this.luck,
    required this.family,
    required this.exp,
    required this.expRequired,
    required this.breakthroughFailStreak,
    required this.realm,
    required this.talentLevelName,
    required this.hasLiteracy,
    required this.alive,
    required this.talentLevel,
    required this.techniques,
    required this.specialTalents,
    required this.lifeEvents,
    required this.pendingEvents,
    required this.seed,
    this.ending,
    this.familyTemplateId,
    this.sectId,
  });

  factory PlayerState.newGame({
    required String name,
    required int strength,
    required int intelligence,
    required int charm,
    required int luck,
    required int family,
    required int seed,
    World world = World.mortal,
    Region region = Region.ren,
  }) {
    return PlayerState(
      name: name,
      age: 0,
      ap: 1,
      world: world,
      region: region,
      strength: strength,
      intelligence: intelligence,
      charm: charm,
      luck: luck,
      family: family,
      exp: 0,
      expRequired: 100,
      breakthroughFailStreak: 0,
      realm: '无',
      talentLevelName: '未知',
      hasLiteracy: false,
      alive: true,
      talentLevel: TalentLevel.zhen,
      techniques: const [],
      specialTalents: const [],
      lifeEvents: [],
      pendingEvents: [],
      seed: seed,
      familyTemplateId: null,
      sectId: null,
    )..ap = 1;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'ap': ap,
        'world': world.name,
        'region': region.name,
        'strength': strength,
        'intelligence': intelligence,
        'charm': charm,
        'luck': luck,
        'family': family,
        'exp': exp,
        'expRequired': expRequired,
        'breakthroughFailStreak': breakthroughFailStreak,
        'realm': realm,
        'talentLevelName': talentLevelName,
        'hasLiteracy': hasLiteracy,
        'alive': alive,
        'ending': ending,
        'talentLevel': talentLevel.name,
        'techniques': techniques.map((e) => e.toJson()).toList(),
        'specialTalents': specialTalents.map((e) => e.toJson()).toList(),
        'lifeEvents': lifeEvents.map((e) => e.toJson()).toList(),
        'pendingEvents': pendingEvents,
        'seed': seed,
        'familyTemplateId': familyTemplateId,
        'sectId': sectId,
      };

  factory PlayerState.fromJson(Map<String, dynamic> json) => PlayerState(
        name: json['name'] ?? '无名',
        age: json['age'] ?? 0,
        ap: json['ap'] ?? 3,
        world: World.values.firstWhere(
          (e) => e.name == json['world'],
          orElse: () => World.mortal,
        ),
        region: Region.values.firstWhere(
          (e) => e.name == json['region'],
          orElse: () => Region.ren,
        ),
        strength: json['strength'] ?? 0,
        intelligence: json['intelligence'] ?? 0,
        charm: json['charm'] ?? 0,
        luck: json['luck'] ?? 0,
        family: json['family'] ?? 0,
        exp: json['exp'] ?? 0,
        expRequired: json['expRequired'] ?? 100,
        breakthroughFailStreak: json['breakthroughFailStreak'] ?? 0,
        realm: json['realm'] ?? '无',
        talentLevelName: json['talentLevelName'] ?? '未知',
        hasLiteracy: json['hasLiteracy'] ?? false,
        alive: json['alive'] ?? true,
        ending: json['ending'],
        talentLevel: TalentLevel.values.firstWhere(
          (e) => e.name == json['talentLevel'],
          orElse: () => TalentLevel.zhen,
        ),
        techniques: (json['techniques'] as List<dynamic>? ?? [])
            .map((e) => Technique.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        specialTalents: (json['specialTalents'] as List<dynamic>? ?? [])
            .map((e) => SpecialTalent.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        lifeEvents: (json['lifeEvents'] as List<dynamic>? ?? [])
            .map((e) => LifeEventEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        pendingEvents:
            (json['pendingEvents'] as List<dynamic>? ?? []).cast<String>(),
        seed: json['seed'] ?? Random().nextInt(1 << 31),
        familyTemplateId: json['familyTemplateId'],
        sectId: json['sectId'],
      );
}
