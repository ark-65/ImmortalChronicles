import 'dart:math';

import '../models/models.dart';
import '../data/sample_events.dart';
import '../data/technique_pool.dart';
import '../data/realms.dart';
import '../data/stages.dart';
import '../data/family_templates.dart';
import '../data/sect_templates.dart';

class EventEngine {
  final Random rng;

  EventEngine(int seed) : rng = Random(seed);

  LifeEventConfig pickEvent(PlayerState state) {
    // pending first
    if (state.pendingEvents.isNotEmpty) {
      final pid = state.pendingEvents.removeAt(0);
      final fromPending =
          sampleEvents.firstWhere((e) => e.id == pid, orElse: () => fallback(state));
      return fromPending;
    }

    final stage = currentStage(state.age);
    final candidates = sampleEvents.where((e) {
      if (!e.worlds.contains(state.world)) return false;
      if (e.regions != null && !e.regions!.contains(state.region)) return false;
      if (e.minAge != null && state.age < e.minAge!) return false;
      if (e.maxAge != null && state.age > e.maxAge!) return false;
      if (e.conditions['needsLiteracy'] == true &&
          (!stage.allowLiteracy || !state.hasLiteracy)) {
        return false;
      }
      if (e.conditions['needsCultivation'] == true &&
          (!stage.allowCultivation || state.realm == '无')) {
        return false;
      }
      if (e.conditions['unique'] == true &&
          state.lifeEvents.any((ev) => ev.id == e.id)) {
        return false;
      }
      if (e.conditions.containsKey('chance')) {
        final p = (e.conditions['chance'] as num).toDouble();
        if (rng.nextDouble() > p) return false;
      }
      return true;
    }).toList();

    if (candidates.isEmpty) return fallback(state);
    // weighted random
    final total = candidates.fold<int>(0, (s, e) => s + e.weight);
    int roll = rng.nextInt(total);
    for (final e in candidates) {
      roll -= e.weight;
      if (roll < 0) return e;
    }
    return candidates.first;
  }

  LifeEventConfig fallback(PlayerState state) => sampleEvents
      .firstWhere((e) => e.id == '${state.world.name}_fallback', orElse: () => sampleEvents.first);

  FamilyTemplate? _currentFamilyTemplate(PlayerState state) {
    if (state.familyTemplateId == null) return null;
    return familyTemplates
        .firstWhere((f) => f.id == state.familyTemplateId, orElse: () => familyTemplates.first);
  }

  double _tierBonus(String? tier) {
    switch (tier) {
      case '霸主':
        return 0.1;
      case '圣地':
        return 0.07;
      case '天':
        return 0.05;
      case '地':
        return 0.03;
      case '人':
        return 0.0;
      case '一品':
        return 0.04;
      case '二品':
        return 0.03;
      case '三品':
        return 0.025;
      case '四品':
        return 0.02;
      case '五品':
        return 0.015;
      case '六品':
        return 0.01;
      case '七品':
        return 0.007;
      case '八品':
        return 0.004;
      case '九品':
        return 0.002;
      default:
        return 0.0;
    }
  }

  SectTemplate? _currentSect(PlayerState state) {
    if (state.sectId == null) return null;
    return sectTemplates
        .firstWhere((s) => s.id == state.sectId, orElse: () => sectTemplates.first);
  }

  Technique _pickTechniqueWithTier(double tierBonus) {
    // 基础权重
    final weights = {
      TechniqueGrade.fan: 60.0,
      TechniqueGrade.ling: 25.0,
      TechniqueGrade.xian: 10.0,
      TechniqueGrade.sheng: 4.0,
      TechniqueGrade.dao: 1.0,
    };
    // tier 提升高阶权重
    weights[TechniqueGrade.sheng] = weights[TechniqueGrade.sheng]! * (1 + tierBonus * 5);
    weights[TechniqueGrade.dao] = weights[TechniqueGrade.dao]! * (1 + tierBonus * 8);
    weights[TechniqueGrade.xian] = weights[TechniqueGrade.xian]! * (1 + tierBonus * 3);
    final pool = allTechPool();
    final total = pool.fold<double>(0, (s, t) => s + (weights[t.grade] ?? 1));
    double roll = rng.nextDouble() * total;
    for (final t in pool) {
      roll -= (weights[t.grade] ?? 1);
      if (roll <= 0) return t;
    }
    return pool.first;
  }

