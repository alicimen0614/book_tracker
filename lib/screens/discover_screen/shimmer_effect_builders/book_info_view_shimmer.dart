import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

Padding shimmerEffectForBookInfoView() {
  return Padding(
    padding: EdgeInsets.all(10),
    child: SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: ShimmerWidget.rounded(
                      width: 125,
                      height: 170,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)))),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ShimmerWidget.rounded(
                      width: 150,
                      height: 20,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  SizedBox(
                    height: 10,
                  ),
                  ShimmerWidget.rounded(
                      width: 100,
                      height: 15,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      ShimmerWidget.rounded(
                          width: 50,
                          height: 10,
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      SizedBox(
                        width: 5,
                      ),
                      ShimmerWidget.rounded(
                          width: 50,
                          height: 10,
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)))
                    ],
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ShimmerWidget.rounded(
                width: 50,
                height: 13,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          SizedBox(
            height: 10,
          ),
          ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => ShimmerWidget.rounded(
                  width: MediaQuery.sizeOf(context).width - 40,
                  height: 10,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              separatorBuilder: (context, index) => SizedBox(height: 10),
              itemCount: 5),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ShimmerWidget.rounded(
                width: 50,
                height: 10,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ShimmerWidget.rounded(
                width: 70,
                height: 13,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 10,
            child: ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) => ShimmerWidget.rounded(
                    width: 50,
                    height: 10,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                separatorBuilder: (context, index) => SizedBox(width: 10),
                itemCount: 12),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ShimmerWidget.rounded(
                width: 70,
                height: 13,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          SizedBox(
            height: 10,
          ),
          ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => ShimmerWidget.rounded(
                  width: MediaQuery.sizeOf(context).width - 40,
                  height: 10,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              separatorBuilder: (context, index) => SizedBox(height: 10),
              itemCount: 5),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ShimmerWidget.rounded(
                width: 50,
                height: 10,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          SizedBox(
            height: 7,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ShimmerWidget.rounded(
                width: 70,
                height: 13,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 100,
            child: ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) => Column(
                      children: [
                        ShimmerWidget.rounded(
                            width: 50,
                            height: 70,
                            shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        SizedBox(
                          height: 5,
                        ),
                        ShimmerWidget.rounded(
                            width: 50,
                            height: 10,
                            shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        SizedBox(
                          height: 5,
                        ),
                        ShimmerWidget.rounded(
                            width: 30,
                            height: 10,
                            shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                      ],
                    ),
                separatorBuilder: (context, index) => SizedBox(width: 10),
                itemCount: 6),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ShimmerWidget.rounded(
                width: 100,
                height: 10,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
          )
        ],
      ),
    ),
  );
}
