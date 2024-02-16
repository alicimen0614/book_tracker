import 'package:flutter/material.dart';

Center noItemsFoundIndicatorBuilder(double width) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "lib/assets/images/notfound.png",
          width: width / 1.2,
        ),
        SizedBox(
          height: width / 10,
        ),
        Text(
          "Sonuç bulunamadı.",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}
