import '../models/models.dart';

const sampleEvents = <LifeEventConfig>[
  LifeEventConfig(
    id: 'm_child_study',
    title: '童年学习',
    description: '你努力认字与算术。',
    worlds: [World.mortal],
    minAge: 6,
    maxAge: 12,
    conditions: {'chance': 0.7},
    effects: {
      'delta': {'intelligence': 2},
      'unlockLiteracy': true,
    },
    choices: [
      LifeEventChoice(
          id: 'recite',
          label: '背诵经文',
          effects: {'delta': {'intelligence': 2}}),
      LifeEventChoice(
          id: 'question',
          label: '向师长发问',
          effects: {'delta': {'intelligence': 1, 'charm': 1}}),
      LifeEventChoice(
          id: 'skip',
          label: '偷懒摸鱼',
          effects: {'delta': {'luck': 1, 'intelligence': -1}}),
    ],
    weight: 3,
  ),
  LifeEventConfig(
    id: 'age_1_sounds',
    title: '牙牙学语',
    description: '你发出稚嫩的声音。',
    worlds: [World.mortal, World.immortal, World.nether],
    minAge: 0,
    maxAge: 1,
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
          id: 'ying',
          label: '嘤嘤嘤',
          effects: {
            'delta': {'charm': 1},
            'log': '你的软萌哭声让屋里的人心都化了。'
          }),
      LifeEventChoice(
          id: 'wow',
          label: '哇哇哇',
          effects: {
            'delta': {'family': 1},
            'log': '娘听到哭声赶来喂食，顺手把你裹得暖暖的。'
          }),
      LifeEventChoice(
          id: 'haha',
          label: '哈哈哈',
          effects: {
            'delta': {'luck': 1},
            'log': '开朗的笑声回荡，窗外一缕阳光正好洒在你身上。'
          }),
    ],
    weight: 5,
  ),
  LifeEventConfig(
    id: 'age_2_report',
    title: '吃奶睡觉的一年',
    description: '除了吃奶就是睡觉。',
    worlds: [World.mortal, World.immortal, World.nether],
    minAge: 2,
    maxAge: 2,
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'eat',
        label: '安心吃奶',
        effects: {
          'delta': {'family': 1},
          'log': '你吃得饱饱，家人放心继续照看你。'
        },
      ),
      LifeEventChoice(
        id: 'sleep',
        label: '继续睡觉',
        effects: {
          'delta': {'luck': 1},
          'log': '你睡得香甜，似乎做了个好梦。'
        },
      ),
      LifeEventChoice(
        id: 'cry',
        label: '随意哭闹',
        effects: {
          'delta': {'charm': -1, 'strength': 1},
          'log': '你哭得声音洪亮，练了气息，但惹得婴儿房鸡飞狗跳。'
        },
      ),
    ],
    weight: 5,
  ),
  LifeEventConfig(
    id: 'age_3_play',
    title: '蹒跚学步',
    description: '你开始能在庭院里乱跑。',
    worlds: [World.mortal, World.immortal, World.nether],
    minAge: 3,
    maxAge: 3,
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'run',
        label: '到处奔跑',
        effects: {
          'delta': {'strength': 1},
          'log': '你在院子里跑得满头大汗，腿脚更稳了。'
        },
      ),
      LifeEventChoice(
        id: 'observe',
        label: '观察自然',
        effects: {
          'delta': {'intelligence': 1},
          'log': '你蹲在地上看蚂蚁搬家，开始思考它们的世界。'
        },
      ),
      LifeEventChoice(
        id: 'hide',
        label: '躲在母亲身后',
        effects: {
          'delta': {'charm': 1},
          'log': '你紧紧抱着母亲的衣角，露出乖巧的笑。'
        },
      ),
    ],
    weight: 4,
  ),
  LifeEventConfig(
    id: 'age_4_curiosity',
    title: '好奇心萌芽',
    description: '你开始对外面的世界产生疑问。',
    worlds: [World.mortal, World.immortal, World.nether],
    minAge: 4,
    maxAge: 4,
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'ask_story',
        label: '缠着长辈讲故事',
        effects: {
          'delta': {'intelligence': 1},
          'log': '长辈向你讲述三界：神界定规则、圣界护法则、仙界为飞升目标；魔界暗涌，灵界繁盛，人界卑微。'
        },
      ),
      LifeEventChoice(
        id: 'find_bug',
        label: '抓虫子玩',
        effects: {
          'delta': {'luck': 1},
          'log': '你在草丛里找到会发光的甲虫，似乎带着微弱灵气。'
        },
      ),
      LifeEventChoice(
        id: 'help_house',
        label: '帮忙做事',
        effects: {
          'delta': {'family': 1},
          'log': '你学着搬水、扫地，长辈对你多了几分赞许。'
        },
      ),
    ],
    weight: 4,
  ),
  LifeEventConfig(
    id: 'family_training_5',
    title: '家族启蒙',
    description: '家族长老决定开始教你修炼。',
    worlds: [World.mortal, World.immortal],
    minAge: 5,
    maxAge: 8,
    conditions: {'chance': 0.8},
    prerequisites: ['root_awakened', 'cultivation_started'],
    effects: {
      'delta': {'intelligence': 1}
    },
    choices: [
      LifeEventChoice(
        id: 'family_skill',
        label: '修习家族功法',
        effects: {
          'delta': {'intelligence': 1, 'strength': 1}
        },
      ),
      LifeEventChoice(
        id: 'family_sword',
        label: '修习家族剑道',
        effects: {
          'delta': {'strength': 2}
        },
      ),
      LifeEventChoice(
        id: 'play',
        label: '继续玩耍',
        effects: {
          'delta': {'charm': 1},
        },
      ),
    ],
  ),
  LifeEventConfig(
    id: 'age_6_root_test',
    title: '灵根检测',
    description: '你被带到灵根台，光柱缓缓升起。',
    worlds: [World.mortal, World.immortal],
    minAge: 6,
    maxAge: 6,
    conditions: {'unique': true},
    effects: {
      'age': 0,
      'unlockLiteracy': true,
      'talentLevelName': '已觉醒',
      'realm': '炼气',
      'log': '体内灵根被激活，修炼之路由此开启。'
    },
    choices: [
      LifeEventChoice(
        id: 'high_profile',
        label: '高调入场',
        effects: {
          'delta': {'charm': 1},
          'log': '你昂首迈上法阵，众目睽睽。',
        },
      ),
      LifeEventChoice(
        id: 'normal',
        label: '普通入场',
        effects: {'log': '你安静排队等待检测。'},
      ),
      LifeEventChoice(
        id: 'low_profile',
        label: '低调入场',
        effects: {
          'delta': {'luck': 1},
          'log': '你选择在人后悄然测试，未引起注意。'
        },
      ),
    ],
    weight: 6,
  ),
  LifeEventConfig(
    id: 'age_7_study_clan',
    title: '族学读书',
    description: '你开始识字抄经，了解家族史。',
    worlds: [World.mortal, World.immortal],
    minAge: 7,
    maxAge: 7,
    effects: {'age': 0, 'unlockLiteracy': true},
    choices: [
      LifeEventChoice(
        id: 'history',
        label: '研读族史',
        effects: {
          'delta': {'intelligence': 1},
          'log': '你知道了祖上曾在仙界立过战功。'
        },
      ),
      LifeEventChoice(
        id: 'copy',
        label: '抄写经卷',
        effects: {
          'delta': {'intelligence': 1, 'charm': 1},
          'log': '你字迹工整，老师满意地点头。'
        },
      ),
      LifeEventChoice(
        id: 'skip',
        label: '偷偷翘课',
        effects: {
          'delta': {'luck': 1, 'intelligence': -1},
          'log': '你躲到后山玩耍，被风吹得神清气爽。'
        },
      ),
    ],
    weight: 5,
  ),
  LifeEventConfig(
    id: 'age_8_spar',
    title: '童子比武',
    description: '族内举行童子场，你也报名参与。',
    worlds: [World.mortal, World.immortal, World.nether],
    minAge: 8,
    maxAge: 8,
    prerequisites: ['cultivation_started'],
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'sword',
        label: '试剑',
        effects: {
          'delta': {'strength': 1},
          'log': '你与同龄人比剑，学到几招实用剑式。'
        },
      ),
      LifeEventChoice(
        id: 'fist',
        label: '赤手搏斗',
        effects: {
          'delta': {'strength': 2, 'charm': -1},
          'log': '你用力过猛把对手打哭，引来长辈皱眉。'
        },
      ),
      LifeEventChoice(
        id: 'observe',
        label: '旁观学习',
        effects: {
          'delta': {'intelligence': 1},
          'log': '你细看套路，记下几处破绽，未来可用。'
        },
      ),
    ],
    weight: 4,
  ),
  LifeEventConfig(
    id: 'age_9_market',
    title: '坊市见闻',
    description: '你随长辈前往坊市，琳琅满目的灵材让你目不暇接。',
    worlds: [World.mortal, World.immortal],
    minAge: 9,
    maxAge: 9,
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'buy_talisman',
        label: '买张护身符',
        effects: {
          'delta': {'luck': 1, 'family': -1},
          'log': '你花了家族的灵石，换来一张简单护符。'
        },
      ),
      LifeEventChoice(
        id: 'haggle',
        label: '练习砍价',
        effects: {
          'delta': {'charm': 1},
          'log': '你与小贩斗嘴，砍掉了三成价格。'
        },
      ),
      LifeEventChoice(
        id: 'learn',
        label: '观察交易',
        effects: {
          'delta': {'intelligence': 1},
          'log': '你记住了几味常用灵药的品相与价格。'
        },
      ),
    ],
    weight: 3,
  ),
  LifeEventConfig(
    id: 'age_10_trial',
    title: '后山小试',
    description: '长辈带你去后山试炼，考验你的胆识与悟性。',
    worlds: [World.mortal, World.immortal, World.nether],
    minAge: 10,
    maxAge: 10,
    prerequisites: ['cultivation_started'],
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'lead',
        label: '带头闯阵',
        effects: {
          'delta': {'strength': 2, 'luck': -1},
          'log': '你冲在前头，吃了点苦头也积累了勇气。'
        },
      ),
      LifeEventChoice(
        id: 'analyze',
        label: '观察机关',
        effects: {
          'delta': {'intelligence': 2},
          'log': '你站在旁边拆解机关原理，长辈暗中点头。'
        },
      ),
      LifeEventChoice(
        id: 'stay_safe',
        label: '谨慎跟随',
        effects: {
          'delta': {'luck': 1, 'charm': 1},
          'log': '你步步小心，既无功也无过。'
        },
      ),
    ],
    weight: 3,
  ),
  LifeEventConfig(
    id: 'age_11_break',
    title: '首次冲击',
    description: '你尝试运转功法，冲击体内关隘。',
    worlds: [World.mortal, World.immortal],
    minAge: 11,
    maxAge: 11,
    prerequisites: ['cultivation_started'],
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'hard_push',
        label: '强行冲关',
        effects: {
          'delta': {'strength': 1},
          'log': '你强推气血，筋脉微痛，但感到一丝松动。'
        },
      ),
      LifeEventChoice(
        id: 'steady',
        label: '稳扎稳打',
        effects: {
          'delta': {'intelligence': 1},
          'log': '你按师长节奏慢慢淬炼，经络更稳固。'
        },
      ),
      LifeEventChoice(
        id: 'giveup',
        label: '决定暂缓',
        effects: {
          'delta': {'luck': 1},
          'log': '你选择等待更好时机，积累更多底蕴。'
        },
      ),
    ],
    weight: 2,
  ),
  LifeEventConfig(
    id: 'age_12_depart',
    title: '外出历练',
    description: '你获得首次独自外出的许可。',
    worlds: [World.mortal, World.immortal],
    minAge: 12,
    maxAge: 12,
    prerequisites: ['cultivation_started'],
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
          id: 'mountain',
          label: '上山采药',
          effects: {
            'delta': {'luck': 1, 'intelligence': 1},
            'log': '你在山林找到几株灵草，小有收获。'
          },
      ),
      LifeEventChoice(
          id: 'town',
          label: '城中历练',
          effects: {
            'delta': {'charm': 1},
            'log': '你在市井与人交涉，嘴皮子变得更利索了。'
          },
      ),
      LifeEventChoice(
          id: 'meditate',
          label: '闭关稳固',
          effects: {
            'delta': {'intelligence': 1, 'family': 1},
            'log': '你选择在家静修，家人支持你的决定。'
          },
      ),
    ],
    weight: 2,
  ),
  LifeEventConfig(
    id: 'clan_secret_realm',
    title: '族中秘境邀约',
    description: '长老发现隐匿洞府，挑选年轻一辈前去探索。',
    worlds: [World.mortal, World.immortal],
    minAge: 16,
    maxAge: 40,
    prerequisites: ['root_awakened'],
    conditions: {'chance': 0.05, 'chanceLuckBoost': 0.1},
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'stay_safe',
        label: '谨慎为妙',
        effects: {
          'delta': {'intelligence': 1, 'exp': 10},
          'log': '你选择留守后方，帮忙记录阵纹，收获些许感悟。'
        },
      ),
      LifeEventChoice(
        id: 'explore',
        label: '前去探索',
        effects: {
          'delta': {'strength': 1, 'luck': 1, 'exp': 30},
          'log': '你随队深入洞府，避开陷阱并取得一块灵矿。'
        },
      ),
    ],
    weight: 2,
  ),
  LifeEventConfig(
    id: 'sect_trial_invite',
    title: '宗门外门试炼',
    description: '师门发出试炼令，要求弟子前往秘地历练。',
    worlds: [World.mortal, World.immortal],
    minAge: 15,
    maxAge: 60,
    prerequisites: ['sect_accepted', 'cultivation_started'],
    conditions: {'chance': 0.08, 'chanceLuckBoost': 0.08},
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'decline',
        label: '申请暂缓',
        effects: {
          'delta': {'charm': -1},
          'log': '你以闭关为由推迟试炼，师兄眼神复杂。'
        },
      ),
      LifeEventChoice(
        id: 'join',
        label: '报名参加',
        effects: {
          'delta': {'exp': 35, 'luck': 1},
          'log': '你与同门协作完成任务，获得了一枚灵符奖励。'
        },
      ),
      LifeEventChoice(
        id: 'solo',
        label: '独自闯荡',
        effects: {
          'delta': {'strength': 1, 'intelligence': 1, 'exp': 45},
          'log': '你独自完成试炼，虽受点伤，但收获巨大。'
        },
      ),
    ],
    weight: 2,
  ),

  // 成年日常（按世界拆分）
  LifeEventConfig(
    id: 'mortal_daily_cultivate',
    title: '日常修炼',
    description: '你在凡界静心打坐，巩固根基。',
    worlds: [World.mortal],
    minAge: 13,
    prerequisites: ['cultivation_started', 'root_awakened'],
    conditions: {'chance': 0.6, 'chanceLuckBoost': 0.05},
    effects: {
      'age': 0,
      'delta': {'exp': 15, 'intelligence': 1}
    },
  ),
  LifeEventConfig(
    id: 'immortal_daily_cultivate',
    title: '仙界吐纳',
    description: '仙气汇聚，你调息运转，法力更稳。',
    worlds: [World.immortal],
    minAge: 13,
    prerequisites: ['cultivation_started', 'root_awakened'],
    conditions: {'chance': 0.7, 'chanceLuckBoost': 0.05},
    effects: {
      'age': 0,
      'delta': {'exp': 15, 'intelligence': 1}
    },
  ),
  LifeEventConfig(
    id: 'nether_daily_survive',
    title: '魔界苟活',
    description: '魔气侵蚀，你谨慎行事以求生。',
    worlds: [World.nether],
    minAge: 13,
    conditions: {'chance': 0.7, 'chanceLuckBoost': 0.05},
    effects: {
      'age': 0,
      'delta': {'strength': 1, 'exp': 10},
      'log': '你压低气息在阴沟穿行，躲过了一头魔兽。'
    },
  ),
  // 普通/世俗家族宗门接引 12 岁（顶级家族不触发）
  LifeEventConfig(
    id: 'mortal_sect_invite_12',
    title: '宗门接引',
    description: '宗门接引使者抵达村庄，挑选可造之材。',
    worlds: [World.mortal],
    minAge: 12,
    maxAge: 12,
    prerequisites: ['non_top_family_only'],
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'attend_test',
        label: '参加灵根测试',
        effects: {
          'log': '你随接引使者前往宗门，准备测试灵根。',
          'pendingEvents': ['sect_root_test_result'],
        },
      ),
      LifeEventChoice(
        id: 'decline',
        label: '婉拒机会',
        effects: {
          'log': '你选择留在家乡，错过了宗门选拔。',
        },
      ),
    ],
    weight: 4,
  ),
  LifeEventConfig(
    id: 'sect_root_test_result',
    title: '宗门灵根检测',
    description: '长老主持灵根石，你的天赋显现。',
    worlds: [World.mortal],
    minAge: 12,
    maxAge: 12,
    prerequisites: ['non_top_family_only'],
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'pass',
        label: '灵根合格',
        effects: {
          'log': '灵光闪耀，你被收为外门弟子。',
          'talentLevelName': '已觉醒',
          'realm': '炼气',
          'sectId': 'generic_sect',
          'pendingEvents': ['join_sect'],
        },
      ),
      LifeEventChoice(
        id: 'fail',
        label: '灵根不足',
        effects: {
          'log': '灵光黯淡，你被遣返家乡，此生难再觉醒灵根，只能走炼体之路。',
          'talentLevelName': '凡体',
          'pendingEvents': ['mortal_fallback'],
        },
      ),
    ],
    weight: 4,
  ),
  // 入宗门
  LifeEventConfig(
    id: 'join_sect',
    title: '拜入宗门',
    description: '你有机会加入一座宗门，选择你的去向。',
    worlds: [World.mortal, World.immortal],
    minAge: 13,
    maxAge: 25,
    conditions: {'needsLiteracy': true, 'needsCultivation': true},
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'pick_fire',
        label: '投赤炎剑宗（天）',
        effects: {
          'delta': {'family': 1, 'exp': 20},
          'log': '你拜入赤炎剑宗，获得火金系资源。',
          'sectId': 'fire_sword_sect'
        },
      ),
      LifeEventChoice(
        id: 'pick_star',
        label: '投星河书院（圣地）',
        effects: {
          'delta': {'intelligence': 1, 'exp': 25},
          'log': '你进入星河书院，接触阵法与符箓。',
          'sectId': 'star_academy'
        },
      ),
      LifeEventChoice(
        id: 'pick_none',
        label: '暂不入宗',
        effects: {
          'log': '你选择暂时游历四方，等待更好机缘。',
        },
      ),
    ],
    weight: 3,
  ),
  // 少年至筑基阶段
  LifeEventConfig(
    id: 'teen_trial',
    title: '少年试炼',
    description: '你参与山门试炼，检验基础修为。',
    worlds: [World.mortal, World.immortal, World.nether],
    minAge: 13,
    maxAge: 20,
    prerequisites: ['cultivation_started'],
    effects: {
      'age': 0,
      'delta': {'exp': 20, 'strength': 1}
    },
    weight: 4,
  ),
  LifeEventConfig(
    id: 'foundation_push',
    title: '冲击筑基',
    description: '你尝试凝聚筑基，稳固根基。',
    worlds: [World.mortal, World.immortal],
    minAge: 16,
    maxAge: 30,
    prerequisites: ['cultivation_started'],
    effects: {
      'age': 0,
      'delta': {'exp': 30}
    },
    weight: 3,
  ),
  LifeEventConfig(
    id: 'clan_competition',
    title: '族比争锋',
    description: '家族比武开始，你登场一试身手。',
    worlds: [World.mortal, World.immortal],
    minAge: 18,
    maxAge: 35,
    prerequisites: ['cultivation_started'],
    effects: {
      'age': 0,
      'delta': {'exp': 25, 'charm': 1}
    },
    choices: [
      LifeEventChoice(
          id: 'allout',
          label: '全力一战',
          effects: {'delta': {'exp': 30, 'strength': 1}}),
      LifeEventChoice(
          id: 'saveface',
          label: '稳健求胜',
          effects: {'delta': {'exp': 20, 'charm': 1}}),
      LifeEventChoice(
          id: 'observe',
          label: '旁观学习',
          effects: {'delta': {'intelligence': 1, 'exp': 15}}),
    ],
    weight: 3,
  ),
  // 金丹至元婴阶段
  LifeEventConfig(
    id: 'pill_concoct',
    title: '炼制丹药',
    description: '你在丹房尝试炼制基础丹药，提升丹道熟练。',
    worlds: [World.mortal, World.immortal],
    minAge: 40,
    maxAge: 80,
    prerequisites: ['cultivation_started'],
    effects: {
      'age': 0,
      'delta': {'exp': 40, 'intelligence': 1}
    },
    choices: [
      LifeEventChoice(
          id: 'success',
          label: '稳住火候',
          effects: {'delta': {'exp': 40, 'intelligence': 1}}),
      LifeEventChoice(
          id: 'try_new',
          label: '尝试新方',
          effects: {'delta': {'exp': 45, 'luck': -1}}),
      LifeEventChoice(
          id: 'fail',
          label: '失败爆炉',
          effects: {'delta': {'exp': 20, 'charm': -1}, 'log': '爆炉弄得你灰头土脸。'}),
    ],
    weight: 2,
  ),
  LifeEventConfig(
    id: 'nascent_travel',
    title: '元婴神游',
    description: '你神游四方，心神更稳固。',
    worlds: [World.mortal, World.immortal, World.nether],
    minAge: 80,
    maxAge: 150,
    effects: {
      'age': 0,
      'delta': {'exp': 50, 'luck': 1}
    },
    choices: [
      LifeEventChoice(
          id: 'tour_star',
          label: '游历星空',
          effects: {'delta': {'exp': 60, 'luck': 1}}),
      LifeEventChoice(
          id: 'visit_home',
          label: '回归本宗',
          effects: {'delta': {'exp': 40, 'family': 1}}),
      LifeEventChoice(
          id: 'enter_secret',
          label: '闯入秘境',
          effects: {'delta': {'exp': 55, 'luck': -1}, 'log': '你在秘境险些迷失，心神受创又觉悟良多。'}),
    ],
    weight: 2,
  ),
  // 化神至仙界阶段
  LifeEventConfig(
    id: 'divine_tribulation',
    title: '雷劫试炼',
    description: '你远离人群渡过一道小雷劫，躲过天威。',
    worlds: [World.mortal, World.immortal, World.nether],
    minAge: 150,
    maxAge: 400,
    prerequisites: ['cultivation_started'],
    effects: {
      'age': 0,
      'delta': {'exp': 80, 'luck': 1}
    },
    choices: [
      LifeEventChoice(
          id: 'hard_resist',
          label: '硬抗雷劫',
          effects: {'delta': {'exp': 90, 'strength': 1}}),
      LifeEventChoice(
          id: 'use_treasure',
          label: '借宝护体',
          effects: {'delta': {'exp': 70, 'luck': 1}, 'log': '宝物消耗，但你安然度过。'}),
      LifeEventChoice(
          id: 'evade',
          label: '尝试躲避',
          effects: {'delta': {'exp': 60, 'luck': -1}, 'log': '雷劫稍退，但你错失淬炼。'}),
    ],
    weight: 2,
  ),
  LifeEventConfig(
    id: 'ascend_chance',
    title: '飞升机缘',
    description: '你在古遗迹中感到一丝上界气息，心有所悟。',
    worlds: [World.mortal, World.immortal],
    minAge: 300,
    maxAge: 600,
    prerequisites: ['cultivation_started'],
    effects: {
      'age': 0,
      'delta': {'exp': 100, 'intelligence': 2}
    },
    choices: [
      LifeEventChoice(
          id: 'close_insight',
          label: '闭关参悟',
          effects: {'delta': {'exp': 120, 'intelligence': 2}}),
      LifeEventChoice(
          id: 'seek_master',
          label: '拜访古遗迹灵影',
          effects: {'delta': {'exp': 90, 'luck': 1}}),
      LifeEventChoice(
          id: 'record',
          label: '记录线索',
          effects: {'delta': {'exp': 80, 'intelligence': 1}, 'log': '你留下飞升阵纹的碎片研究。'}),
    ],
    weight: 1,
  ),
  // 高阶漫长岁月
  LifeEventConfig(
    id: 'grand_retreat',
    title: '千年闭关',
    description: '你闭关多年，静看世事变迁。',
    worlds: [World.immortal, World.nether],
    minAge: 600,
    maxAge: 1200,
    prerequisites: ['cultivation_started'],
    effects: {
      'age': 0,
      'delta': {'exp': 150}
    },
    weight: 1,
  ),
  LifeEventConfig(
    id: 'saint_insight',
    title: '大道一瞥',
    description: '你于星河之下感悟大道，灵光一闪。',
    worlds: [World.immortal],
    minAge: 1200,
    maxAge: 2000,
    effects: {
      'age': 0,
      'delta': {'exp': 200, 'intelligence': 2}
    },
    weight: 1,
  ),
  LifeEventConfig(
    id: 'm_street_fight',
    title: '街头打架',
    description: '你卷入了一场打斗。',
    worlds: [World.mortal],
    minAge: 10,
    conditions: {'chance': 0.4},
    effects: {
      'delta': {'strength': 2, 'charm': -1}
    },
    choices: [
      LifeEventChoice(
          id: 'swing',
          label: '全力挥拳',
          effects: {'delta': {'strength': 2, 'charm': -1}}),
      LifeEventChoice(
          id: 'dodge',
          label: '闪避为主',
          effects: {'delta': {'luck': 1, 'strength': 1}}),
      LifeEventChoice(
          id: 'avoid',
          label: '躲开冲突',
          effects: {'delta': {'charm': 1, 'strength': -1}}),
    ],
    weight: 2,
  ),
  LifeEventConfig(
    id: 'm_noble_meet',
    title: '偶遇贵人',
    description: '贵人提点你的人生道路。',
    worlds: [World.mortal],
    minAge: 8,
    conditions: {'chance': 0.2, 'needsLiteracy': true},
    effects: {
      'delta': {'family': 1, 'charm': 1}
    },
    choices: [
      LifeEventChoice(
          id: 'befriend',
          label: '结交贵人',
          effects: {'delta': {'charm': 1, 'family': 1}}),
      LifeEventChoice(
          id: 'ask_advice',
          label: '虚心求教',
          effects: {'delta': {'intelligence': 1, 'family': 1}}),
      LifeEventChoice(
          id: 'miss',
          label: '错过机会',
          effects: {'delta': {'luck': -1}}),
    ],
    weight: 1,
  ),
  LifeEventConfig(
    id: 'nether_hardship',
    title: '险境磨砺',
    description: '魔气侵蚀，你艰难前行。',
    worlds: [World.nether],
    minAge: 3,
    effects: {
      'delta': {'strength': 2, 'charm': -1}
    },
    choices: [
      LifeEventChoice(
          id: 'fight_back',
          label: '硬扛魔气',
          effects: {'delta': {'strength': 2, 'charm': -1}}),
      LifeEventChoice(
          id: 'seek_shelter',
          label: '寻找遮蔽',
          effects: {'delta': {'luck': 1}}),
      LifeEventChoice(
          id: 'meditate',
          label: '静心抵抗',
          effects: {'delta': {'intelligence': 1}}),
    ],
  ),
  LifeEventConfig(
    id: 'immortal_retreat',
    title: '仙界修行',
    description: '仙气萦绕，你可以闭关、游赏或出门历练。',
    worlds: [World.immortal],
    minAge: 6,
    maxAge: 1200,
    prerequisites: ['cultivation_started', 'root_awakened'],
    effects: {
      'delta': {'intelligence': 2, 'strength': 1}
    },
    choices: [
      LifeEventChoice(
          id: 'focus_qi',
          label: '闭关修炼',
          effects: {
            'delta': {'intelligence': 2, 'exp': 40},
            'log': '你闭关数日，仙气灌体，功法运转更顺畅。'
          }),
      LifeEventChoice(
          id: 'body_train',
          label: '锤炼体魄',
          effects: {
            'delta': {'strength': 2, 'exp': 15},
            'log': '你负重奔跑、挥舞重剑，汗水浸透衣衫，筋骨更坚韧。',
          }),
      LifeEventChoice(
          id: 'wander',
          label: '出门探索',
          effects: {
            'pendingEvents': ['immortal_explore_random'],
            'log': '你决定走出洞府，看看山川与坊市的风云。'
          }),
    ],
    weight: 2,
  ),

  LifeEventConfig(
    id: 'immortal_explore_random',
    title: '仙界游历',
    description: '你踏出洞府，决定在仙界各处行走。',
    worlds: [World.immortal],
    prerequisites: ['cultivation_started', 'root_awakened'],
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'mountain_hunt',
        label: '入山猎妖',
        effects: {
          'delta': {'strength': 1, 'exp': 25},
          'log': '你深入仙山斩杀低阶妖兽，收获灵材与历练。'
        },
      ),
      LifeEventChoice(
        id: 'market',
        label: '逛仙坊市',
        effects: {
          'delta': {'charm': 1, 'exp': 12},
          'log': '你在坊市与仙人讨价还价，见识了稀罕法宝。'
        },
      ),
      LifeEventChoice(
        id: 'secret_forest',
        label: '探幽灵林',
        effects: {
          'delta': {'luck': 1, 'intelligence': 1, 'exp': 18},
          'log': '灵林雾气缭绕，你避过机关，顺手采得灵药。'
        },
      ),
    ],
    weight: 2,
  ),
  LifeEventConfig(
    id: 'ending_old_age',
    title: '寿终正寝',
    description: '岁月无情，你的故事告一段落。',
    worlds: [World.mortal, World.nether, World.immortal],
    minAge: 80,
    effects: {'ending': '寿终正寝', 'alive': false, 'age': 1},
    choices: [
      LifeEventChoice(
          id: 'reflect',
          label: '回首往昔',
          effects: {'log': '你带着平静的心态离开。'}),
      LifeEventChoice(
          id: 'regret',
          label: '心有遗憾',
          effects: {'log': '你仍有未竟之事，或许来生再续。'}),
      LifeEventChoice(
          id: 'share_seed',
          label: '留下种子',
          effects: {'log': '你将此生的故事刻入种子，供人回忆。'}),
    ],
    weight: 1,
  ),
  // fallbacks
  LifeEventConfig(
    id: 'mortal_fallback',
    title: '平淡一年',
    description: '一年平平无奇地过去了。',
    worlds: [World.mortal],
    minAge: 3,
    effects: {'age': 1},
    choices: [
      LifeEventChoice(
        id: 'routine',
        label: '按部就班',
        effects: {'log': '你循规蹈矩地过完这一年。'},
      ),
      LifeEventChoice(
        id: 'small_try',
        label: '默默练气',
        effects: {
          'delta': {'exp': 5},
          'log': '你抓紧时间打坐，略有所得。'
        },
      ),
    ],
  ),
  LifeEventConfig(
    id: 'nether_fallback',
    title: '魔界岁月',
    description: '魔风呼啸，你苟活下来。',
    worlds: [World.nether],
    minAge: 3,
    effects: {'age': 1},
    choices: [
      LifeEventChoice(
        id: 'hide',
        label: '龟缩藏匿',
        effects: {'log': '你屏住呼吸躲过一劫，毫发无损。'},
      ),
      LifeEventChoice(
        id: 'hunt',
        label: '猎取魔兽',
        effects: {
          'delta': {'strength': 1, 'exp': 5},
          'log': '你搏杀弱小魔兽，换取了一些资源。'
        },
      ),
    ],
  ),
  LifeEventConfig(
    id: 'immortal_fallback',
    title: '仙界闲居',
    description: '你随族中长辈在仙山间日常起居，未涉修行。',
    worlds: [World.immortal],
    minAge: 3,
    effects: {'age': 0},
    choices: [
      LifeEventChoice(
        id: 'meditate',
        label: '静心参悟',
        effects: {
          'delta': {'intelligence': 1, 'exp': 8},
          'log': '在仙山云雾中，你悟出一丝法理。'
        },
      ),
      LifeEventChoice(
        id: 'stroll',
        label: '游赏仙山',
        effects: {
          'delta': {'charm': 1},
          'log': '你在瑶池仙山漫步，心境澄明。'
        },
      ),
    ],
  ),
];

