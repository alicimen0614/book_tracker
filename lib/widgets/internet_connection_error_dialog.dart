import 'package:flutter/material.dart';

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
              child: const Text("Kapat"),
            )
          ],
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: SizedBox(
            height: MediaQuery.of(context).size.height / 2.5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text(
                      "İnternete bağlanılamadı.",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Expanded(
                      flex: 6,
                      child: Image.asset(
                          "lib/assets/images/no_internet_connection.png")),
                  const Expanded(
                    flex: 1,
                    child: Text(
                      "Lütfen internet bağlantınızı kontrol edip tekrar deneyiniz.",
                      style: TextStyle(
                          fontSize: 15,
                          color: Color.fromRGBO(216, 63, 49, 1),
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
