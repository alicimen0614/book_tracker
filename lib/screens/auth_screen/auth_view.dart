import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/services/internet_connection_service.dart';

import 'package:book_tracker/widgets/animated_button.dart';
import 'package:book_tracker/widgets/bottom_navigation_bar_controller.dart';
import 'package:book_tracker/widgets/internet_connection_error_dialog.dart';
import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/text_field_widget.dart';

enum FormStatus { signIn, register, reset }

class AuthView extends ConsumerStatefulWidget {
  AuthView({super.key, required this.formStatusData});

  final FormStatus formStatusData;
  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  bool isConnected = false;
  Future<void>? _signInWithGoogle(WidgetRef ref) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    // ignore: unused_local_variable

    await ref.read(authProvider).signInWithGoogle(context);
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          body: Stack(
        children: [
          Container(
            height: 350,
            decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 2.0,
                    spreadRadius: 0.0,
                    offset: Offset(2.0, 2.0), // shadow direction: bottom right
                  )
                ],
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25)),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF3A98B9),
                      Color(0xFF1B7695),
                    ])),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  size: 30,
                )),
          ),
          Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        formStatus == FormStatus.register
                            ? "Kayıt Ol"
                            : formStatus == FormStatus.signIn
                                ? "Giriş Yap"
                                : "Parola Sıfırla",
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
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
                    )),
              ),
            ),
            Expanded(
              flex: 2,
              child: AnimatedButton(
                  onTap: () async {
                    if (signInFormKey.currentState!.validate()) {
                      if (mounted)
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
                children: [
                  Expanded(
                      child: Divider(
                    color: Colors.black38,
                    endIndent: 5,
                  )),
                  googleSignIn(),
                  Expanded(
                      child: Divider(
                    color: Colors.black38,
                    indent: 5,
                  )),
                ],
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
                children: [
                  Expanded(
                      child: Divider(
                    color: Colors.black38,
                    endIndent: 5,
                  )),
                  googleSignIn(),
                  Expanded(
                      child: Divider(
                    color: Colors.black38,
                    indent: 5,
                  )),
                ],
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
                children: [
                  Expanded(
                      child: Divider(
                    color: Colors.black38,
                    endIndent: 5,
                  )),
                  googleSignIn(),
                  Expanded(
                      child: Divider(
                    color: Colors.black38,
                    indent: 5,
                  )),
                ],
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
                  )),
            )
          ],
        ),
      ),
    );
  }

  InkWell googleSignIn() {
    return InkWell(
      onTap: () async {
        isConnected = await checkForInternetConnection();
        if (isConnected != true) {
          await internetConnectionErrorDialog(context);
        } else {
          await _signInWithGoogle(ref)!.whenComplete(() {
            if (ref.read(authProvider).currentUser != null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BottomNavigationBarController(),
                  ),
                  (route) => false);
            }
          });
        }

        ;
      },
      child: Container(
        padding: EdgeInsets.all(5),
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white,
        ),
        child: Image.asset(
          "lib/assets/images/google.png",
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }
}
