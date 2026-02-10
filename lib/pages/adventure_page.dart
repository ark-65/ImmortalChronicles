import 'dart:math';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/event_engine.dart';
import '../services/storage_service.dart';
import 'attribute_setup_page.dart';
import '../widgets/detail_sheet.dart';

class AdventurePage extends StatefulWidget {
  final PlayerState initialState;
  const AdventurePage({super.key, required this.initialState});

  @override
  State<AdventurePage> createState() => _AdventurePageState();
}

class _AdventurePageState extends State<AdventurePage> {
  late PlayerState state;
  late EventEngine engine;
  LifeEventConfig? lastEvent;
  LifeEventConfig? pendingChoiceEvent;
  List<LifeEventConfig>? eventOptions;
  bool autoSaving = false;
  final expGainPerEvent = 15;
  final expGainPerChoice = 10;

  void _tryBreakthrough() async {
    if (!state.canCultivate) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('你选择了凡人之路，无法再进行修炼突破')));
      return;
    }
    if (state.exp < state.expRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('经验不足，无法突破')),
      );
      return;
    }
    // 扣 1 AP
    if (state.ap <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AP 不足，先跳到下一岁')),
      );
      return;
    }
    if (state.ap <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('AP 不足，先跳到下一岁')));
      return;
    }
    state.ap -= 1;
    final successRate =
        (0.4 + state.intelligence / 100 + state.luck / 100).clamp(0.1, 0.9);
    final roll = Random().nextDouble();
    bool success = roll < successRate;
    String desc;
    if (success) {
      final overflow = state.exp - state.expRequired;
      state.expRequired = (state.expRequired * 1.2).round();
      state.exp = overflow;
      state.breakthroughFailStreak = 0;
      // 进阶境界
      final idx = realmSequence.indexOf(state.realm);
      if (idx >= 0 && idx < realmSequence.length - 1) {
        state.realm = realmSequence[idx + 1];
      }
      desc =
          '突破成功！进入${state.realm}，成功率 ${(successRate * 100).toStringAsFixed(1)}%';
    } else {
      final penalty = (state.expRequired * 0.1).round();
      state.exp = (state.exp - penalty).clamp(0, state.expRequired);
      state.breakthroughFailStreak += 1;
      desc = '突破失败，损失$penalty 经验，连续失败 ${state.breakthroughFailStreak} 次。';
      if (state.breakthroughFailStreak % 3 == 0) {
        // 心魔试炼
        final demonRate = (state.luck / 100).clamp(0.05, 0.8);
        if (Random().nextDouble() < demonRate) {
          // 成功
          state.exp += (state.expRequired * 0.2).round();
          desc += ' 心魔试炼成功，额外获得悟性，经验+20%。';
        } else {
          final dPenalty = (state.expRequired * 0.2).round();
          state.exp = (state.exp - dPenalty).clamp(0, state.expRequired);
          desc += ' 心魔反噬，经验再扣 $dPenalty。';
        }
      }
    }
    final ev = LifeEventEntry(
      id: 'breakthrough',
      age: state.age,
      title: '闭关突破',
      description: desc,
    );
    state.lifeEvents.add(ev);
    lastEvent = LifeEventConfig(
      id: ev.id,
      title: ev.title,
      description: ev.description,
      worlds: [state.world],
    );
    await _persist();
    if (!mounted) return;
    setState(() {});
  }

  void _upgradeTechnique(Technique tech) {
    if (state.exp <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('经验不足，无法提升功法')));
      return;
    }
    // 经验溢出允许：扣角色经验，累加功法经验
    state.exp -= 10;
    tech.exp += 10;
    if (tech.exp >= tech.expRequired) {
      tech.exp -= tech.expRequired;
      // 升级熟练度
      final nextStage = ProficiencyStage.values.indexOf(tech.stage) + 1;
      if (nextStage < ProficiencyStage.values.length) {
        tech.stage = ProficiencyStage.values[nextStage];
        tech.expRequired = (tech.expRequired * 1.5).round();
      } else {
        tech.exp = tech.expRequired; // 封顶
      }
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('已消耗10经验提升 ${tech.name} 熟练度')));
    setState(() {});
  }

  void _doCultivate() async {
    if (!state.canCultivate) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('你已选择凡人道路，无法继续修炼')));
      return;
    }
    if (!state.alive || state.ending != null) return;
    if (pendingChoiceEvent != null) return;
    if (state.ap <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('AP 不足，先跳到下一岁')));
      return;
    }
    state.ap -= 1;
    state.exp += expGainPerEvent;
    final ev = LifeEventEntry(
      id: 'cultivate',
      age: state.age,
      title: '闭关修炼',
      description: '你专注修炼一段时间，收获经验 +$expGainPerEvent。',
    );
    state.lifeEvents.add(ev);
    lastEvent = LifeEventConfig(
      id: ev.id,
      title: ev.title,
      description: ev.description,
      worlds: [state.world],
    );
    await _persist();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    state = widget.initialState;
    engine = EventEngine(state.seed);
    if (state.lifeEvents.isNotEmpty) {
      lastEvent = LifeEventConfig(
        id: state.lifeEvents.last.id,
        title: state.lifeEvents.last.title,
        description: state.lifeEvents.last.description,
        worlds: [state.world],
        effects: const {},
      );
    }
  }

  Future<void> _persist() async {
    setState(() => autoSaving = true);
    await StorageService().save(state);
    setState(() => autoSaving = false);
  }

  void _newLife() async {
    await StorageService().clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AttributeSetupPage()),
      (route) => false,
    );
  }

  void _advance({bool forceNextYear = false}) async {
    if (!state.alive) return;
    if (state.ending != null) return;
    if (forceNextYear) {
      pendingChoiceEvent = null;
      eventOptions = null;
    }

    // Manual year skip
    bool skipAgeInEvent = false;
    if (forceNextYear) {
      state.age += 1;
      state.ap = state.apPerYear;
      final report = LifeEventEntry(
        id: 'year_report_${state.age}',
        age: state.age,
        title: '年报',
        description: '这一年平平无奇地过去了，除了日常外没有额外收获。',
      );
      state.lifeEvents.add(report);
      lastEvent = LifeEventConfig(
        id: report.id,
        title: report.title,
        description: report.description,
        worlds: [state.world],
      );
      skipAgeInEvent = true;
    }

    final options = await engine.pickOptions(state, count: 3);
    
    if (options.length > 1) {
      // Show options for user to pick
      setState(() {
        eventOptions = options;
        lastEvent = null;
        pendingChoiceEvent = null;
      });
    } else {
      // Single mandatory/story event
      final event = options.first;
      eventOptions = null;
      if (event.choices.isNotEmpty) {
        pendingChoiceEvent = event;
        lastEvent = event;
      } else {
        engine.applyEffects(
          state,
          event,
          consumeAp: !forceNextYear,
          extraEffects: {
            'delta': {'exp': expGainPerEvent},
            if (skipAgeInEvent) 'age': 0,
          },
        );
        final latest = state.lifeEvents.isNotEmpty ? state.lifeEvents.last : null;
        lastEvent = LifeEventConfig(
          id: event.id,
          title: event.title,
          description: latest?.description ?? event.description,
          worlds: event.worlds,
        );
      }
    }

    await _persist();
    if (!mounted) return;
    setState(() {});
  }

  void _selectEventOption(LifeEventConfig event) async {
    if (event.choices.isNotEmpty) {
      setState(() {
        eventOptions = null;
        pendingChoiceEvent = event;
        lastEvent = event;
      });
      return;
    }

    engine.applyEffects(
      state,
      event,
      consumeAp: true,
      extraEffects: {'delta': {'exp': expGainPerEvent}},
    );
    final latest = state.lifeEvents.isNotEmpty ? state.lifeEvents.last : null;
    setState(() {
      eventOptions = null;
      lastEvent = LifeEventConfig(
        id: event.id,
        title: event.title,
        description: latest?.description ?? event.description,
        worlds: event.worlds,
      );
    });
    await _persist();
  }

  void _pickChoice(LifeEventChoice choice) async {
    if (pendingChoiceEvent == null) return;
    final event = pendingChoiceEvent!;
    engine.applyEffects(state, event,
        extraEffects: {
          ...choice.effects,
          'delta': {
            ...?choice.effects['delta'],
            'exp': (choice.effects['delta']?['exp'] ?? 0) + expGainPerChoice
          }
        },
        consumeAp: true);
    final latest = state.lifeEvents.isNotEmpty ? state.lifeEvents.last : null;
    pendingChoiceEvent = null;
    lastEvent = LifeEventConfig(
      id: event.id,
      title: event.title,
      description: latest?.description ?? event.description,
      worlds: event.worlds,
    );
    await _persist();
    if (!mounted) return;
    setState(() {});
  }

  void _showLog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.lifeEvents.length,
        itemBuilder: (_, i) {
          final e = state.lifeEvents[state.lifeEvents.length - 1 - i];
          return ListTile(
            dense: true,
            title: Text('${e.age}岁：${e.title}'),
            subtitle: Text(e.description),
          );
        },
      ),
    );
  }

  Widget _buildAttr(String label, int value, Color color) {
    return Chip(
      backgroundColor: color.withValues(alpha: 0.15),
      label: Text('$label $value', style: TextStyle(color: color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attrs = Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildAttr('力', state.strength, Colors.red),
        _buildAttr('智', state.intelligence, Colors.blue),
        _buildAttr('魅', state.charm, Colors.purple),
        _buildAttr('运', state.luck, Colors.orange),
        _buildAttr('家', state.family, Colors.teal),
        Chip(
          label: Text('AP/年 ${state.apPerYear}'),
          avatar: const Icon(Icons.flash_on, size: 18),
        ),
        Chip(
          label: Text('境界 ${state.realm}'),
          avatar: const Icon(Icons.stacked_line_chart, size: 18),
        ),
        Chip(
          label: Text('灵根 ${state.talentLevelName}'),
          avatar: const Icon(Icons.flare, size: 18),
        ),
        Chip(
          label: Text('经验 ${state.exp}'),
          avatar: const Icon(Icons.star, size: 18),
        ),
        Chip(
          label: Text('升级需 ${state.expRequired}'),
          avatar: const Icon(Icons.upgrade, size: 18),
        ),
        Chip(
          label: Text('寿元上限 ${state.maxLifespan}'),
          avatar: const Icon(Icons.hourglass_bottom, size: 18),
        ),
      ],
    );

    String worldLabel = switch (state.world) {
      World.immortal => '仙界',
      World.nether => '魔界',
      World.mortal => '人界',
    };
    String regionLabel = switch (state.region) {
      Region.xian => '仙域',
      Region.sheng => '圣域',
      Region.shen => '神域',
      Region.ling => '灵域',
      Region.mo => '魔域',
      Region.ren => '人域',
    };

    final status = Text(
      '${state.name}｜$worldLabel/$regionLabel｜${state.age}岁｜AP ${state.ap}',
      style: Theme.of(context).textTheme.titleMedium,
    );

    final canBreakthrough = state.canCultivate &&
        state.alive &&
        state.ending == null &&
        state.exp >= state.expRequired &&
        state.realm != '无';
    final canCultivateNow = state.canCultivate &&
        state.alive &&
        state.ending == null &&
        state.realm != '无';

    final bodyCard = eventOptions != null
        ? Column(
            children: eventOptions!
                .map((e) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => _selectEventOption(e),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.title, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 4),
                                    Text(e.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          )
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lastEvent?.title ?? '等待启程', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(lastEvent?.description ?? '点击继续前行开始你的历程。'),
                  if (pendingChoiceEvent != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: pendingChoiceEvent!.choices
                          .map(
                            (c) => ElevatedButton(
                              onPressed: () => _pickChoice(c),
                              child: Text(c.label),
                            ),
                          )
                          .toList(),
                    ),
    return Scaffold(
      appBar: AppBar(
        title: const Text('冒险'),
        actions: [
          IconButton(
            tooltip: '详细属性',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => FractionallySizedBox(
                  heightFactor: 0.8,
                  child: DetailSheet(
                    state: state,
                    onUpgradeTechnique: _upgradeTechnique,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            onPressed: _showLog,
            icon: const Icon(Icons.article_outlined),
            tooltip: '日志',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            status,
            const SizedBox(height: 8),
            attrs,
            const SizedBox(height: 12),
            Expanded(child: SingleChildScrollView(child: bodyCard)), // Wrapped in scroll view to avoid overflow
            if (autoSaving) const Text('保存中...'),
            if (state.ending != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('结局：${state.ending}'),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column( // Use column for tighter layout if needed, or just Row
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: ended || state.ap <= 0
                          ? (ended ? _newLife : null)
                          : (pendingChoiceEvent == null && eventOptions == null ? _advance : null),
                      child: Text(ended ? '重开' : '历练'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!ended) ...[
                     Expanded(
                      child: ElevatedButton( // Cultivate/Breakthrough Button
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canBreakthrough ? Colors.amber.shade700 : (canCultivateNow && state.techniques.isNotEmpty ? Colors.blue.shade700 : Colors.grey),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: pendingChoiceEvent == null && state.techniques.isNotEmpty && canCultivateNow
                            ? (canBreakthrough ? _tryBreakthrough : _doCultivate)
                            : null,
                        child: Text(canBreakthrough ? '突破' : '修炼'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          ended ? _showLog : () => _advance(forceNextYear: true),
                      child: Text(ended ? '回顾' : '长一岁'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
