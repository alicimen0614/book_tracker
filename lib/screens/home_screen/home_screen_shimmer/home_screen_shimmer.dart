import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

Container homeScreenShimmer(BuildContext context) {
  return Container(
    height: 220,
    width: 100,
    child: Column(
      children: [
        Expanded(
          flex: 20,
          child: ShimmerWidget.rounded(
              width: MediaQuery.sizeOf(context).width / 3.5,
              height: MediaQuery.sizeOf(context).height / 4,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
        ),
        Spacer(),
        Expanded(
            flex: 3, child: ShimmerWidget.rectangular(width: 100, height: 1)),
        Spacer(),
        Expanded(
            flex: 3, child: ShimmerWidget.rectangular(width: 70, height: 1))
      ],
    ),
  );
}
