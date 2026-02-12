import 'package:flutter/material.dart';
import 'dart:math';

import '../models/models.dart';
import '../services/storage_service.dart';
import 'adventure_page.dart';
import '../data/reference_repository.dart';

final _refRepo = ReferenceRepository();

({String father, String mother}) _pickParentRoles({required int familyScore, required int luck}) {
  if (familyScore >= 90) return (father: '长生大能', mother: '仙族神女');
  if (familyScore >= 70) return (father: '世家之主', mother: '隐世传人');
  if (familyScore >= 50) return (father: '修仙名宿', mother: '宗门长老');
  if (familyScore >= 30) return (father: '商贾巨富', mother: '书香门第');
  return (father: '老实巴交的农夫', mother: '勤劳质朴的村妇');
}

FamilyTemplate _pickFamilyTemplate(int familyScore) {
  final families = _refRepo.families;
  // Support both 0-20 scale (default) and 0-100+ (modded)
  final score = familyScore > 20 ? familyScore.clamp(0, 100) : (familyScore * 5).clamp(0, 100);
  final rng = Random();

  List<FamilyTemplate> byTier(String tier) =>
      families.where((f) => f.tier == tier).toList();

  if (score == 100) {
    final pool = rng.nextDouble() < 0.3 ? byTier('霸主') : byTier('顶级');
    if (pool.isNotEmpty) return pool[rng.nextInt(pool.length)];
  }
  if (score >= 95) {
    final pool = rng.nextDouble() < 0.2 ? byTier('霸主') : byTier('顶级');
    if (pool.isNotEmpty) return pool[rng.nextInt(pool.length)];
  }
  if (score >= 90) {
    final pool = byTier('顶级');
    if (pool.isNotEmpty) return pool[rng.nextInt(pool.length)];
  }
  if (score >= 70) {
    final pool = byTier('仙族');
    if (pool.isNotEmpty) return pool[rng.nextInt(pool.length)];
  }
  if (score >= 50) {
    final pool = byTier('一品');
    if (pool.isNotEmpty) return pool[rng.nextInt(pool.length)];
  }
  if (score >= 30) {
    final pool = byTier('二品');
    if (pool.isNotEmpty) return pool[rng.nextInt(pool.length)];
  }
  final mundanePool = families
      .where((f) =>
          ['一品', '二品', '三品', '四品', '五品', '六品', '七品', '八品', '九品']
              .contains(f.tier))
      .toList();
  if (mundanePool.isNotEmpty) return mundanePool[rng.nextInt(mundanePool.length)];
  if (families.isNotEmpty) return families.first;
  // Final hardcoded fallback if asset loading failed completely
  return const FamilyTemplate(
    id: 'mundane_fallback',
    name: '平民百姓',
    elements: [],
    weapons: [],
    coreTechniqueIds: [],
    tier: '九品',
  );
}


class AttributeSetupPage extends StatefulWidget {
  const AttributeSetupPage({super.key});

  @override
  State<AttributeSetupPage> createState() => _AttributeSetupPageState();
}

class _AttributeSetupPageState extends State<AttributeSetupPage> {
  final _nameController = TextEditingController(text: '无名氏');
  int strength = 0;
  int intelligence = 0;
  int charm = 0;
  int luck = 0;
  int family = 0;
  bool _isInitialized = false;
  static const totalPoints = 30;

  int _costFor(int val) {
    if (val <= 10) return val; // 1:1
    if (val <= 20) return 10 + (val - 10) * 2; // 1.5x approx via int math
    return 10 + 20 + (val - 20) * 3; // steeper after 20
  }

