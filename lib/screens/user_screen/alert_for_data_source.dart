import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AlertForDataSource extends StatelessWidget {
  const AlertForDataSource({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leadingWidth: 50,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppLocalizations.of(context)!.aboutAppDataSource,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_sharp,
                size: 30,
              )),
          automaticallyImplyLeading: false,
          elevation: 5,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                AppLocalizations.of(context)!.appDataSourceAndDisclaimer,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(AppLocalizations.of(context)!.appDataSourceInfo),
              const SizedBox(
                height: 20,
              ),
              Text(
                AppLocalizations.of(context)!.userResponsibility,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(AppLocalizations.of(context)!.userResponsibilityInfo)
            ]),
          ),
        ));
  }
}
