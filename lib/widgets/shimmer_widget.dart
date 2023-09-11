import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color baseColor;
  final ShapeBorder shapeBorder;
  final Color highlightColor;

  const ShimmerWidget.rectangular(
      {required this.width,
      required this.height,
      this.baseColor = const Color.fromRGBO(195, 129, 84, 1),
      this.highlightColor = Colors.white})
      : this.shapeBorder = const RoundedRectangleBorder();

  const ShimmerWidget.rounded(
      {required this.width,
      required this.height,
      required this.baseColor,
      required this.shapeBorder,
      this.highlightColor = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(color: Colors.grey, shape: shapeBorder),
      ),
    );
  }
}
