import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

SizedBox categoriesViewShimmerEffect() {
  return SizedBox(
    height: 100,
    width: double.infinity,
    child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(
              width: 25,
            ),
        itemCount: 10,
        itemBuilder: (context, index) => SizedBox(
            width: 85,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: ShimmerWidget.rectangular(width: 40, height: 58)),
                const SizedBox(
                  height: 5,
                ),
                ShimmerWidget.rounded(
                    width: 75,
                    height: 10,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)))
              ]),
            ))),
  );
}
