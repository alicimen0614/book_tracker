import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String description;
  final String firstButtonText;
  final void Function()? firstButtonOnPressed;
  final String? secondButtonText;
  final void Function()? secondButtonOnPressed;
  final String thirdButtonText;
  final void Function()? thirdButtonOnPressed;

  const CustomAlertDialog(
      {super.key,
      required this.title,
      required this.description,
      required this.firstButtonText,
      required this.firstButtonOnPressed,
      this.secondButtonText,
      this.secondButtonOnPressed,
      required this.thirdButtonText,
      required this.thirdButtonOnPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(title),
      content: Text(description),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
            onPressed: firstButtonOnPressed, child: Text(firstButtonText)),
        if (secondButtonText != null && secondButtonOnPressed != null)
          TextButton(
              onPressed: secondButtonOnPressed, child: Text(secondButtonText!)),
        TextButton(
            onPressed: thirdButtonOnPressed, child: Text(thirdButtonText))
      ],
    );
  }
}
