import 'package:flutter/material.dart';

errorSnackBar(BuildContext snackbarContext, String errorMessage,
    {String infoMessage = 'Bir hata meydana geldi. Lütfen tekrar deneyiniz.'}) {
  return ScaffoldMessenger.of(snackbarContext).showSnackBar(SnackBar(
    duration: const Duration(seconds: 4),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(infoMessage),
        const SizedBox(
          height: 3,
        ),
        Text(
          errorMessage,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.left,
          maxLines: 1,
        ),
      ],
    ),
    action: SnackBarAction(label: 'Tamam', onPressed: () {}),
    behavior: SnackBarBehavior.floating,
  ));
}
