import '../models/medicine.dart';

const medicineListFallback = <Medicine>[
  Medicine(
    id: 'fan_recovery_pill',
    name: '回元散',
    grade: '凡',
    effect: '小幅恢复气血，适合凡修与低阶修士日常疗伤。',
    bonuses: {'hp': 20},
    rarity: 1,
  ),
  Medicine(
    id: 'ling_qi_pill',
    name: '聚灵丹',
    grade: '灵',
    effect: '提升灵气恢复并短暂提升悟性。',
    bonuses: {'exp': 30, 'intelligence': 1},
    rarity: 3,
  ),
  Medicine(
    id: 'xian_body_pill',
    name: '洗髓丹',
    grade: '仙',
    effect: '淬炼根骨，提升基础体质，辅助突破筑基/金丹。',
    bonuses: {'strength': 2, 'charm': 1},
    rarity: 5,
  ),
  Medicine(
    id: 'sheng_life_extension',
    name: '长生玉露',
    grade: '圣',
    effect: '延寿 50 年并稳固神魂，极为罕见。',
    bonuses: {'lifespan': 50},
    rarity: 8,
  ),
  Medicine(
    id: 'dao_pill',
    name: '混元道果',
    grade: '道',
    effect: '顿悟大道气息，突破失败可保底重试一次。',
    bonuses: {'exp': 200, 'luck': 3},
    rarity: 10,
  ),
];
