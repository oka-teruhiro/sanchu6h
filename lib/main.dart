import 'package:flutter/material.dart';

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
        /*body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  onPressed: () {
                    //Navigator.push(
                      //context,
                      //MaterialPageRoute(
                        const BottomViewAnimation();
                      //),
                    //);
                  },
                  child: const Text(
                    'おみくじアニメ',
                  style: TextStyle(
                    fontSize: 20,
                  ),),
              ),
            ],
          ),
        ),*/
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
          child: ElevatedButton(
              onPressed: _startAnimation,
              child: const Text(
                  'おみくじアニメ',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              //height: 200,
              height: bottomViewHeight,
              color: Colors.blue,
              child: Center(
                  child: Column(
                    children: [
                      const Text('天からのメッセージをお伝えします',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                          )),
                      const SizedBox(height: 20,),
                      SizedBox(
                        height: bottomViewHeight * 4 / 5,
                        child: Image.asset('assets/images/x6.jpg'),
                      ),

                    ],
                  )),
            ),
          ),
        ),
      ],
    );
  }
}