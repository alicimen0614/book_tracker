import 'package:flutter/material.dart';

import '../widgets/animated_button.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

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
              const AnimatedButton(text: "Kitaplar"),
              const SizedBox(
                width: 15,
              ),
              const AnimatedButton(text: "Kategoriler")
            ],
          )
        ]),
      ),
    );
  }
}
