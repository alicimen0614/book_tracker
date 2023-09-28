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
              ShimmerWidget.rectangular(width: 125, height: 170),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ShimmerWidget.rectangular(width: 150, height: 20),
                  SizedBox(
                    height: 7,
                  ),
                  ShimmerWidget.rectangular(width: 100, height: 15),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: [
                      ShimmerWidget.rectangular(width: 50, height: 10),
                      SizedBox(
                        width: 5,
                      ),
                      ShimmerWidget.rectangular(width: 50, height: 10)
                    ],
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 7,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ShimmerWidget.rectangular(width: 50, height: 13),
          ),
          SizedBox(
            height: 7,
          ),
          ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) => ShimmerWidget.rectangular(
                  width: MediaQuery.sizeOf(context).width - 40, height: 10),
              separatorBuilder: (context, index) => SizedBox(height: 10),
              itemCount: 5),
          SizedBox(
            height: 7,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ShimmerWidget.rectangular(width: 50, height: 10),
          ),
          SizedBox(
            height: 7,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ShimmerWidget.rectangular(width: 70, height: 13),
          ),
          SizedBox(
            height: 7,
          ),
          Container(
            height: 7,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) => ShimmerWidget.rectangular(
                    width: MediaQuery.sizeOf(context).width - 40, height: 10),
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemCount: 5),
          ),
          SizedBox(
            height: 7,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ShimmerWidget.rectangular(width: 70, height: 13),
          ),
          SizedBox(
            height: 7,
          ),
          ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) => ShimmerWidget.rectangular(
                  width: MediaQuery.sizeOf(context).width - 40, height: 10),
              separatorBuilder: (context, index) => SizedBox(height: 10),
              itemCount: 5),
          SizedBox(
            height: 7,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ShimmerWidget.rectangular(width: 50, height: 10),
          ),
          SizedBox(
            height: 7,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ShimmerWidget.rectangular(width: 70, height: 13),
          ),
          SizedBox(
            height: 7,
          ),
          Container(
            height: 100,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) => Column(
                      children: [
                        ShimmerWidget.rectangular(width: 50, height: 70),
                        SizedBox(
                          height: 5,
                        ),
                        ShimmerWidget.rectangular(width: 50, height: 10),
                        SizedBox(
                          height: 5,
                        ),
                        ShimmerWidget.rectangular(width: 30, height: 10),
                      ],
                    ),
                separatorBuilder: (context, index) => SizedBox(width: 10),
                itemCount: 6),
          ),
          SizedBox(
            height: 7,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ShimmerWidget.rectangular(width: 100, height: 10),
          )
        ],
      ),
    ),
  );
}
