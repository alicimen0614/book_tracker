import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

errorSnackBar(BuildContext snackbarContext, String errorMessage,
    {String infoMessage = ''}) {
  infoMessage =
      '${AppLocalizations.of(snackbarContext)!.somethingWentWrong} ${AppLocalizations.of(snackbarContext)!.tryAgainLater}';
  return ScaffoldMessenger.of(snackbarContext).showSnackBar(SnackBar(
    duration: const Duration(seconds: 4),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(infoMessage),
        const SizedBox(
          height: 3,
        ),
      ],
    ),
    action: SnackBarAction(
        label: AppLocalizations.of(snackbarContext)!.okay, onPressed: () {}),
    behavior: SnackBarBehavior.floating,
  ));
}
