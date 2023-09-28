import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

SizedBox gridViewBooksShimmerEffectBuilder() {
  return SizedBox(
    height: 500,
    width: 500,
    child: GridView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: 12,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 25,
          childAspectRatio: 0.5,
          mainAxisSpacing: 25),
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          ShimmerWidget.rectangular(width: 180, height: 150),
          SizedBox(
            height: 5,
          ),
          ShimmerWidget.rectangular(width: 180, height: 10)
        ]),
      ),
    ),
  );
}
