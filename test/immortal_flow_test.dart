import 'package:flutter_test/flutter_test.dart';
import 'package:immortal_chronicles/models/models.dart';
import 'package:immortal_chronicles/services/event_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Immortal high-luck flow hits cultivation events', () async {
    final engine = EventEngine(1234);
    final state = PlayerState.newGame(
      name: '测试者',
      strength: 5,
      intelligence: 5,
      charm: 5,
      luck: 20,
      family: 20,
      seed: 1,
      world: World.immortal,
      region: Region.xian,
    );

    // ensure root test will run
    state.pendingEvents.add('age_6_root_test');

    // Fast-forward到6岁执行觉醒
    state.age = 6;
    final rootEvent = await engine.pickEvent(state);
    expect(rootEvent.id, 'age_6_root_test');
    engine.applyEffects(state, rootEvent);
    expect(state.talentLevelName, isNot('未知'));
    expect(state.realm, '炼气');

    // 家族功法学习（挂入pending并拉到7岁）
    state.pendingEvents.add('family_training_5');
    state.age = 7;
    final famEvent = await engine.pickEvent(state);
    expect(famEvent.id, 'family_training_5');
    engine.applyEffects(state, famEvent);

    // 连续取10个事件，应出现修炼/仙界吐纳相关事件
    state.age = 8;
    var seenCultivate = false;
    for (var i = 0; i < 10; i++) {
      final ev = await engine.pickEvent(state);
      engine.applyEffects(state, ev);
      if (ev.id == 'immortal_daily_cultivate' || ev.id == 'immortal_retreat') {
        seenCultivate = true;
        break;
      }
      state.age = (state.age + 1).clamp(0, 2000);
    }
    expect(seenCultivate, isTrue, reason: 'Should see cultivation events after awakening.');
  });
}
