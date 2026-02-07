import 'dart:math';

import '../models/models.dart';
import '../data/stages.dart';
import '../data/event_repository.dart';
import '../data/reference_repository.dart';

class EventEngine {
  final Random rng;
  final EventRepository repo;
  final ReferenceRepository refRepo;

  EventEngine(int seed)
      : rng = Random(seed),
        repo = EventRepository(),
        refRepo = ReferenceRepository();

  Future<LifeEventConfig> pickEvent(PlayerState state) async {
    await repo.ensureLoaded();
    await refRepo.ensureLoaded();
    // pending first
    if (state.pendingEvents.isNotEmpty) {
      final pendingCount = state.pendingEvents.length;
      for (int i = 0; i < pendingCount; i++) {
        final pid = state.pendingEvents.removeAt(0);
        final fromPending = repo.byId(pid) ?? fallback(state);
        final ready = (fromPending.minAge == null ||
                state.age >= fromPending.minAge!) &&
            (fromPending.maxAge == null || state.age <= fromPending.maxAge!) &&
            fromPending.worlds.contains(state.world) &&
            (fromPending.regions == null ||
                fromPending.regions!.contains(state.region));
        // 不满足前置(root/cultivation/sect/family)时也不能触发
        final stage = currentStage(state.age);
        final prereqOk = !fromPending.prerequisites.contains('root_awakened') ||
            (state.talentLevelName != '未知' && state.talentLevelName != '凡体');
        final cultOk =
            !fromPending.prerequisites.contains('cultivation_started') ||
                (state.realm != '无' && state.canCultivate);
        final nonCultOk =
            !fromPending.prerequisites.contains('non_cultivation') ||
                !state.canCultivate;
        final sectOk = !fromPending.prerequisites.contains('sect_accepted') ||
            state.sectId != null;
        final topOk = !fromPending.prerequisites.contains('top_family_only') ||
            state.familyScore >= 95;
        final nonTopOk =
            !fromPending.prerequisites.contains('non_top_family_only') ||
                state.familyScore < 95;
        final litOk = fromPending.conditions['needsLiteracy'] != true ||
            state.hasLiteracy;
        final cultCondOk = fromPending.conditions['needsCultivation'] != true ||
            (stage.allowCultivation &&
                state.realm != '无' &&
                state.canCultivate);
        final nonCultCondOk =
            fromPending.conditions['needsNonCultivation'] != true ||
                !state.canCultivate;

        final allReady = ready &&
            prereqOk &&
            cultOk &&
            nonCultOk &&
            sectOk &&
            topOk &&
            nonTopOk &&
            litOk &&
            cultCondOk &&
            nonCultCondOk;

        if (allReady) {
          // guard: 仙界修行/游历必须觉醒灵根
          if (fromPending.id == 'immortal_retreat' ||
              fromPending.id == 'immortal_explore_random') {
            if (state.talentLevelName == '未知' ||
                state.talentLevelName == '凡体') {
              state.pendingEvents.add(pid);
              continue;
            }
          }
          return fromPending;
        } else {
          state.pendingEvents.add(pid); // defer to later age/condition
        }
      }
    }

    // 强制 6+ 岁未觉醒时优先触发灵根检测（防止被其他事件抢占）
    if ((state.talentLevelName == '未知' || state.talentLevelName == '凡体') &&
        state.age >= 6 &&
        state.age <= 12 &&
        !state.lifeEvents.any((e) =>
            e.id == 'age_6_root_test' || e.id == 'age_6_root_test_result')) {
      final rootEvent = repo.byId('age_6_root_test');
      if (rootEvent != null) return rootEvent;
    }

    final stage = currentStage(state.age);
    final isTopFamily = state.familyScore >= 95;

    List<LifeEventConfig> agePool;
    if (state.age <= 3) {
      agePool = repo.tableAge0to3();
    } else if (state.age <= 6) {
      agePool = repo.tableAge4to6();
    } else if (state.age <= 12) {
      agePool = repo.tableAge7to12();
    } else if (state.age <= 18) {
      agePool = repo.tableAge13to18();
    } else {
      // TODO: 日常/高阶表后续拆分
      agePool = repo.table('mortal_daily') +
          repo.table('immortal_daily') +
          repo.table('nether_daily');
    }
    // 合并家族/宗门机缘表
    final mergedPool = [
      ...agePool,
      ...repo.tableClanChance(),
      ...repo.tableSectChance(),
      ...repo.tableWorldDaily(state.world),
    ];
    final seen = <String>{};
    final uniquePool = mergedPool.where((e) => seen.add(e.id)).toList();

    final candidates = uniquePool.where((e) {
      if (!e.worlds.contains(state.world)) return false;
      if (e.regions != null && !e.regions!.contains(state.region)) return false;
      if (e.minAge != null && state.age < e.minAge!) return false;
      if (e.maxAge != null && state.age > e.maxAge!) return false;
      // prerequisite flags
      if (e.prerequisites.contains('root_awakened') &&
          (state.talentLevelName == '未知' || state.talentLevelName == '凡体')) {
        return false;
      }
      if (e.prerequisites.contains('cultivation_started') &&
          (state.realm == '无' || !state.canCultivate)) {
        return false;
      }
      if (e.prerequisites.contains('non_cultivation') && state.canCultivate) {
        return false;
      }
      if (e.prerequisites.contains('sect_accepted') && state.sectId == null) {
        return false;
      }
      if (e.prerequisites.contains('top_family_only') && !isTopFamily) {
        return false;
      }
      if (e.prerequisites.contains('non_top_family_only') && isTopFamily) {
        return false;
      }
      if (e.conditions['needsLiteracy'] == true &&
          (!stage.allowLiteracy || !state.hasLiteracy)) {
        return false;
      }
      if (e.conditions['needsCultivation'] == true &&
          (!stage.allowCultivation ||
              state.realm == '无' ||
              !state.canCultivate)) {
        return false;
      }
      if (e.conditions['needsNonCultivation'] == true && state.canCultivate) {
        return false;
      }
      if (e.conditions['unique'] == true &&
          state.lifeEvents.any((ev) => ev.id == e.id)) {
        return false;
      }
      if (e.conditions.containsKey('chance')) {
        double p = (e.conditions['chance'] as num).toDouble();
        if (e.conditions.containsKey('chanceLuckBoost')) {
          final boost = (e.conditions['chanceLuckBoost'] as num).toDouble();
          p += (state.luck / 100) * boost;
          if (p > 1) p = 1;
          if (p < 0) p = 0;
        }
        if (rng.nextDouble() > p) return false;
      }
      return true;
    }).toList();

    if (candidates.isEmpty) {
      // 若已觉醒且在修炼，强制提供当前世界日常修炼/苟活事件作为兜底
      if (state.talentLevelName != '未知' && state.realm != '无') {
        final daily = repo.tableWorldDaily(state.world);
        if (daily.isNotEmpty) return daily[rng.nextInt(daily.length)];
      }
      return fallback(state);
    }
    // weighted random
    final total = candidates.fold<int>(0, (s, e) => s + e.weight);
    int roll = rng.nextInt(total);
    for (final e in candidates) {
      roll -= e.weight;
      if (roll < 0) return e;
    }
    return candidates.first;
  }

