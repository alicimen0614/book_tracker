import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color baseColor;
  final ShapeBorder shapeBorder;
  final Color highlightColor;

  ShimmerWidget.rectangular({
    required this.width,
    required this.height,
  })  : this.shapeBorder = const RoundedRectangleBorder(),
        this.baseColor = const Color(0xFFEBEBF4),
        this.highlightColor = Colors.grey.shade300;

  ShimmerWidget.rounded({
    required this.width,
    required this.height,
    required this.shapeBorder,
  })  : this.highlightColor = Colors.grey.shade300,
        this.baseColor = const Color(0xFFEBEBF4);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration:
            ShapeDecoration(shape: shapeBorder, gradient: _shimmerGradient),
      ),
    );
  }

  final _shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFEBEBF4),
      Color(0xFFF4F4F4),
      Color(0xFFEBEBF4),
    ],
    stops: [
      0.1,
      0.3,
      0.4,
    ],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    tileMode: TileMode.clamp,
  );
}
