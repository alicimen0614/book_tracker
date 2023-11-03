import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

Expanded authorInfoBodyShimmerBuilder(BuildContext context) {
  return Expanded(
    child: Scrollbar(
      thickness: 2,
      radius: Radius.circular(20),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Yazar Adı",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            ShimmerWidget.rectangular(
                width: MediaQuery.sizeOf(context).width / 3, height: 10),
            Divider(color: Colors.transparent, thickness: 0),
            Divider(color: Colors.transparent, thickness: 0),
            Text(
              "Biyografi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            SizedBox(
                height: 120,
                child: ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => ShimmerWidget.rectangular(
                          height: 15,
                          width: MediaQuery.sizeOf(context).width - 40,
                        ),
                    separatorBuilder: (context, index) => SizedBox(
                          height: 5,
                        ),
                    itemCount: 5)),
            Align(
              alignment: Alignment.centerRight,
              child: ShimmerWidget.rectangular(
                  width: MediaQuery.sizeOf(context).width / 3, height: 10),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            Text(
              "Yazara Ait Kitaplar",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            SizedBox(
                height: 120,
                width: double.infinity,
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => Container(
                          height: 100,
                          width: 100,
                          child: InkWell(
                              child: Column(
                            children: [
                              Expanded(
                                  flex: 10,
                                  child: ShimmerWidget.rectangular(
                                      width: 50, height: 70)),
                              Spacer(),
                              Expanded(
                                  flex: 2,
                                  child: ShimmerWidget.rectangular(
                                      width: 50, height: 10))
                            ],
                          )),
                        ),
                    itemCount: 5)),
            Divider(color: Colors.transparent, thickness: 0),
            Align(
              alignment: Alignment.centerRight,
              child: ShimmerWidget.rectangular(
                  width: MediaQuery.sizeOf(context).width / 3, height: 10),
            )
          ],
        ),
      ),
    ),
  );
}
