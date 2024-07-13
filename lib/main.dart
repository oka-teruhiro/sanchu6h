import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bottom View Animation'),
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

class BottomViewAnimationState extends State<BottomViewAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Center(child: Text('Main Content')),
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              height: 200,
              color: Colors.blue,
              child: const Center(child: Text('Bottom View', style: TextStyle(color: Colors.white, fontSize: 20))),
            ),
          ),
        ),
      ],
    );
  }
}