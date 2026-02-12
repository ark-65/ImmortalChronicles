# ImmortalChronicles · 仙道纪事

一款以“修仙人生”为主题的轻量级生命模拟器，支持多平台运行（iOS / Android / Web / 桌面）。  
**英文名**: ImmortalChronicles  
**中文名**: 仙道纪事

## 核心玩法 / Highlights
- **属性构筑**：通过 `属性分配` 页面自定义初始体质、悟性等关键数值，影响后续人生走向。
- **事件驱动**：海量事件卡片（见 `lib/data`）按照年龄/阶段触发，提供多线分支与随机性。
- **多平台体验**：Flutter 3 构建，同一代码基同时覆盖移动端、Web 与桌面端。
- **持久化支持**：借助 `shared_preferences` 进行本地存档（设置、进度）。

## 快速启动
```bash
flutter pub get          # 安装依赖
flutter run              # 选择目标设备运行
flutter test             # 运行现有组件测试
```

## 代码结构一览
- `lib/main.dart`：应用入口，配置主题与首页导航。
- `lib/pages/attribute_setup_page.dart`：属性分配与开局逻辑。
- `lib/data` / `lib/models` / `lib/services`：事件数据、模型定义与业务服务。
- `web/` `android/` `ios/` `linux/` `windows/`：各平台适配与元数据（名称、图标、清单）。

## 命名与品牌
- **包名**：`immortal_chronicles`
- **显示名**：桌面 & 移动端均为 “ImmortalChronicles / 仙道纪事”
- 若需发布，请根据发行渠道调整各平台的 `bundle identifier` / `applicationId`。

## 开发者须知
- Dart SDK: `^3.10.8`（参见 `pubspec.yaml`）
- 遵循 Flutter 官方最佳实践，更多参考：[Flutter 文档](https://docs.flutter.dev/)

## 版权与授权
- 本项目基于 Apache License 2.0 发布，详情见 `LICENSE`。
- 使用、修改或再分发时需注明原作者 “ark-65” 并附上仓库地址：https://github.com/ark-65/immortal_chronicles（详见 `NOTICE`）。
