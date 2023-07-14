import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({super.key, required this.text});
  final String text;
  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  double _position = 5;
  final double _shadowHeight = 5;

  @override
  Widget build(BuildContext context) {
    print("animatedbutton build çalıştı");
    final double height = 40 - _shadowHeight;

    return GestureDetector(
      onTapUp: (_) {
        setState(() {
          _position = 5;
        });
      },
      onTapDown: (_) {
        setState(() {
          _position = 0;
        });
      },
      onTapCancel: () {
        setState(() {
          _position = 5;
        });
      },
      child: Container(
        height: height + _shadowHeight,
        width: 90,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                height: height,
                width: 90,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(136, 74, 57, 0.9),
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              curve: Curves.easeIn,
              bottom: _position,
              duration: const Duration(milliseconds: 70),
              child: Container(
                height: height,
                width: 90,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(136, 74, 57, 1),
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
