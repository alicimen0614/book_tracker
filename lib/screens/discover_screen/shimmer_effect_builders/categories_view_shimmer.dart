import 'package:book_tracker/const.dart';
import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

SizedBox categoriesViewShimmerEffect() {
  return SizedBox(
    height: Const.screenSize.height / 4.7,
    width: double.infinity,
    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) => SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                Expanded(
                  flex: 10,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ShimmerWidget.rectangular(width: 80, height: 70)),
                ),
                Spacer(),
                Expanded(
                  flex: 1,
                  child: ShimmerWidget.rounded(
                      width: 80,
                      height: 2,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                )
              ]),
            ))),
  );
}
