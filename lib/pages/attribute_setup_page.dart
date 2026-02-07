import 'package:flutter/material.dart';
import 'dart:math';

import '../models/models.dart';
import '../services/storage_service.dart';
import 'adventure_page.dart';
import '../data/family_templates.dart';
import '../data/parent_roles.dart';

FamilyTemplate _pickFamilyTemplate(int familyScore) {
  final score = (familyScore * 5).clamp(0, 100);
  final rng = Random();

  List<FamilyTemplate> byTier(String tier) =>
      familyTemplates.where((f) => f.tier == tier).toList();

  if (score == 100) {
    final pool = rng.nextDouble() < 0.3 ? byTier('霸主') : byTier('圣地');
    if (pool.isNotEmpty) return pool[rng.nextInt(pool.length)];
  }
  if (score >= 95) {
    final pool = rng.nextDouble() < 0.2 ? byTier('霸主') : byTier('圣地');
    if (pool.isNotEmpty) return pool[rng.nextInt(pool.length)];
  }
  if (score >= 90) {
    final pool = byTier('圣地');
    if (pool.isNotEmpty) return pool[rng.nextInt(pool.length)];
  }
  if (score >= 70) {
    final pool = byTier('天');
    if (pool.isNotEmpty) return pool[rng.nextInt(pool.length)];
  }
  if (score >= 50) {
    final pool = byTier('地');
    if (pool.isNotEmpty) return pool[rng.nextInt(pool.length)];
  }
  if (score >= 30) {
    final pool = byTier('人');
    if (pool.isNotEmpty) return pool[rng.nextInt(pool.length)];
  }
  final mundanePool = familyTemplates
      .where((f) =>
          ['一品', '二品', '三品', '四品', '五品', '六品', '七品', '八品', '九品']
              .contains(f.tier))
      .toList();
  if (mundanePool.isNotEmpty) return mundanePool[rng.nextInt(mundanePool.length)];
  return familyTemplates.first;
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
  static const totalPoints = 30;

  int get used => strength + intelligence + charm + luck + family;
  int get remain => totalPoints - used;

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
    final parentRoles = pickParentRoles(familyScore: fs, luck: state.luck);
    String familyTier;
    String parentRealm;
    String clanSize;
    if (fs >= 90) {
      familyTier = '顶级仙族';
      parentRealm = '真仙境长老';
      clanSize = '坐拥数十座仙山，供奉护道者与执法堂';
    } else if (fs >= 70) {
      familyTier = '灵界修真世家';
      parentRealm = '合体期父亲与炼虚期母亲';
      clanSize = '族人逾千，设有功法阁与试炼场';
    } else if (fs >= 50) {
      familyTier = '灵界普通家族';
      parentRealm = '元婴期父母';
      clanSize = '族人数百，偶有外门客卿坐镇';
    } else if (fs >= 30) {
      familyTier = '人界富庶人家';
      parentRealm = '练气高层的父母';
      clanSize = '城中有产业与护院，但缺少修真底蕴';
    } else if (fs >= 10) {
      familyTier = '人界普通家庭';
      parentRealm = '凡人父母';
      clanSize = '三代同堂，靠勤勉度日';
    } else {
      familyTier = '人界贫寒之家';
      parentRealm = '凡人父母，体弱多病';
      clanSize = '小院简陋，亲族稀少';
    }

    final luckDesc = state.luck >= 60
        ? '天生福泽，气运隐隐加身'
        : state.luck >= 30
            ? '气运平平，需自求机缘'
            : '气运欠佳，需步步谨慎';

    final talentHint =
        '当前五维：力${state.strength}/智${state.intelligence}/魅${state.charm}/运${state.luck}/家${state.family}';

    String? familyName;
    if (state.familyTemplateId != null) {
      final tpl = familyTemplates.firstWhere(
        (f) => f.id == state.familyTemplateId,
        orElse: () => familyTemplates.first,
      );
      familyName = tpl.name;
    }

    final clanInfo = familyName != null
        ? '家族传承：$familyName'
        : '家族底蕴尚未显露';

    final desc =
        '你降生在$regionName 的 $familyTier。家族疆域$clanSize，父母为$parentRealm，庇护你度过最初岁月。'
        '父亲是${parentRoles.father}，母亲是${parentRoles.mother}。'
        '出身决定了你的起跑线，但未来仍要靠自己积累。$luckDesc。$talentHint。$clanInfo。';

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
  FamilyTemplate _pickFamilyTemplateForUi(int familyScore) =>
      _pickFamilyTemplate(familyScore);

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
              onPressed: canStart ? _startGame : null,
              child: const Text('开始人生'),
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
