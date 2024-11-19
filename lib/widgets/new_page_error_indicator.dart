import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

InkWell newPageErrorIndicatorBuilder(
    void Function()? onTap, BuildContext context) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${AppLocalizations.of(context)!.somethingWentWrong} ${AppLocalizations.of(context)!.clickToRetry}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 4,
          ),
          const Icon(
            Icons.refresh,
            size: 25,
          ),
        ],
      ),
    ),
  );
}
