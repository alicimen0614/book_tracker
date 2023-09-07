import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerWidget.rectangular({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromRGBO(195, 129, 84, 1),
      highlightColor: Colors.grey.shade400,
      child: Container(
        width: width,
        height: height,
        color: Colors.grey,
      ),
    );
  }
}
