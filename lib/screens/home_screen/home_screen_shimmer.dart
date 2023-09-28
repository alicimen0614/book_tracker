import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

Padding homeScreenShimmer(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(15),
    child: ShimmerWidget.rounded(
        width: MediaQuery.sizeOf(context).width - 20,
        height: MediaQuery.sizeOf(context).height / 3,
        shapeBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
  );
}
