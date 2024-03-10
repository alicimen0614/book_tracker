import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

ListView homeScreenShimmer(BuildContext context) {
  return ListView.separated(
    scrollDirection: Axis.horizontal,
    physics: const ClampingScrollPhysics(),
    separatorBuilder: (context, index) =>
        const VerticalDivider(color: Colors.transparent, thickness: 0),
    itemCount: 4,
    itemBuilder: (context, index) => SizedBox(
      height: 220,
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 20,
            child: ShimmerWidget.rounded(
                width: MediaQuery.sizeOf(context).width / 3.5,
                height: MediaQuery.sizeOf(context).height / 4.3,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          const Spacer(),
          Expanded(
              flex: 3,
              child: ShimmerWidget.rounded(
                  width: 100,
                  height: 1,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)))),
          const Spacer(),
          Expanded(
              flex: 3,
              child: ShimmerWidget.rounded(
                  width: 70,
                  height: 1,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))))
        ],
      ),
    ),
  );
}
