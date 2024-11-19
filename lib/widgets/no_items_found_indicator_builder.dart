import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Center noItemsFoundIndicatorBuilder(double width, BuildContext context) {
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
          AppLocalizations.of(context)!.noResultsFound,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}
