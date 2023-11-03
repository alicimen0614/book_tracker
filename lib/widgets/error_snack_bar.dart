import 'package:flutter/material.dart';

errorSnackBar(BuildContext snackbarContext, String errorMessage,
    {String infoMessage = 'Bir hata meydana geldi. Lütfen tekrar deneyiniz.'}) {
  print(errorMessage);
  return ScaffoldMessenger.of(snackbarContext).showSnackBar(SnackBar(
    duration: Duration(seconds: 4),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(infoMessage),
        SizedBox(
          height: 3,
        ),
        Text(
          '$errorMessage',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.left,
          maxLines: 1,
        ),
      ],
    ),
    action: SnackBarAction(label: 'Tamam', onPressed: () {}),
    behavior: SnackBarBehavior.floating,
  ));
}