  LifeEventConfig fallback(PlayerState state) {
    final byKey = repo.byId('${state.world.name}_fallback');
    if (byKey != null) {
      final requiresNonCult = byKey.prerequisites.contains('non_cultivation') ||
          byKey.conditions['needsNonCultivation'] == true;
      if (requiresNonCult && state.canCultivate) {
        // skip non-cultivation fallback when已走修行路
      } else {
        return byKey;
      }
    }
    final daily = repo.tableWorldDaily(state.world);
    if (daily.isNotEmpty) return daily[rng.nextInt(daily.length)];
    // 最后的兜底：任意已有事件或一个默认占位
    if (repo.byId('mortal_fallback') != null) {
      return repo.byId('mortal_fallback')!;
    }
    return LifeEventConfig(
      id: 'empty_fallback',
      title: '平平无奇的一年',
      description: '什么都没发生。',
      worlds: [state.world],
      effects: const {'age': 1},
    );
  }

  SectTemplate _randomSectFor(World world) {
    List<SectTemplate> pool;
    switch (world) {
      case World.immortal:
        pool = refRepo.sects
            .where((s) => s.tier == '圣地' || s.tier == '霸主')
            .toList();
        break;
      case World.mortal:
        pool = refRepo.sects
            .where((s) => s.tier == '天' || s.tier == '地' || s.tier == '人')
            .toList();
        break;
      case World.nether:
        pool = refRepo.sects; // 简化：魔界也允许全表
        break;
    }
    if (pool.isEmpty) pool = refRepo.sects;
    return pool[rng.nextInt(pool.length)];
  }

