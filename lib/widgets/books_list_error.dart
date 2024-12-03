import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@override
Center booksListError(
    bool isNetworkError, BuildContext context, VoidCallback? onTryAgain,
    {String title = '', String? message = ''}) {
  if (isNetworkError == true) {
    title = AppLocalizations.of(context)!.noInternetConnection;
    message = AppLocalizations.of(context)!.checkInternetConnection;
  } else {
    title = AppLocalizations.of(context)!.somethingWentWrong;
    message =
        "${AppLocalizations.of(context)!.appEncounteredError} \n ${AppLocalizations.of(context)!.tryAgainLater}";
  }

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          isNetworkError == true
              ? Image.asset(
                  "lib/assets/images/no_internet_connection.png",
                  width: MediaQuery.of(context).size.width / 1.2,
                )
              : const SizedBox.shrink(),
          isNetworkError == true
              ? const SizedBox(
                  height: 15,
                )
              : const SizedBox.shrink(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          if (message != '')
            const SizedBox(
              height: 16,
            ),
          if (message != '')
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          if (onTryAgain != null)
            const SizedBox(
              height: 48,
            ),
          if (onTryAgain != null)
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white),
                onPressed: onTryAgain,
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                label: Text(
                  AppLocalizations.of(context)!.retry,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
