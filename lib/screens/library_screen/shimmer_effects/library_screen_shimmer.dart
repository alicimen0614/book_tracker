import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

GridView libraryScreenShimmerEffect() {
  return GridView.builder(
    padding: EdgeInsets.all(20),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        crossAxisSpacing: 25,
        mainAxisSpacing: 25),
    itemBuilder: (context, index) {
      return Column(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: ShimmerWidget.rectangular(width: 85, height: 120)),
        SizedBox(
          height: 5,
        ),
        ShimmerWidget.rounded(
            width: 75,
            height: 10,
            shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        SizedBox(
          height: 5,
        ),
        ShimmerWidget.rounded(
            width: 40,
            height: 10,
            shapeBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))
      ]);
    },
  );
}