  void _rollRoot(PlayerState state, LifeEventConfig event) {
    final baseRoots = ['金', '木', '水', '火', '土', '风'];
    final variantRoots = ['雷', '阴', '阳'];
    String root = baseRoots[rng.nextInt(baseRoots.length)];
    if (rng.nextDouble() < 0.1) {
      root = variantRoots[rng.nextInt(variantRoots.length)];
    }
    double roll = rng.nextDouble();
    String grade = '凡';
    if (roll < 0.1 + state.luck / 200) {
      grade = '道';
    } else if (roll < 0.2 + state.luck / 150) {
      grade = '圣';
    } else if (roll < 0.4 + state.luck / 120) {
      grade = '灵';
    }
    state.talentLevelName = '$grade·$root';
    state.lifeEvents.add(
      LifeEventEntry(
        id: '${event.id}_result',
        age: state.age,
        title: '灵根结果',
        description: '检测结果：$root 系灵根，品级 $grade。',
      ),
    );
  }

  void applyEffects(
    PlayerState state,
    LifeEventConfig event, {
    Map<String, dynamic> extraEffects = const {},
    bool consumeAp = true,
  }) {
    final mergedEffects = {...event.effects, ...extraEffects};
    final ageDelta =
        mergedEffects['age'] is num ? (mergedEffects['age'] as num).round() : 0;
    state.age += ageDelta;

    // literacy flag
    if (mergedEffects['unlockLiteracy'] == true) {
      state.hasLiteracy = true;
    }
    if (consumeAp) {
      state.ap = max(0, state.ap - 1);
    }

    final delta = Map<String, num>.from(mergedEffects['delta'] ?? {});
    state.strength += delta['strength']?.toInt() ?? 0;
    state.intelligence += delta['intelligence']?.toInt() ?? 0;
    state.charm += delta['charm']?.toInt() ?? 0;
    state.luck += delta['luck']?.toInt() ?? 0;
    state.family += delta['family']?.toInt() ?? 0;

    if (mergedEffects['world'] != null) {
      final w = mergedEffects['world'] as String;
      if (w == 'immortal') {
        state.world = World.immortal;
        state.region = Region.xian;
      } else if (w == 'nether') {
        state.world = World.nether;
        state.region = Region.mo;
      } else {
        state.world = World.mortal;
      }
    }

    if (mergedEffects['ending'] != null) {
      state.ending = mergedEffects['ending'];
      state.alive = mergedEffects['alive'] == false ? false : true;
    }

    // 入宗门
    if (mergedEffects['sectId'] != null) {
      state.sectId = mergedEffects['sectId'];
      // 入宗后给予少量经验奖励与宗门声望事件
      state.exp += 20;
      state.lifeEvents.add(
        LifeEventEntry(
          id: 'join_sect_log',
          age: state.age,
          title: '加入宗门',
          description: '你正式加入了${mergedEffects['sectId']}，获得宗门资源倾斜。',
        ),
      );
    }

    if (event.id == 'age_6_root_test') {
      _rollRoot(state, event);
    }

    // 掉落功法：基础概率 5%，高 luck 提升
    // 功法掉落仅在已具备基础识字/修炼条件后触发（默认 age>=6 或已有功法/境界非无）
    final canLearnTech =
        state.age >= 6 || state.techniques.isNotEmpty || state.realm != '无';
    if (canLearnTech) {
      final tierBonus = _tierBonus(_currentFamilyTemplate(state)?.tier) +
          _tierBonus(_currentSect(state)?.tier);
      final techChance = 0.05 + state.luck / 500 + tierBonus;
      if (rng.nextDouble() < techChance) {
        final tech = _pickTechniqueWithTier(tierBonus);
        state.techniques.add(tech);
        state.lifeEvents.add(
          LifeEventEntry(
            id: 'gain_tech_${tech.name}',
            age: state.age,
            title: '获得功法',
            description: '你获得了 ${tech.name}（${tech.gradeLabel}·${tech.stageLabel}）。',
          ),
        );
      }
    }

    state.lifeEvents.add(
      LifeEventEntry(
        id: event.id,
        age: state.age,
        title: event.title,
        description: _mergeDescription(event.description, mergedEffects['log']),
        deltas: delta,
      ),
    );

    // 若 AP 用尽，不自动跳岁；交由玩家手动点击“跳到下一岁”
  }
}

String _mergeDescription(String base, dynamic extraLog) {
  if (extraLog == null) return base;
  return '$base\n$extraLog';
}
