import 'package:book_tracker/providers/riverpod_management.dart';

import 'package:book_tracker/widgets/animated_button.dart';
import 'package:book_tracker/widgets/bottom_navigation_bar_controller.dart';
import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/text_field_widget.dart';

enum FormStatus { signIn, register, reset }

class AuthView extends ConsumerStatefulWidget {
  AuthView({super.key, required this.formStatusData});

  FormStatus formStatusData;
  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  Future<void>? _signInWithGoogle(WidgetRef ref) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    final user = await ref.read(authProvider).signInWithGoogle();
  }

  final signInFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final resetFormKey = GlobalKey<FormState>();
  TextEditingController signInEmailController = TextEditingController();
  TextEditingController signInPasswordController = TextEditingController();
  TextEditingController registerEmailController = TextEditingController();
  TextEditingController registerPasswordController = TextEditingController();
  TextEditingController registerPasswordConfirmController =
      TextEditingController();
  TextEditingController resetEmailController = TextEditingController();

  @override
  void dispose() {
    signInEmailController.dispose();
    signInPasswordController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerPasswordConfirmController.dispose();
    resetEmailController.dispose();
    super.dispose();
  }

  late FormStatus formStatus = widget.formStatusData;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(top: 30),
      child: Scaffold(
          body: Stack(
        children: [
          Container(
            height: 350,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25)),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(195, 129, 84, 1),
                      Color.fromRGBO(122, 70, 55, 1),
                    ])),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  size: 35,
                )),
          ),
          Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        formStatus == FormStatus.register
                            ? "Kayıt Ol"
                            : formStatus == FormStatus.signIn
                                ? "Giriş Yap"
                                : "Parola Sıfırla",
                        style: const TextStyle(fontSize: 25)),
                    const SizedBox(
                      height: 8,
                    ),
                    Material(
                      borderRadius: BorderRadius.circular(25),
                      elevation: 25,
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color.fromRGBO(249, 224, 187, 1),
                          ),
                          height: formStatus == FormStatus.register
                              ? 400
                              : formStatus == FormStatus.signIn
                                  ? 400
                                  : 300,
                          width: 300,
                          child: formStatus == FormStatus.register
                              ? registerForm()
                              : formStatus == FormStatus.signIn
                                  ? signInForm()
                                  : resetForm()),
                    )
                  ],
                ),
              )),
          Container()
        ],
      )),
    );
  }

  Form signInForm() {
    return Form(
      key: signInFormKey,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: TextFieldWidget(
                validator: (value) {
                  if (EmailValidator.validate(value!)) {
                    return null;
                  } else {
                    return 'Lütfen geçerli bir E-posta adresi giriniz.';
                  }
                },
                controller: signInEmailController,
                hintText: "E-mail",
                autoCorrect: true,
                keyboardType: TextInputType.emailAddress,
                prefixIconData: Icons.account_circle,
              ),
            ),
            Expanded(
              flex: 3,
              child: TextFieldWidget(
                validator: (value) {
                  if (value!.length < 6 || value.length > 16) {
                    return "Şifreniz 6-16 karakter arasında olmalıdır";
                  } else {
                    return null;
                  }
                },
                controller: signInPasswordController,
                obscureText: true,
                hintText: "Şifre",
                autoCorrect: true,
                keyboardType: TextInputType.emailAddress,
                prefixIconData: Icons.lock,
                suffixIconData: Icons.remove_red_eye,
                useSuffixIcon: true,
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        formStatus = FormStatus.reset;
                      });
                    },
                    child: const Text(
                      "Şifremi Unuttum",
                      style: TextStyle(color: Colors.amber),
                    )),
              ),
            ),
            Expanded(
              flex: 2,
              child: AnimatedButton(
                  onTap: () async {
                    if (signInFormKey.currentState!.validate()) {
                      await ref
                          .read(authProvider)
                          .signInWithEmailAndPassword(
                              signInEmailController.text,
                              signInPasswordController.text,
                              context)
                          .then((value) {
                        if (value != null) {
                          print("value not null");
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BottomNavigationBarController(),
                              ),
                              (route) => false);
                        } else {
                          print("value is null");
                          return;
                        }
                      });
                    }
                  },
                  text: "Giriş Yap",
                  widthSize: 200,
                  backgroundColor: const Color.fromRGBO(204, 149, 68, 1)),
            ),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [facebookSignIn(), googleSignIn()],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Üye değil misin?"),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          formStatus = FormStatus.register;
                        });
                      },
                      child: const Text(
                        "Üye Ol",
                        style: TextStyle(color: Colors.amber),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Form registerForm() {
    return Form(
      key: registerFormKey,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: TextFieldWidget(
                validator: (value) {
                  if (EmailValidator.validate(value!)) {
                    return null;
                  } else {
                    return 'Lütfen geçerli bir E-posta adresi giriniz.';
                  }
                },
                controller: registerEmailController,
                hintText: "E-posta",
                autoCorrect: true,
                keyboardType: TextInputType.emailAddress,
                prefixIconData: Icons.account_circle,
              ),
            ),
            Expanded(
              flex: 3,
              child: TextFieldWidget(
                validator: (value) {
                  if (value!.length < 6 || value.length > 16) {
                    return "Şifreniz 6-16 karakter arasında olmalıdır";
                  } else if (value != registerPasswordConfirmController.text) {
                    return 'Şifreler Uyuşmuyor';
                  } else if (value.contains(" ")) {
                    return "Şifrede boşluk olamaz.";
                  } else {
                    return null;
                  }
                },
                controller: registerPasswordController,
                obscureText: true,
                hintText: "Şifre",
                autoCorrect: true,
                keyboardType: TextInputType.emailAddress,
                prefixIconData: Icons.lock,
                suffixIconData: Icons.remove_red_eye,
                useSuffixIcon: true,
              ),
            ),
            Expanded(
              flex: 3,
              child: TextFieldWidget(
                validator: (value) {
                  if (value!.length < 6 || value.length > 16) {
                    return "Şifreniz 6-16 karakter arasında olmalıdır";
                  } else if (value != registerPasswordConfirmController.text) {
                    return 'Şifreler Uyuşmuyor';
                  } else if (value.contains(" ")) {
                    return "Şifrede boşluk olamaz.";
                  } else {
                    return null;
                  }
                },
                controller: registerPasswordConfirmController,
                obscureText: true,
                hintText: "Şifre tekrar",
                autoCorrect: true,
                keyboardType: TextInputType.emailAddress,
                prefixIconData: Icons.lock,
                suffixIconData: Icons.remove_red_eye,
                useSuffixIcon: true,
              ),
            ),
            Expanded(
              flex: 2,
              child: AnimatedButton(
                  onTap: () async {
                    if (registerFormKey.currentState!.validate()) {
                      await ref
                          .read(authProvider)
                          .createUserWithEmailAndPassword(
                              registerEmailController.text,
                              registerPasswordController.text,
                              context);
                    }
                  },
                  text: "Kayıt Ol",
                  widthSize: 200,
                  backgroundColor: const Color.fromRGBO(204, 149, 68, 1)),
            ),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [facebookSignIn(), googleSignIn()],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Zaten üye misin?"),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          formStatus = FormStatus.signIn;
                        });
                      },
                      child: const Text(
                        "Giriş Yap",
                        style: TextStyle(color: Colors.amber),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Form resetForm() {
    return Form(
      key: resetFormKey,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: TextFieldWidget(
                validator: (value) {
                  if (EmailValidator.validate(value!)) {
                    return null;
                  } else {
                    return "Lütfen geçerli bir e-mail adresi giriniz";
                  }
                },
                controller: resetEmailController,
                hintText: "E-mail",
                autoCorrect: true,
                keyboardType: TextInputType.emailAddress,
                prefixIconData: Icons.account_circle,
              ),
            ),
            Expanded(
              flex: 3,
              child: AnimatedButton(
                  onTap: () {},
                  text: "Gönder",
                  widthSize: 200,
                  backgroundColor: const Color.fromRGBO(204, 149, 68, 1)),
            ),
            Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [facebookSignIn(), googleSignIn()],
              ),
            ),
            Expanded(
              flex: 3,
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      formStatus = FormStatus.signIn;
                    });
                  },
                  child: const Text(
                    "Giriş Yap",
                    style: TextStyle(color: Colors.amber),
                  )),
            )
          ],
        ),
      ),
    );
  }

  SizedBox facebookSignIn() {
    return SizedBox(
      height: 35,
      width: 125,
      child: ElevatedButton.icon(
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
                const TextStyle(fontSize: 13)),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.blue.shade700)),
        onPressed: () {},
        icon: const Icon(Icons.facebook, size: 30),
        label: const Text("Facebook ile bağlan"),
      ),
    );
  }

  SizedBox googleSignIn() {
    return SizedBox(
      height: 35,
      width: 125,
      child: ElevatedButton.icon(
          style: ButtonStyle(
              textStyle: MaterialStateProperty.all<TextStyle>(
                  const TextStyle(fontSize: 13)),
              backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromRGBO(253, 132, 31, 1))),
          onPressed: () async {
            await _signInWithGoogle(ref)!.whenComplete(() {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BottomNavigationBarController(),
                  ),
                  (route) => false);
            });
            ;
          },
          icon: const Icon(Icons.g_mobiledata_sharp, size: 30),
          label: const Text("Google ile bağlan")),
    );
  }
}
