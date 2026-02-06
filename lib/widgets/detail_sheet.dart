import 'package:flutter/material.dart';

import '../models/models.dart';

class DetailSheet extends StatelessWidget {
  final PlayerState state;
  final void Function(Technique technique)? onUpgradeTechnique;
  const DetailSheet({super.key, required this.state, this.onUpgradeTechnique});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('基础', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('境界 ${state.realm}')),
                Chip(label: Text('灵根 ${state.talentLevelName}')),
                Chip(label: Text('经验 ${state.exp}/${state.expRequired}')),
                Chip(label: Text('寿元上限 ${state.maxLifespan}')),
              ],
            ),
            const SizedBox(height: 12),
            Text('功法与熟练度', style: Theme.of(context).textTheme.titleMedium),
            ...state.techniques.map((t) => ListTile(
                  dense: true,
                  title: Text('${t.name}（${t.gradeLabel}）'),
                  subtitle:
                      Text('${t.stageLabel}｜${t.exp}/${t.expRequired} 经验'),
                  trailing: onUpgradeTechnique == null
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: '消耗角色经验提升熟练度',
                          onPressed: () => onUpgradeTechnique!(t),
                        ),
                )),
            const SizedBox(height: 12),
            Text('天赋/体质', style: Theme.of(context).textTheme.titleMedium),
            ...state.specialTalents.map(
              (s) => ListTile(
                dense: true,
                title: Text(s.name),
                subtitle: Text(s.description),
              ),
            ),
            const SizedBox(height: 12),
            Text('法宝（占位）', style: Theme.of(context).textTheme.titleMedium),
            const Text('暂未获得法宝，可在奇遇/宗门奖励中获取。'),
          ],
        ),
      ),
    );
  }
}
