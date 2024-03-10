import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

SingleChildScrollView shimmerEffectForBookInfoView(BuildContext context) {
  return SingleChildScrollView(
    physics: const NeverScrollableScrollPhysics(),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          height: MediaQuery.of(context).size.height / 4,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
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
              const Spacer(),
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
                    const SizedBox(
                      height: 35,
                    ),
                    ShimmerWidget.rounded(
                        width: 100,
                        height: 15,
                        shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 30,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (context, index) => const SizedBox(
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
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const SizedBox(
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
              const SizedBox(
                height: 10,
              ),
              ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) => ShimmerWidget.rounded(
                      width: MediaQuery.sizeOf(context).width - 40,
                      height: 10,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: 5),
              const SizedBox(
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
              const SizedBox(
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
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 10,
                child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => ShimmerWidget.rounded(
                        width: 50,
                        height: 10,
                        shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemCount: 12),
              ),
              const SizedBox(
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
              const SizedBox(
                height: 10,
              ),
              ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) => ShimmerWidget.rounded(
                      width: MediaQuery.sizeOf(context).width - 40,
                      height: 10,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: 5),
              const SizedBox(
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
              const SizedBox(
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
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 100,
                child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => Column(
                          children: [
                            ShimmerWidget.rounded(
                                width: 50,
                                height: 70,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                            const SizedBox(
                              height: 5,
                            ),
                            ShimmerWidget.rounded(
                                width: 50,
                                height: 10,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                            const SizedBox(
                              height: 5,
                            ),
                            ShimmerWidget.rounded(
                                width: 30,
                                height: 10,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                          ],
                        ),
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemCount: 6),
              ),
              const SizedBox(
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