  int get used => _costFor(strength) + _costFor(intelligence) + _costFor(charm) + _costFor(luck) + _costFor(family);
  int get remain => totalPoints - used;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _refRepo.ensureLoaded();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  LifeEventEntry _buildBirthIntro(PlayerState state) {
    String regionName = switch (state.region) {
      Region.xian => '仙界',
      Region.sheng => '圣界',
      Region.shen => '神界',
      Region.ling => '灵界',
      Region.mo => '魔界',
      _ => '人界',
    };
    final fs = state.familyScore;
    final parentRoles = _pickParentRoles(familyScore: fs, luck: state.luck);
    
    String flavorText;
    String parentRealm;
    
    if (fs >= 90) {
      flavorText = '家族坐拥数十座仙山，供奉护道者与执法堂，威震一方。';
      parentRealm = '父亲修为深不可测，母亲亦是得道大能';
    } else if (fs >= 70) {
      flavorText = '族人逾千，设有功法阁与试炼场，在灵界颇具威望。';
      parentRealm = '合体期父亲与炼虚期母亲';
    } else if (fs >= 50) {
      flavorText = '族人数百，偶有外门客卿坐镇，算是一方豪强。';
      parentRealm = '元婴期父母';
    } else if (fs >= 30) {
      flavorText = '城中有产业与护院，但缺少修真底蕴，但在凡俗界已是富甲一方。';
      parentRealm = '练气高层的父母';
    } else if (fs >= 10) {
      flavorText = '三代同堂，靠勤勉度日，日子平淡而温馨。';
      parentRealm = '凡人父母';
    } else {
      flavorText = '小院简陋，亲族稀少，生活颇为拮据。';
      parentRealm = '凡人父母，体弱多病';
    }

    final luckDesc = state.luck >= 60
        ? '天生福泽，气运隐隐加身'
        : state.luck >= 30
            ? '气运平平，需自求机缘'
            : '气运欠佳，需步步谨慎';

    String familyInfo = '';
    if (state.familyTemplateId != null) {
      try {
        final tpl = _refRepo.families.firstWhere((f) => f.id == state.familyTemplateId);
        familyInfo = '【家族】${tpl.name}（${tpl.tier}）\n';
      } catch (_) {
        familyInfo = '【家族】隐世家族（未知品阶）\n';
      }
    }

    final desc =
        '【身世】你降生在$regionName。\n'
        '$familyInfo'
        '【背景】$flavorText\n'
        '【双亲】${parentRoles.father}与${parentRoles.mother}。$parentRealm，庇护你度过最初岁月。\n'
        '【天赋】$luckDesc。\n'
        '【初始】力${state.strength}/智${state.intelligence}/魅${state.charm}/运${state.luck}/家${state.family}。';

    return LifeEventEntry(
      id: 'birth_intro',
      age: 0,
      title: '出生背景',
      description: desc,
    );
  }

  void _startGame() {
    final seed = DateTime.now().millisecondsSinceEpoch;
    final fs = (family * 5).clamp(0, 100);
    final world = fs >= 90 ? World.immortal : World.mortal;
    final region = fs >= 90
        ? Region.xian
        : fs >= 70
            ? Region.ling
            : Region.ren;
    // pick family template
    final template = _pickFamilyTemplateForUi(family);
    final state = PlayerState.newGame(
      name: _nameController.text.isEmpty ? '无名氏' : _nameController.text,
      strength: strength,
      intelligence: intelligence,
      charm: charm,
      luck: luck,
      family: family,
      seed: seed,
      world: world,
      region: region,
    );
    state.familyTemplateId = template.id;
    state.currentMapId = _refRepo.defaultMapFor(state.world).id;
    // 强制排程 6 岁灵根检测，确保不会错过觉醒窗口
    state.pendingEvents.add('age_6_root_test');
    state.ap = state.apPerYear;
    state.lifeEvents.add(_buildBirthIntro(state));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AdventurePage(initialState: state),
      ),
    );
  }

  // simple deterministic pick based on family to ensure reproducible
  FamilyTemplate _pickFamilyTemplateForUi(int familyScore) {
    debugPrint('[AttributeSetup] Picking family with raw score: $familyScore');
    final t = _pickFamilyTemplate(familyScore);
    debugPrint('[AttributeSetup] Chosen family: ${t.name} (${t.tier})');
    return t;
  }

  void _loadLast() async {
    final stored = await StorageService().load();
    if (!mounted) return;
    if (stored == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('无存档')));
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AdventurePage(initialState: stored)),
    );
  }

  Widget _slider(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label：$value'),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 20,
          divisions: 20,
          label: '$value',
          onChanged: (v) {
            if (v.round() - value > remain) return;
            onChanged(v.round());
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final canStart = remain == 0;
    return Scaffold(
      appBar: AppBar(title: const Text('属性分配')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '姓名'),
            ),
            const SizedBox(height: 12),
            _slider('力量', strength, (v) => setState(() => strength = v)),
            _slider('智力', intelligence, (v) => setState(() => intelligence = v)),
            _slider('魅力', charm, (v) => setState(() => charm = v)),
            _slider('幸运', luck, (v) => setState(() => luck = v)),
            _slider('家境', family, (v) => setState(() => family = v)),
            Text('剩余点数：$remain'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (canStart && _isInitialized) ? _startGame : null,
              child: _isInitialized ? const Text('开始人生') : const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loadLast,
              child: const Text('继续上次人生'),
            ),
          ],
        ),
      ),
    );
  }
}
