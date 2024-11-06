import 'package:book_tracker/const.dart';
import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

Container quoteWidgetShimmer(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    height: Const.screenSize.height * 0.47,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShimmerWidget.rounded(
                width: Const.screenSize.width / 10,
                height: Const.screenSize.width / 10,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100))),
            SizedBox(
              width: Const.minSize,
            ),
            ShimmerWidget.rounded(
                width: Const.screenSize.width / 3,
                height: 15,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)))
          ],
        ),
        SizedBox(
          height: Const.minSize,
        ),
        ShimmerWidget.rounded(
            width: Const.screenSize.width / 1.1,
            height: Const.screenSize.height / 5,
            shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        SizedBox(
          height: Const.minSize,
        ),
        Row(
          children: [
            ShimmerWidget.rounded(
                width: Const.screenSize.width / 5,
                height: Const.screenSize.height / 7,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            SizedBox(
              width: Const.minSize,
            ),
            Column(
              children: [
                ShimmerWidget.rounded(
                    width: Const.screenSize.width / 4,
                    height: 15,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                SizedBox(
                  height: Const.minSize,
                ),
                ShimmerWidget.rounded(
                    width: Const.screenSize.width / 5,
                    height: 15,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)))
              ],
            )
          ],
        ),
        SizedBox(
          height: Const.minSize,
        ),
        ShimmerWidget.rounded(
            width: Const.screenSize.width / 2,
            height: 15,
            shapeBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))
      ],
    ),
  );
}