  FamilyTemplate? _currentFamilyTemplate(PlayerState state) {
    if (state.familyTemplateId == null) return null;
    return refRepo.families.firstWhere((f) => f.id == state.familyTemplateId,
        orElse: () => refRepo.families.first);
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
    return refRepo.sects.firstWhere((s) => s.id == state.sectId,
        orElse: () => refRepo.sects.first);
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
    weights[TechniqueGrade.sheng] =
        weights[TechniqueGrade.sheng]! * (1 + tierBonus * 5);
    weights[TechniqueGrade.dao] =
        weights[TechniqueGrade.dao]! * (1 + tierBonus * 8);
    weights[TechniqueGrade.xian] =
        weights[TechniqueGrade.xian]! * (1 + tierBonus * 3);
    final pool = refRepo.techniques;
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
    final variantChance = (0.1 + state.luck / 400).clamp(0.0, 0.35);
    String pickRoot() {
      bool isVar = rng.nextDouble() < variantChance;
      final pool = isVar ? variantRoots : baseRoots;
      return (isVar ? '变异·' : '') + pool[rng.nextInt(pool.length)];
    }

    // 是否双灵根：基础 5% + luck/500，上限 20%
    final dualChance = (0.05 + state.luck / 500).clamp(0.0, 0.2);
    final isDual = rng.nextDouble() < dualChance;

    String root1 = pickRoot();
    String? root2;
    if (isDual) {
      do {
        root2 = pickRoot();
      } while (root2 == root1);
    }

    // 品阶概率随气运（创角幸运上限约 20 点，做 0-20 线性映射）
    double roll = rng.nextDouble();
    final luckFactor = (state.luck.clamp(0, 20)) / 20.0;
    final pDao = 0.05 + 0.15 * luckFactor; // 5% -> 20%
    final pSheng = 0.15 + 0.20 * luckFactor; // 15% -> 35%  (累积到 55%)
    final pLing = 0.40 + 0.20 * luckFactor; // 40% -> 60%  (累积到 ~1.15, 取上限)

    double thresholdDao = pDao;
    double thresholdSheng = (thresholdDao + pSheng).clamp(0.0, 0.95);
    double thresholdLing = (thresholdSheng + pLing).clamp(0.0, 0.99);

    String grade = '凡';
    if (roll < thresholdDao) {
      grade = '道';
    } else if (roll < thresholdSheng) {
      grade = '圣';
    } else if (roll < thresholdLing) {
      grade = '灵';
    }

    // 顶级及以上家境保底：familyScore>=90 至少灵阶
    if (state.familyScore >= 90 && (grade == '凡')) grade = '灵';

    String visualOf(String r) {
      final key = r.replaceAll('变异·', '');
      return switch (key) {
        '金' => '金光如剑锋直刺天际',
        '木' => '翠绿藤纹在光柱中缠绕',
        '水' => '清光如波，水雾弥漫台阶',
        '火' => '赤焰升腾，热浪扑面',
        '土' => '厚重黄光稳如山岳',
        '风' => '青光流转，如风刃环绕',
        '雷' => '紫电游走，轰鸣震耳',
        '阴' => '幽光森冷，似有鬼魅低语',
        '阳' => '炽白光耀，温暖充盈四方',
        _ => '灵光旋绕',
      };
    }

    String comment = switch (grade) {
      '道' => '长老们面露震惊，纷纷上前争抢收徒。',
      '圣' => '族中子弟屏息，私语称你为天骄之姿。',
      '灵' => '旁人投来艳羡目光，称你有望入内门。',
      _ => '族人摇头叹息，觉得资质平平只能勤补拙。',
    };

    final rootsLabel = isDual ? '$root1 / $root2' : root1;
    state.talentLevelName = '$grade·$rootsLabel';

    final visuals = isDual
        ? '灵光交织：${visualOf(root1)}；${visualOf(root2!)}。'
        : '灵光冲天：${visualOf(root1)}。';
    final variantNote =
        (root1.startsWith('变异') || (root2?.startsWith('变异') ?? false))
            ? '出现稀有变异灵根。'
            : '';
    final dualNote = isDual ? '双灵根共振，潜力倍增。' : '';

    state.lifeEvents.add(
      LifeEventEntry(
        id: '${event.id}_result',
        age: state.age,
        title: '灵根结果·$grade·$rootsLabel',
        description:
            '$visuals 检测结果：$rootsLabel，品级 $grade。$variantNote$dualNote$comment',
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
    // merge delta maps加和
    final mergedDelta = <String, num>{};
    if (event.effects['delta'] is Map) {
      (event.effects['delta'] as Map).forEach((k, v) {
        mergedDelta[k] = (v as num);
      });
    }
    if (extraEffects['delta'] is Map) {
      (extraEffects['delta'] as Map).forEach((k, v) {
        mergedDelta[k] = (mergedDelta[k] ?? 0) + (v as num);
      });
    }
    if (mergedDelta.isNotEmpty) {
      mergedEffects['delta'] = mergedDelta;
    }
    final ageDelta =
        mergedEffects['age'] is num ? (mergedEffects['age'] as num).round() : 0;
    state.age += ageDelta;

    // literacy flag
    if (mergedEffects['unlockLiteracy'] == true) {
      state.hasLiteracy = true;
    }
    if (mergedEffects['talentLevelName'] != null) {
      state.talentLevelName = mergedEffects['talentLevelName'];
    }
    if (mergedEffects['realm'] != null) {
      state.realm = mergedEffects['realm'];
    }
    if (mergedEffects['canCultivate'] != null) {
      state.canCultivate = mergedEffects['canCultivate'] == true;
    }
    if (mergedEffects['pendingEvents'] is List) {
      state.pendingEvents.addAll(
        (mergedEffects['pendingEvents'] as List).cast<String>(),
      );
    }
    if (mergedEffects['sectId'] == 'random') {
      state.sectId = _randomSectFor(state.world).id;
    }
    if (consumeAp) {
      state.ap = max(0, state.ap - 1);
    }

    final delta = Map<String, num>.from(mergedEffects['delta'] ?? {});
    // 经验随灵根品阶调整：灵=1.0，道=1.4，圣=1.2，凡=0.8
    num expDelta = delta['exp'] ?? 0;
    if (expDelta != 0) {
      double mult = 1.0;
      final grade = state.talentLevelName;
      if (grade.startsWith('道')) {
        mult = 1.4;
      } else if (grade.startsWith('圣')) {
        mult = 1.2;
      } else if (grade.startsWith('灵')) {
        mult = 1.0;
      } else if (grade.startsWith('凡')) {
        mult = 0.8;
      } else {
        mult = 0.6;
      }
      expDelta = (expDelta * mult).round();
      delta['exp'] = expDelta;
    }
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
        state.region = Region.ren;
      }
      // 世界跃迁后重置默认地图
      state.currentMapId = refRepo.defaultMapFor(state.world).id;
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
            description:
                '你获得了 ${tech.name}（${tech.gradeLabel}·${tech.stageLabel}）。',
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
