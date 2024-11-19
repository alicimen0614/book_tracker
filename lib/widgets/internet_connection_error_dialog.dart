import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<dynamic> internetConnectionErrorDialog(
    BuildContext context, bool closeThePage) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                closeThePage == true ? Navigator.pop(context) : null;
              },
              child: Text(AppLocalizations.of(context)!.close),
            )
          ],
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.noInternetConnection,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Expanded(
                      flex: 10,
                      child: Image.asset(
                          "lib/assets/images/no_internet_connection.png")),
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.checkInternetConnection,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 50,
                          color: const Color.fromRGBO(216, 63, 49, 1),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ));
    },
  );
}
