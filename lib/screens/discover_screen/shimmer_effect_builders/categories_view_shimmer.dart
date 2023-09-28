import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

Container categoriesViewShimmerEffect() {
  return Container(
    height: 100,
    width: double.infinity,
    child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => SizedBox(
              width: 25,
            ),
        itemCount: 10,
        itemBuilder: (context, index) => SizedBox(
            width: 85,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(children: [
                ShimmerWidget.rectangular(width: 40, height: 58),
                SizedBox(
                  height: 5,
                ),
                ShimmerWidget.rectangular(width: 75, height: 10)
              ]),
            ))),
  );
}