/// 简易分表过滤（仍使用同一常量表）。后续可替换为独立 JSON/YAML 装载。
List<LifeEventConfig> tableAge0to3() => sampleEvents
    .where((e) => (e.minAge ?? 0) <= 3 && (e.maxAge ?? 2000) >= 0)
    .toList();

List<LifeEventConfig> tableAge4to6() => sampleEvents
    .where((e) => (e.minAge ?? 0) <= 6 && (e.maxAge ?? 2000) >= 4)
    .toList();

List<LifeEventConfig> tableAge7to12() => sampleEvents
    .where((e) => (e.minAge ?? 0) <= 12 && (e.maxAge ?? 2000) >= 7)
    .toList();

List<LifeEventConfig> tableAge13to18() => sampleEvents
    .where((e) => (e.minAge ?? 0) <= 18 && (e.maxAge ?? 2000) >= 13)
    .toList();

List<LifeEventConfig> tableClanChance() =>
    sampleEvents.where((e) => e.id.startsWith('clan_')).toList();

List<LifeEventConfig> tableSectChance() =>
    sampleEvents.where((e) => e.id.startsWith('sect_')).toList();

List<LifeEventConfig> tableWorldDaily(World world) => sampleEvents.where((e) {
      switch (world) {
        case World.mortal:
          return e.id.startsWith('mortal_daily_');
        case World.immortal:
          return e.id.startsWith('immortal_daily_');
        case World.nether:
          return e.id.startsWith('nether_daily_');
      }
    }).toList();
