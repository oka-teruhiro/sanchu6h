import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:sensors_plus/sensors_plus.dart';    // 9
import 'dart:async';                                // 9
import 'package:firebase_core/firebase_core.dart';  // 7.1.0
import 'firebase_options.dart';                     // 7.1.0
import 'services/omikuji_service.dart';             // 7.1.0

void main() async {                                  // 7.1.0
  WidgetsFlutterBinding.ensureInitialized();        // 7.1.0
  await Firebase.initializeApp(                     // 7.1.0
    options: DefaultFirebaseOptions.currentPlatform, // 7.1.0
  );                                                 // 7.1.0
  runApp(const MyApp());                             // 7.1.0
}                                                    // 7.1.0

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('おみくじが出てくるアニメ'),
        ),
        body: const BottomViewAnimation(),
      ),
    );
  }
}

class BottomViewAnimation extends StatefulWidget {
  const BottomViewAnimation({super.key});

  @override
  BottomViewAnimationState createState() => BottomViewAnimationState();
}

class BottomViewAnimationState extends State<BottomViewAnimation>
    with SingleTickerProviderStateMixin {
  final OmikujiService _service = OmikujiService();
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Map<String, dynamic>? _currentOmikuji;
  final List<String> _displayedContent = [];
  int _currentLine = 0;
  int _currentChar = 0;
  String _currentText = '';
  final ScrollController _scrollController = ScrollController();
  bool _bottomViewVisible = false;
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _gyroscopeSubscription;
  double _lastX = 0.0;
  double _lastY = 0.0;
  double _lastZ = 0.0;                         // 9

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // ３秒かけてボトムビューが現れる
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _bottomViewVisible = true;
        });
        _startTextAnimation();  // アニメーション完了後にテキストアニメーション開始
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _bottomViewVisible = false;
          // おみくじの状態をリセット
          _displayedContent.clear();
          _currentLine = 0;
          _currentChar = 0;
          _currentText = '';
          _currentOmikuji = null;
        });
      }
    });
    _startListening(); // 9
    //_controller.forward(); //todo:変更
  }

  void _startListening() {
    _accelerometerSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
          double deltaX = (event.x - _lastX).abs();
          double deltaY = (event.y - _lastY).abs();
          double deltaZ = (event.z - _lastZ).abs();

          if (deltaX > 2 || deltaY > 2 || deltaZ > 2) {
            _startAnimation();
          }

          _lastX = event.x;
          _lastY = event.y;
          _lastZ = event.z;
        });

    _gyroscopeSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
      if (event.y > 2) {
        _reverseAnimation();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }

  // 7.1.0 以下追加
  void _startAnimation() async {
    try {
      final omikuji = await _service.drawOmikuji();
      if (omikuji != null && mounted) {
        setState(() {
          _currentOmikuji = omikuji;
        });
        _controller.forward();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

// テキストアニメーション関連のメソッドを追加
  void _startTextAnimation() {
    if (_currentOmikuji == null) return;
    final content = List<String>.from(_currentOmikuji!['content']);
    _animateText(content);
  }

  void _animateText(List<String> content) async {
    if (_currentLine >= content.length) return;

    if (_currentChar >= content[_currentLine].length) {
      setState(() {
        _displayedContent.add(_currentText);
        _currentText = '';
        _currentChar = 0;
        _currentLine++;
      });

      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      await Future.delayed(const Duration(milliseconds: 400));
      _animateText(content);
      return;
    }

    setState(() {
      _currentText = content[_currentLine].substring(0, _currentChar + 1);
      _currentChar++;
    });

    await Future.delayed(const Duration(milliseconds: 50));
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }

    await Future.delayed(const Duration(milliseconds: 50));
    _animateText(content);
  }
    // 7.1.0 追加ここまで

  void _reverseAnimation() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double bottomViewHeight = screenHeight * 4 / 5;
    final containerWidth = MediaQuery.of(context).size.width * 0.9;

    // フォントサイズの計算
    final maxLength = _currentOmikuji != null ?
    [..._currentOmikuji!['content']].fold<int>(0, (maxLen, line) =>
    line.length > maxLen ? line.length : maxLen) : 20;
    final calculatedFontSize = (containerWidth / maxLength) * 0.93;
    final baseFontSize = calculatedFontSize.clamp(14.0, 42.0);

    return Stack(
      children: [
        // おみくじアニメボタンを配置
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    '天からのメッセージをお伝えします',
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    speed: const Duration(microseconds: 200),
                  ),
                ],
                totalRepeatCount: 1,
              ),
              ElevatedButton(
                onPressed: _startAnimation,
                child: const Text(
                  'おみくじアニメ',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ボトムビュー
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              height: bottomViewHeight,
              color: Colors.black,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: containerWidth,
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _displayedContent.length +
                              (_currentOmikuji != null && _currentLine < _currentOmikuji!['content'].length ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _displayedContent.length) {
                              if (_displayedContent[index].isEmpty) {
                                return SizedBox(height: baseFontSize * 1.5);
                              }
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: baseFontSize * 0.4,
                                ),
                                child: Text(
                                  _displayedContent[index],
                                  style: TextStyle(
                                    fontSize: baseFontSize,
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: baseFontSize * 0.4,
                                ),
                                child: Text(
                                  _currentText,
                                  style: TextStyle(
                                    fontSize: baseFontSize,
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _reverseAnimation,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                    child: const Text(
                      '戻る',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
