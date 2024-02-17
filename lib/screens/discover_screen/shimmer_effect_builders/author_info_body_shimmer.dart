import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

Expanded authorInfoBodyShimmerBuilder(BuildContext context) {
  return Expanded(
    child: Scrollbar(
      thickness: 2,
      radius: Radius.circular(20),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        physics: ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Yazar Adı",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            ShimmerWidget.rounded(
                width: MediaQuery.sizeOf(context).width / 2,
                height: 15,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            Divider(color: Colors.transparent, thickness: 0),
            Text(
              "Biyografi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            SizedBox(
              height: MediaQuery.sizeOf(context).height / 5.5,
              child: ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => SizedBox(
                  height: 5,
                ),
                itemCount: 5,
                itemBuilder: (context, index) => ShimmerWidget.rounded(
                    height: 15,
                    width: MediaQuery.sizeOf(context).width - 30,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: ShimmerWidget.rounded(
                    width: 100,
                    height: 15,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)))),
            Divider(color: Colors.transparent, thickness: 0),
            Text(
              "Yazara Ait Kitaplar",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            Container(
              height: 150,
              child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => Column(
                        children: [
                          ShimmerWidget.rounded(
                              width: 70,
                              height: 100,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          SizedBox(
                            height: 5,
                          ),
                          ShimmerWidget.rounded(
                              width: 70,
                              height: 10,
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
                        ],
                      ),
                  separatorBuilder: (context, index) => SizedBox(width: 20),
                  itemCount: 4),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            Align(
              alignment: Alignment.centerRight,
              child: ShimmerWidget.rounded(
                  width: MediaQuery.sizeOf(context).width / 3,
                  height: 15,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
            )
          ],
        ),
      ),
    ),
  );
}
