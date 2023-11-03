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
          ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: ShimmerWidget.rectangular(width: 180, height: 150)),
          SizedBox(
            height: 15,
          ),
          ShimmerWidget.rounded(
            width: 180,
            height: 10,
            shapeBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          SizedBox(
            height: 15,
          ),
          Align(
              alignment: Alignment.center,
              child: ShimmerWidget.rounded(
                  width: 60,
                  height: 10,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))))
        ]),
      ),
    ),
  );
}
