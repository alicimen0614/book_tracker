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
        ShimmerWidget.rectangular(width: 75, height: 100),
        SizedBox(
          height: 5,
        ),
        ShimmerWidget.rectangular(width: 75, height: 10)
      ]);
    },
  );
}
