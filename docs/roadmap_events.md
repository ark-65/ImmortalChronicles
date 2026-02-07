# 事件分表与机缘刷新规划（草案）

## 分表切分建议
- age_0_3.yaml：0-3 岁婴幼儿（牙牙学语、吃奶睡觉、学步）。
- age_4_6.yaml：4-6 岁童年（好奇、玩耍、启蒙识字、家族启蒙）。
- age_7_12.yaml：7-12 岁少年（族学、比武、集市见闻、灵根检测）。
- age_13_18.yaml：13-18 岁青少年（试炼、入宗、初期修炼）。
- mortal_daily.yaml：凡界日常修炼/奇遇基线事件（可根据境界分段）。
- sect_chance.yaml：宗门机缘（秘境、长老试炼、师门任务）。
- clan_chance.yaml：家族机缘（长老发现洞府、资源倾斜、族比）。
- immortal_daily.yaml：仙界日常/奇遇（闭关、游历、渡劫前兆）。
- nether_daily.yaml：魔界生存事件。

## 抽取逻辑（拟实现）
1. 根据年龄段/世界/境界动态选择表；默认日常表 + 若干概率机缘表。
2. 每个表的事件带 `chance`，支持 `chanceLuckBoost`（已在 EventEngine 增加 luck 加成）。
3. 机缘刷新频率：基础刷新=每岁，机缘表条目权重 = `baseChance + luck * k`，气运越高机缘越多。
4. 兜底：各 world 维持 fallback 事件；若当前表无可用事件则回退到对应日常表。

## 下一步实施顺序
- [ ] 拆分 sample_events.dart 为 age_0_3 等分表（YAML/JSON）。
- [ ] 在构建时合并分表为 `sampleEvents`，或运行时懒加载（需工具）。
- [ ] 补充家族/宗门机缘示例：
      - “族中长老发现洞府”事件，包含谨慎/探索分支，奖励灵材/受伤/名声变化。
      - “宗门外门考核”、“师兄姐指导”、“护道者任务”等。
- [ ] 按境界分层日常修炼表，避免高龄仍刷低阶事件。

## 现状依赖
- `EventEngine.conditions.chanceLuckBoost` 已支持按 luck 提升概率。
- 需要新增表与装载逻辑后，可删除大体量的 sample_events.dart。

