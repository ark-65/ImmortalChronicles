class WeaponType {
  final String name;
  final String description;
  final List<String> examples;

  const WeaponType({
    required this.name,
    required this.description,
    this.examples = const [],
  });

  factory WeaponType.fromJson(Map<String, dynamic> json) => WeaponType(
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        examples: List<String>.from(json['examples'] ?? const []),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'examples': examples,
      };
}

/// 常见武器大类（中式修真向）
const weaponTypesFallback = <WeaponType>[
  WeaponType(
    name: '刀',
    description: '单刃劈砍武器，爆发力强，适合贴身与破甲。',
    examples: ['柳叶刀', '环首刀', '朴刀', '苗刀'],
  ),
  WeaponType(
    name: '剑',
    description: '双刃刺击/劈砍平衡，讲究剑意与身法。',
    examples: ['长剑', '青锋剑', '重剑'],
  ),
  WeaponType(
    name: '枪',
    description: '长柄刺击，“百兵之王”，攻守兼备，适合远点控制。',
    examples: ['红缨枪', '方天画戟式枪', '龙吟枪'],
  ),
  WeaponType(
    name: '棍',
    description: '无刃长杆打击，圆融不伤刃，适合基础与群战。',
    examples: ['齐眉棍', '少林禅杖', '哨棒'],
  ),
  WeaponType(
    name: '棒',
    description: '较棍更重，常带棱或刺，偏重破甲与震荡。',
    examples: ['狼牙棒', '流星棒'],
  ),
  WeaponType(
    name: '斧',
    description: '重型劈砍，适合开山破阵，但耗力大。',
    examples: ['短柄斧', '长柄开山斧'],
  ),
  WeaponType(
    name: '钺',
    description: '宽刃礼兵或重器，威仪与杀伤并存。',
    examples: ['青铜钺', '巨刃钺'],
  ),
  WeaponType(
    name: '钩',
    description: '前端弯曲可勾拿卸力，擒拿与破绽制造。',
    examples: ['虎头钩', '护手钩'],
  ),
  WeaponType(
    name: '叉',
    description: '多尖刺击，长柄控制，多用于水战或围猎。',
    examples: ['鱼叉', '牛角叉'],
  ),
  WeaponType(
    name: '镗',
    description: '长柄多尖的复合兵，兼具拍、刺、挑。',
    examples: ['凤翅镗', '雁翅镗'],
  ),
  WeaponType(
    name: '槊',
    description: '重型长矛，矛头修长，常见于骑战。',
    examples: ['马槊'],
  ),
  WeaponType(
    name: '鞭',
    description: '硬鞭多节铁质，软鞭可卷绕，讲究节奏与手腕。',
    examples: ['铁节鞭', '九节鞭'],
  ),
  WeaponType(
    name: '锏',
    description: '无刃棱状短兵，震骨碎筋，常为近身护身兵。',
    examples: ['四棱锏'],
  ),
  WeaponType(
    name: '锤',
    description: '重击破甲，惯性大，需巨力掌控。',
    examples: ['金瓜锤', '流星锤'],
  ),
  WeaponType(
    name: '抓',
    description: '飞爪软索，远距勾取/擒拿或攀爬奇袭。',
    examples: ['金龙爪', '飞天爪'],
  ),
  WeaponType(
    name: '拐',
    description: '短棍侧带横柄，可钩可挡，灵活制敌。',
    examples: ['丁字拐', '铁拐'],
  ),
  WeaponType(
    name: '流星',
    description: '软索系重物，借离心力抽击，兼具暗器特性。',
    examples: ['流星锤', '流星镖'],
  ),
  WeaponType(
    name: '戟',
    description: '矛戈结合，可刺可勾，阵战/破阵常用。',
    examples: ['青龙偃月戟', '方天画戟'],
  ),
  WeaponType(
    name: '戈',
    description: '横刃钩杀，古战阵主流，可挑可绞。',
    examples: ['青铜戈'],
  ),
  WeaponType(
    name: '弓弩',
    description: '远程射击，机缘事件可触发“百步穿杨”或陷阱解法。',
    examples: ['强弓', '连发弩'],
  ),
];
