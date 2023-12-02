import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AnimatedPercentIndicator extends StatelessWidget {
  const AnimatedPercentIndicator({super.key, required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Center(
        child: CircularPercentIndicator(
          progressColor: Color(0xFF1B7695),
          radius: 40,
          animation: true,
          percent: percentage,
          animateFromLastPercent: true,
          center: Text("%${(percentage * 100).ceil()}"),
        ),
      ),
    );
  }
}
