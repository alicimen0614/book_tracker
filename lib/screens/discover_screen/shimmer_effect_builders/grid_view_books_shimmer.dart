import 'package:book_tracker/const.dart';
import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

SizedBox gridViewBooksShimmerEffectBuilder() {
  return SizedBox(
    height: Const.screenSize.height / 3,
    width: Const.screenSize.width / 2,
    child: GridView.builder(
      physics: const ClampingScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 25,
          childAspectRatio: 0.5,
          mainAxisSpacing: 25,
          mainAxisExtent: 230),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: ShimmerWidget.rectangular(
                  width: Const.screenSize.width / 4,
                  height: Const.screenSize.height / 6)),
          const SizedBox(
            height: 15,
          ),
          ShimmerWidget.rounded(
            width: Const.screenSize.width / 4,
            height: Const.minSize,
            shapeBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          SizedBox(
            height: Const.minSize,
          ),
          Align(
              alignment: Alignment.center,
              child: ShimmerWidget.rounded(
                  width: Const.screenSize.width / 10,
                  height: Const.minSize,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))))
        ]),
      ),
    ),
  );
}
