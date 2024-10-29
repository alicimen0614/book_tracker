import 'package:book_tracker/screens/auth_screen/auth_view.dart';
import 'package:flutter/material.dart';

class SignUpDialog extends StatelessWidget {
  const SignUpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text("BookTracker"),
      content: const Text(
          "Bir gönderiyi beğenebilmek için giriş yapmış olmalısınız."),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AuthView(formStatusData: FormStatus.register),
                  ));
            },
            child: const Text("Kayıt Ol")),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AuthView(formStatusData: FormStatus.signIn),
                  ));
            },
            child: const Text("Giriş Yap")),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Kapat"))
      ],
    );
  }
}
