import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

SingleChildScrollView shimmerEffectForBookInfoView(BuildContext context) {
  return SingleChildScrollView(
    physics: NeverScrollableScrollPhysics(),
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(15),
          height: MediaQuery.of(context).size.height / 4,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 8,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ShimmerWidget.rounded(
                        width: 125,
                        height: MediaQuery.of(context).size.height / 5,
                        shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)))),
              ),
              Spacer(),
              Expanded(
                flex: 16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShimmerWidget.rounded(
                        width: 150,
                        height: 20,
                        shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    SizedBox(
                      height: 35,
                    ),
                    ShimmerWidget.rounded(
                        width: 100,
                        height: 15,
                        shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 30,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (context, index) => SizedBox(
                          width: 10,
                        ),
                        itemCount: 5,
                        itemBuilder: (context, index) => ShimmerWidget.rounded(
                            width: 80,
                            height: 25,
                            shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25))),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
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
        )
      ],
    ),
  );
}
