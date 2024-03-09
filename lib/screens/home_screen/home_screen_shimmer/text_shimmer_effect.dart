import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

ShimmerWidget textShimmerEffect(BuildContext context, double width) {
  return ShimmerWidget.rounded(
      width: width,
      height: 10,
      shapeBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)));
}
