import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

Container authorImageAndDetailsShimmerBuilder(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: const BoxDecoration(
        color: Color(0xFF1B7695),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50))),
    child: Column(
      children: [
        Align(
            alignment: Alignment.center,
            child: ShimmerWidget.rectangular(
              height: MediaQuery.of(context).size.height / 3.5,
              width: MediaQuery.of(context).size.height / 4.5,
            )),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(50)),
          width: MediaQuery.sizeOf(context).width - 30,
          height: MediaQuery.of(context).size.height / 12,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Doğum Tarihi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 50)),
                  ShimmerWidget.rectangular(
                      width: MediaQuery.sizeOf(context).width / 3, height: 15)
                ],
              ),
            ),
            const VerticalDivider(),
            SizedBox(
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Ölüm Tarihi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 50)),
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
