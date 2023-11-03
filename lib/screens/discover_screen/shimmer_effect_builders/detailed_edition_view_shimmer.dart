import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

Expanded detailedEditionInfoShimmerBuilder(BuildContext context) {
  return Expanded(
    child: Scrollbar(
      thickness: 3,
      radius: Radius.circular(20),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Başlık",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            ShimmerWidget.rounded(
                width: MediaQuery.sizeOf(context).width / 2,
                height: 15,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            Divider(color: Colors.transparent, thickness: 0),
            Text(
              "Yazarlar",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            ShimmerWidget.rounded(
                width: MediaQuery.sizeOf(context).width / 4,
                height: 15,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            Divider(color: Colors.transparent, thickness: 0),
            Text(
              "Açıklama",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
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
              "Yayıncı",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            ShimmerWidget.rounded(
                width: MediaQuery.sizeOf(context).width / 4,
                height: 15,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            Divider(color: Colors.transparent, thickness: 0),
            Text(
              "Kitap formatı",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            ShimmerWidget.rounded(
                width: MediaQuery.sizeOf(context).width / 4,
                height: 15,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            Divider(color: Colors.transparent, thickness: 0),
            Text(
              "Isbn 10",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            ShimmerWidget.rounded(
                width: MediaQuery.sizeOf(context).width / 4,
                height: 15,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            Divider(color: Colors.transparent, thickness: 0),
            Text(
              "Isbn 13",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            ShimmerWidget.rounded(
                width: MediaQuery.sizeOf(context).width / 3,
                height: 15,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            Divider(color: Colors.transparent, thickness: 0),
            Text(
              "Kitap durumu",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.transparent, thickness: 0),
            ShimmerWidget.rounded(
                width: MediaQuery.sizeOf(context).width / 3,
                height: 15,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
          ],
        ),
      ),
    ),
  );
}
