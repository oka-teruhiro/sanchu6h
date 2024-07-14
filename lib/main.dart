//import 'dart:ffi';

//import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() => runApp(const MyApp());

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

class BottomViewAnimationState extends State<BottomViewAnimation> with
    SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  // テキストもアニメーションにする
  //late Animation<double> _textAnimation;
  bool _bottomViewVisible = false;

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

   /* _textAnimation = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );*/

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _bottomViewVisible = true;
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _bottomViewVisible = false;
        });
      }
    });
    //_controller.forward(); //todo:変更
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _controller.forward();
  }

  void _reverseAnimation() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double bottomViewHeight = screenHeight * 4 / 5; // ボトムびゅうーの高さ4/5に調整
    return Stack(
      children: [
        const Center(child: Text('Main Content')),

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
                  TyperAnimatedText(
                    '愛は与えて忘れなさい',
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

        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              //height: 200,
              height: bottomViewHeight,
              color: Colors.black,
              child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // テキストをアニメーションで表示
                      if (_bottomViewVisible)
                        AnimatedTextKit(
                            animatedTexts: [
                              TyperAnimatedText(
                                  '天からのメッセージをお伝えします',
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                //speed: const Duration(microseconds: 1000),
                              ),
                              TyperAnimatedText(
                                '愛は与えて忘れなさい',
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                //speed: const Duration(microseconds: 1000),
                              ),
                            ],
                          totalRepeatCount: 1,
                        )
                        /*AnimatedBuilder(
                            animation: _textAnimation,
                            builder: (context, child){
                              final int totalChars = '天からのメッセージをお伝えします'.length;
                              final int charsToShow = (_textAnimation.value * totalChars).round();
                              final String textToShow = '天からのメッセージをお伝えします'.substring(0, charsToShow);
                              return Text(
                                textToShow,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              );
                            },
                        )*/
                      else
                        const Text(
                            //'天からのメッセージをお伝えします',
                            '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),

                      /*const Text('天からのメッセージをお伝えします',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                          )),*/
                      const SizedBox(height: 20,),
                      SizedBox(
                        height: bottomViewHeight * 4 / 5,
                        child: Image.asset('assets/images/おみくじ箱.png'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                          onPressed: _reverseAnimation,
                          child: const Text('OK',
                          style: TextStyle(
                            fontSize: 20,
                          ),)),
                      const SizedBox(height: 20,),
                    ],
                  )),
            ),
          ),
        ),
      ],
    );
  }
}