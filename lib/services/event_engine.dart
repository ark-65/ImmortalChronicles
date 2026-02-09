import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/models.dart';
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
    final options = await pickOptions(state, count: 1);
    return options.first;
  }

  Future<List<LifeEventConfig>> pickOptions(PlayerState state, {int count = 3}) async {
    await repo.ensureLoaded();
    await refRepo.ensureLoaded();

    // 1. Check pending events first (story/mandatory)
    if (state.pendingEvents.isNotEmpty) {
      final pid = state.pendingEvents.removeAt(0);
      final event = repo.byId(pid);
      if (event != null && _meetsConditions(state, event)) {
        // Special guard for immortal exploration
        if ((event.id == 'immortal_retreat' || event.id == 'immortal_explore_random') &&
            (state.talentLevelName == '未知' || state.talentLevelName == '凡体')) {
          state.pendingEvents.insert(0, pid);
        } else {
          return [event]; // Return mandatory event as single option
        }
      } else if (event != null) {
        state.pendingEvents.insert(0, pid); // Defer
      }
    }

    // 2. Early priority events (Mandatory Root/Sect Tests)
    // Immortal Realm: Age 6 Root Awakening
    if (state.world == World.immortal &&
        state.age >= 6 &&
        (state.talentLevelName == '未知' || state.talentLevelName == '凡体') &&
        !state.lifeEvents.any((e) => e.id == 'age_6_root_immortal')) {
      final rootEvent = repo.byId('age_6_root_immortal');
      if (rootEvent != null) return [rootEvent];
    }

    // Mortal Realm: Age 12 Sect Recruitment
    if (state.world == World.mortal &&
        state.age >= 12 &&
        (state.talentLevelName == '未知' || state.talentLevelName == '凡体') &&
        !state.lifeEvents.any((e) => e.id == 'age_12_sect_mortal')) {
      final sectEvent = repo.byId('age_12_sect_mortal');
      if (sectEvent != null) return [sectEvent];
    }


    // 3. Normal pool selection
    final pool = _getTablePool(state);
    debugPrint('[EventEngine] Age: ${state.age}, World: ${state.world}, Tier: ${_currentFamilyTemplate(state)?.tier}');
    debugPrint('[EventEngine] Pool size pre-filter: ${pool.length}');

    final seen = <String>{};
    final candidates = pool.where((e) {
      if (seen.contains(e.id)) return false;
      seen.add(e.id);
      return _meetsConditions(state, e, checkChance: true);
    }).toList();

    if (candidates.isEmpty) {
      return [fallback(state)];
    }

    // If we only need one, or it's a "story" event that shouldn't be mixed
    // (For now, we just pick N unique ones from the candidates)
    final results = <LifeEventConfig>[];
    final workingCandidates = List<LifeEventConfig>.from(candidates);
    
    // Weighted selection for multiple options
    for (int i = 0; i < count && workingCandidates.isNotEmpty; i++) {
      final totalWeight = workingCandidates.fold<int>(0, (s, e) => s + e.weight);
      if (totalWeight <= 0) break;
      
      int roll = rng.nextInt(totalWeight);
      for (int j = 0; j < workingCandidates.length; j++) {
        final e = workingCandidates[j];
        roll -= e.weight;
        if (roll < 0) {
          results.add(e);
          workingCandidates.removeAt(j);
          break;
        }
      }
    }

    // 4. AP Check: If out of AP and no pending, return Next Year trigger instead of nothing
    if (state.ap <= 0 && state.pendingEvents.isEmpty) {
      return [nextYearFallback(state)];
    }

    return results.isNotEmpty ? results : [fallback(state)];
  }

  LifeEventConfig nextYearFallback(PlayerState state) {
    return LifeEventConfig(
      id: 'tick_next_year',
      title: '进入下一岁',
      description: '岁月流转，跨入新的一年。',
      worlds: [state.world],
      effects: const {'nextYear': true},
    );
  }

  List<LifeEventConfig> _getTablePool(PlayerState state) {
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
      agePool = repo.table('mortal_daily') + repo.table('immortal_daily') + repo.table('nether_daily');
    }

    return [
      ...agePool,
      ...repo.tableClanChance(),
      ...repo.tableSectChance(),
      ...repo.tableWorldDaily(state.world),
    ];
  }

  bool _meetsConditions(PlayerState state, LifeEventConfig e, {bool checkChance = false}) {
    // Basic checks: World, Region, Age
    if (!e.worlds.contains(state.world)) return false;
    if (e.regions != null && !e.regions!.contains(state.region)) return false;
    if (e.minAge != null && state.age < e.minAge!) return false;
    if (e.maxAge != null && state.age > e.maxAge!) return false;

    // Binding checks: Map, Family Tier
    if (e.mapIds != null && (state.currentMapId == null || !e.mapIds!.contains(state.currentMapId))) {
      return false;
    }
    if (e.familyTiers != null) {
      var tier = _currentFamilyTemplate(state)?.tier;
      // Robustness: If no family template (e.g. data error or poor start), map to lowest tier
      if (tier == null) {
        if (state.world == World.mortal) {
          tier = '人'; // Matches 'Poor' events
        } else {
          tier = '灵界普通家族'; // Matches 'Rogue/Minor' events
        }
      }
      
      // Special handling: Map '九品' through '五品' to generic 'Poor' if needed, 
      // but currently the event files list all specific tiers.
      
      // Tier Coercion for World Mismatch (e.g. Immortal World but Mortal Tier due to data fallback)
      if (state.world == World.immortal && 
          ['一品', '二品', '三品', '四品', '五品', '六品', '七品', '八品', '九品', '人'].contains(tier)) {
        tier = '灵界普通家族';
      }

      if (!e.familyTiers!.contains(tier)) {
        // debugPrint('[EventEngine] Filtered ${e.id} due to tier mismatch. Player: $tier, Event needs: ${e.familyTiers}');
        return false;
      }
    }

    // Prerequisite checks
    for (final pre in e.prerequisites) {
      if (!_checkPrerequisite(state, pre)) return false;
    }

    // Config conditions
    final stage = refRepo.currentStage(state.age);
    if (e.conditions['needsLiteracy'] == true && (!stage.allowLiteracy || !state.hasLiteracy)) {
      return false;
    }
    if (e.conditions['needsCultivation'] == true &&
        (!stage.allowCultivation || state.realm == '无' || !state.canCultivate)) {
      return false;
    }
    if (e.conditions['needsNonCultivation'] == true && state.canCultivate) {
      return false;
    }
    if (e.conditions['unique'] == true && state.lifeEvents.any((ev) => ev.id == e.id)) {
      return false;
    }

    // Chance check
    if (checkChance && e.conditions.containsKey('chance')) {
      double p = (e.conditions['chance'] as num).toDouble();
      if (e.conditions.containsKey('chanceLuckBoost')) {
        p += (state.luck / 100) * (e.conditions['chanceLuckBoost'] as num).toDouble();
      }
      if (rng.nextDouble() > p.clamp(0.0, 1.0)) return false;
    }

    // Protection check: Filter out death events if user is protected
    if (state.isProtectedFrom(e)) {
      return false;
    }

    return true;
  }

  bool _checkPrerequisite(PlayerState state, String pre) {
    switch (pre) {
      case 'root_awakened':
        return state.talentLevelName != '未知' && state.talentLevelName != '凡体';
      case 'cultivation_started':
        return state.realm != '无' && state.canCultivate;
      case 'non_cultivation':
        return !state.canCultivate;
      case 'sect_accepted':
        return state.sectId != null;
      case 'top_family_only':
        return state.familyScore >= 95;
      case 'non_top_family_only':
        return state.familyScore < 95;
      default:
        return true;
    }
  }

  LifeEventConfig fallback(PlayerState state) {
    // 1. Toddler Fallback (Age 0-3): Should NOT advance age automatically
    if (state.age <= 3) {
      return LifeEventConfig(
        id: 'toddler_fallback',
        title: '牙牙学语',
        description: '你还太小，除了玩耍和睡觉，什么也做不了。',
        worlds: [state.world],
        effects: const {'age': 0, 'exp': 1}, // No age increase
      );
    }

    final byKey = repo.byId('${state.world.name}_fallback');
    if (byKey != null) {
      if (_meetsConditions(state, byKey)) return byKey;
    }
    final daily = repo.tableWorldDaily(state.world);
    if (daily.isNotEmpty) return daily[rng.nextInt(daily.length)];
    
    // Last resort fallback
    return LifeEventConfig(
      id: 'empty_fallback',
      title: '平平无奇的一年',
      description: '什么都没发生。',
      worlds: [state.world],
      effects: const {'age': 1},
    );
  }


  FamilyTemplate? _currentFamilyTemplate(PlayerState state) {
    if (state.familyTemplateId == null) return null;
    if (refRepo.families.isEmpty) return null;
    return refRepo.families.firstWhere((f) => f.id == state.familyTemplateId,
        orElse: () => refRepo.families.first);
  }

  void _grantFamilyTechnique(PlayerState state) {
    final tpl = _currentFamilyTemplate(state);
    if (tpl == null || tpl.coreTechniqueIds.isEmpty) return;
    
    // Grant all core techniques specified by the family
    for (final techId in tpl.coreTechniqueIds) {
      final tplTech = refRepo.techniqueById(techId);
      if (tplTech == null) continue;

      final existingIndex = state.techniques.indexWhere((t) => t.id == techId || t.name == tplTech.name);
      if (existingIndex != -1) {
        // Already has it, small proficiency boost
        final t = state.techniques[existingIndex];
        t.exp += (t.expRequired * 0.1).round();
        if (t.exp >= t.expRequired) {
          // Level up proficiency stage if possible
          if (t.stage.index < ProficiencyStage.values.length - 1) {
            t.stage = ProficiencyStage.values[t.stage.index + 1];
            t.exp = 0;
            t.expRequired = (t.expRequired * 1.5).round();
          }
        }
      } else {
        // New technique
        state.techniques.add(Technique(
          id: tplTech.id,
          name: tplTech.name,
          type: tplTech.type,
          grade: tplTech.grade,
          rank: tplTech.rank,
          elements: tplTech.elements,
          description: tplTech.description,
          stage: ProficiencyStage.chuKui,
          exp: 0,
          expRequired: tplTech.expRequired,
        ));
      }
    }
  }


  void _syncRealmStage(PlayerState state, {bool resetExp = false}) {
    final layers = refRepo.realmLayers[state.realm] ??
        const [200];
    if (resetExp || !layers.contains(state.expRequired)) {
      state.exp = 0;
      state.expRequired = layers.first;
    }
  }

  double _tierBonus(String? tier) {
    switch (tier) {
      case '霸主': return 0.1;
      case '圣地': return 0.07;
      case '天': return 0.05;
      case '地': return 0.03;
      case '人': return 0.0;
      default: return 0.0;
    }
  }

  SectTemplate? _currentSect(PlayerState state) {
    if (state.sectId == null) return null;
    return refRepo.sects.firstWhere((s) => s.id == state.sectId,
        orElse: () => refRepo.sects.first);
  }

  Technique _pickTechniqueWithTier(double tierBonus) {
    // Weights for major Grade (Fan, Ling, Xian, Sheng, Dao)
    final gradeWeights = {
      TechniqueGrade.fan: 60.0,
      TechniqueGrade.ling: 25.0,
      TechniqueGrade.xian: 10.0,
      TechniqueGrade.sheng: 4.0,
      TechniqueGrade.dao: 1.0,
    };
    gradeWeights[TechniqueGrade.sheng] = gradeWeights[TechniqueGrade.sheng]! * (1 + tierBonus * 5);
    gradeWeights[TechniqueGrade.dao] = gradeWeights[TechniqueGrade.dao]! * (1 + tierBonus * 8);
    gradeWeights[TechniqueGrade.xian] = gradeWeights[TechniqueGrade.xian]! * (1 + tierBonus * 3);

    // Weights for quality Rank (SSS to F)
    final rankWeights = {
      OpportunityTier.sss: 10.0,
      OpportunityTier.ss: 20.0,
      OpportunityTier.s: 40.0,
      OpportunityTier.a: 60.0,
      OpportunityTier.b: 80.0,
      OpportunityTier.c: 100.0,
      OpportunityTier.d: 120.0,
      OpportunityTier.e: 140.0,
      OpportunityTier.f: 160.0,
    };
    rankWeights[OpportunityTier.sss] = rankWeights[OpportunityTier.sss]! * (1 + tierBonus * 10);
    rankWeights[OpportunityTier.ss] = rankWeights[OpportunityTier.ss]! * (1 + tierBonus * 5);
    
    final pool = refRepo.techniques;
    if (pool.isEmpty) throw StateError('No techniques loaded');

    final total = pool.fold<double>(0, (s, t) {
      double weight = (gradeWeights[t.grade] ?? 1.0) * (rankWeights[t.rank] ?? 10.0);
      return s + weight;
    });

    double roll = rng.nextDouble() * total;
    for (final t in pool) {
      double weight = (gradeWeights[t.grade] ?? 1.0) * (rankWeights[t.rank] ?? 10.0);
      roll -= weight;
      if (roll <= 0) {
        return t;
      }
    }
    return pool.first;
  }

  void _rollRoot(PlayerState state, LifeEventConfig event) {
    final basics = refRepo.elementCategories.firstWhere((c) => c.id == 'basic', orElse: () => ElementCategory(id: 'basic', name: '基础', elements: ['金', '木', '水', '火', '土'])).elements;
    final variants = refRepo.elementCategories.firstWhere((c) => c.id == 'variant', orElse: () => ElementCategory(id: 'variant', name: '变异', elements: ['雷', '风', '冰', '阴', '阳', '毒'])).elements;

    final variantChance = (0.1 + state.luck / 400).clamp(0.0, 0.35);
    
    String pickRoot() {
      bool isVar = rng.nextDouble() < variantChance;
      final pool = isVar ? variants : basics;
      return (isVar ? '变异·' : '') + pool[rng.nextInt(pool.length)];
    }

    final dualChance = (0.05 + state.luck / 500).clamp(0.0, 0.2);
    final isDual = rng.nextDouble() < dualChance;
    String root1 = pickRoot();
    String? root2;
    if (isDual) {
      do { root2 = pickRoot(); } while (root2 == root1);
    }

    double roll = rng.nextDouble();
    final luckFactor = (state.luck.clamp(0, 20)) / 20.0;
    final pDao = 0.05 + 0.15 * luckFactor;
    final pSheng = 0.15 + 0.20 * luckFactor;
    final pLing = 0.40 + 0.20 * luckFactor;

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

    if (state.familyScore >= 90 && grade == '凡') grade = '灵';

    final rootsLabel = isDual ? '$root1 / $root2' : root1;
    state.talentLevelName = '$grade·$rootsLabel';

    state.lifeEvents.add(
      LifeEventEntry(
        id: '${event.id}_result',
        age: state.age,
        title: '灵根结果·$grade·$rootsLabel',
        description: '检测结果：$rootsLabel，品级 $grade。',
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
    final mergedDelta = <String, num>{};
    if (event.effects['delta'] is Map) {
      (event.effects['delta'] as Map).forEach((k, v) => mergedDelta[k] = (v as num));
    }
    if (extraEffects['delta'] is Map) {
      (extraEffects['delta'] as Map).forEach((k, v) => mergedDelta[k] = (mergedDelta[k] ?? 0) + (v as num));
    }

    // Force age to NOT update unless it's the explicit 'Next Year' event
    // This addresses user request to remove "auto-aging" from random events
    if (event.id == 'tick_next_year') {
      state.age += mergedEffects['age'] is num ? (mergedEffects['age'] as num).round() : 0;
    } else {
      // standard events do NOT increase age
    }
    if (mergedEffects['unlockLiteracy'] == true) state.hasLiteracy = true;
    if (mergedEffects['talentLevelName'] != null) state.talentLevelName = mergedEffects['talentLevelName'];
    if (mergedEffects['realm'] != null) {
      state.realm = mergedEffects['realm'];
      _syncRealmStage(state, resetExp: mergedEffects['resetRealmExp'] == true);
    }
    if (mergedEffects['setExp'] != null) state.exp = (mergedEffects['setExp'] as num).round();
    if (mergedEffects['setExpRequired'] != null) state.expRequired = (mergedEffects['setExpRequired'] as num).round();
    if (mergedEffects['learnFamilyTechnique'] == true) {
      _grantFamilyTechnique(state);
      state.realm = '炼气';
      _syncRealmStage(state, resetExp: true);
    }
    if (mergedEffects['canCultivate'] != null) state.canCultivate = mergedEffects['canCultivate'] == true;
    if (mergedEffects['pendingEvents'] is List) state.pendingEvents.addAll((mergedEffects['pendingEvents'] as List).cast<String>());
    
    // Support for duration-based Decision Rounds
    if (event.duration != null && event.duration! > 0) {
      // For each year of duration, push a round event to pending
      // Assuming a convention where [id]_round is the event used for manual decisions
      final roundId = '${event.id}_round';
      for (int i = 0; i < event.duration!; i++) {
        state.pendingEvents.add(roundId);
      }
    }

    if (consumeAp) state.ap = max(0, state.ap - 1);

    final delta = Map<String, num>.from(mergedDelta);
    num expDelta = delta['exp'] ?? 0;
    if (expDelta != 0) {
      double mult = gradeMultiplier(state.talentLevelName);
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
      state.world = w == 'immortal' ? World.immortal : (w == 'nether' ? World.nether : World.mortal);
      state.region = state.world == World.immortal ? Region.xian : (state.world == World.nether ? Region.mo : Region.ren);
      state.currentMapId = refRepo.defaultMapFor(state.world).id;
    }

    if (mergedEffects['ending'] != null) {
      // Final guard: check if protected during effect application
      if (state.isProtectedFrom(event)) {
        state.lifeEvents.add(LifeEventEntry(
          id: 'protection_triggered',
          age: state.age,
          title: '因果护体',
          description: '一股神秘的力量（家境/气运）护住了你，化解了致命危机。',
        ));
      } else {
        state.ending = mergedEffects['ending'];
        state.alive = mergedEffects['alive'] != false;
      }
    }

    if (mergedEffects['sectId'] != null) state.sectId = mergedEffects['sectId'];
    if (mergedEffects['nextYear'] == true) state.nextYear();

    if (event.id == 'age_6_root_test' || 
        event.id == 'age_6_root_immortal' || 
        event.id == 'age_12_sect_mortal') {
      _rollRoot(state, event);
      
      // Special branching for Mortal Age 12 Sect Test
      if (event.id == 'age_12_sect_mortal') {
         // Determine success based on talent
         // Assuming '凡体' and '废品' (if exists) are failures for Sects
         if (state.talentLevelName == '凡体' || state.talentLevelName.contains('废')) {
           state.pendingEvents.add('age_12_sect_fail');
           state.canCultivate = false; // Ensure it stays closed
         } else {
           state.pendingEvents.add('age_12_sect_success');
           // Success event will handle enabling cultivation
         }
      }
    }

    // Technique drop
    final canLearnTech = state.age >= 6 || state.techniques.isNotEmpty || state.realm != '无';
    if (canLearnTech && refRepo.techniques.isNotEmpty) {
      final tierBonus = _tierBonus(_currentFamilyTemplate(state)?.tier) + _tierBonus(_currentSect(state)?.tier);
      if (rng.nextDouble() < (0.05 + state.luck / 500 + tierBonus)) {
        final tplTech = _pickTechniqueWithTier(tierBonus);
        final existingIndex = state.techniques.indexWhere((t) => t.id == tplTech.id);
        if (existingIndex != -1) {
          state.techniques[existingIndex].exp += 10; // Minimal boost for generic drop
        } else {
          state.techniques.add(Technique(
            id: tplTech.id,
            name: tplTech.name,
            type: tplTech.type,
            grade: tplTech.grade,
            rank: tplTech.rank,
            elements: tplTech.elements,
            description: tplTech.description,
            stage: ProficiencyStage.chuKui,
            exp: 0,
            expRequired: tplTech.expRequired,
          ));
        }
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
  }

  double gradeMultiplier(String grade) {
    if (grade.contains('混沌')) return 10.0;
    if (grade.contains('先天道体')) return 5.0;
    if (grade.contains('道')) return 3.0;
    if (grade.contains('圣')) return 2.0;
    if (grade.contains('天')) return 1.5;
    if (grade.contains('灵')) return 1.0;
    if (grade.contains('杂')) return 0.5;
    if (grade.contains('废')) return 0.2;
    return 0.6;
  }

  String _mergeDescription(String base, dynamic extraLog) {
    if (extraLog == null) return base;
    return '$base\n$extraLog';
  }
}
