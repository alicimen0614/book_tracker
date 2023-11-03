import 'package:flutter/material.dart';

Future<dynamic> internetConnectionErrorDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            height: MediaQuery.sizeOf(context).height / 3,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                        "lib/assets/images/no_internet_connection_icon.jpg"),
                    fit: BoxFit.fill),
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 15),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      padding: EdgeInsets.all(15),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        color: Color(0xFF1B7695),
                        Icons.cancel_sharp,
                      ),
                      splashRadius: 25,
                    ),
                  ),
                  Positioned(
                    top: 13,
                    child: const Text(
                      "İnternete bağlanılamadı.",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Positioned(
                    bottom: 25,
                    left: 15,
                    right: 15,
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
