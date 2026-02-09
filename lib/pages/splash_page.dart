import 'package:flutter/material.dart';
import '../data/reference_repository.dart';
import '../data/event_repository.dart';
import 'attribute_setup_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _status = '正在初始化世界...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      setState(() {
        _status = '加载基础数据...';
        _progress = 0.2;
      });
      
      // Load Reference Data (Maps, Sects, Families)
      await ReferenceRepository().ensureLoaded();
      
      setState(() {
        _status = '加载事件系统...';
        _progress = 0.6;
      });

      // Load Event Data
      await EventRepository().ensureLoaded();

      setState(() {
        _status = '准备就绪';
        _progress = 1.0;
      });

      // Small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AttributeSetupPage()),
      );
    } catch (e) {
      setState(() {
        _status = '初始化失败: $e';
        _progress = 0.0;
      });
      debugPrint('Splash Init Failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories, size: 80, color: Colors.teal),
            const SizedBox(height: 24),
            Text(
              '人生重开·多界版',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(value: _progress),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
