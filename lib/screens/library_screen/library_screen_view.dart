import 'package:flutter/material.dart';

import '../../widgets/animated_button.dart';

class LibraryScreenView extends StatelessWidget {
  const LibraryScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    print("screen build çalıştı");
    return SafeArea(
      minimum: EdgeInsets.only(top: 30),
      child: Scaffold(
        body: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedButton(
                onTap: () {},
                text: "Kitaplar",
                widthSize: 90,
                backgroundColor: Color.fromRGBO(136, 74, 57, 1),
              ),
              SizedBox(
                width: 15,
              ),
              AnimatedButton(
                onTap: () {},
                text: "Kategoriler",
                widthSize: 90,
                backgroundColor: Color.fromRGBO(136, 74, 57, 1),
              )
            ],
          )
        ]),
      ),
    );
  }
}
