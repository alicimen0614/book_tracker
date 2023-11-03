import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

Container authorImageAndDetailsShimmerBuilder(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
        color: Color(0xFF1B7695),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50))),
    child: Column(
      children: [
        ShimmerWidget.rectangular(width: 150, height: 200),
        SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(50)),
          width: MediaQuery.sizeOf(context).width - 30,
          height: 50,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Doğum Tarihi",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ShimmerWidget.rectangular(
                      width: MediaQuery.sizeOf(context).width / 3, height: 15)
                ],
              ),
            ),
            VerticalDivider(),
            SizedBox(
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Ölüm Tarihi",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ShimmerWidget.rectangular(
                      width: MediaQuery.sizeOf(context).width / 3, height: 10)
                ],
              ),
            )
          ]),
        ),
      ],
    ),
  );
}
