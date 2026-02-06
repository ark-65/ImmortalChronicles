import 'dart:math';

class ParentRolePick {
  final String father;
  final String mother;
  ParentRolePick(this.father, this.mother);
}

final _rnd = Random();

ParentRolePick pickParentRoles({required int familyScore, required int luck}) {
  // 基础池按家境档位
  List<String> fatherPool;
  List<String> motherPool;

  if (familyScore >= 90) {
    fatherPool = ['族长', '大长老', '真仙护法', '核心长老'];
    motherPool = ['圣地圣女', '族内圣女', '长老', '核心子弟'];
  } else if (familyScore >= 70) {
    fatherPool = ['长老', '内门护法', '核心子弟', '普通子弟'];
    motherPool = ['核心子弟', '内门执事', '族内圣女', '普通子弟'];
  } else if (familyScore >= 50) {
    fatherPool = ['内门护法', '核心子弟', '普通子弟'];
    motherPool = ['内门执事', '核心子弟', '普通子弟'];
  } else if (familyScore >= 30) {
    fatherPool = ['练气高手', '家族护卫', '普通子弟'];
    motherPool = ['凡人娘', '外门杂役', '普通子弟'];
  } else {
    fatherPool = ['凡人父', '老实农夫', '手艺人'];
    motherPool = ['凡人母', '体弱母亲', '村里妇人'];
  }

  // 高 luck 小概率提升一个档次
  bool luckUp = luck >= 80 && _rnd.nextDouble() < 0.2;
  if (luckUp && familyScore < 90) {
    if (familyScore >= 70) {
      fatherPool.add('真仙护法');
      motherPool.add('族内圣女');
    } else if (familyScore >= 50) {
      fatherPool.add('长老');
      motherPool.add('内门执事');
    } else if (familyScore >= 30) {
      fatherPool.add('内门护法');
      motherPool.add('核心子弟');
    }
  }

  final father = fatherPool[_rnd.nextInt(fatherPool.length)];
  final mother = motherPool[_rnd.nextInt(motherPool.length)];
  return ParentRolePick(father, mother);
}
