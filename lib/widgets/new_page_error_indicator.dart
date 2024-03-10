import 'package:flutter/material.dart';

InkWell newPageErrorIndicatorBuilder(void Function()? onTap) {
  return InkWell(
    onTap: onTap,
    child: const Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bir şeyler yanlış gitti. Tekrar denemek için tıklayın.',
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 4,
          ),
          Icon(
            Icons.refresh,
            size: 25,
          ),
        ],
      ),
    ),
  );
}
