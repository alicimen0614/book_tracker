import 'package:book_tracker/const.dart';
import 'package:book_tracker/providers/connectivity_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/services/analytics_service.dart';

import 'package:book_tracker/widgets/animated_button.dart';
import 'package:book_tracker/widgets/bottom_navigation_bar_controller.dart';
import 'package:book_tracker/widgets/internet_connection_error_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/text_field_widget.dart';

enum FormStatus { signIn, register, reset }

class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key, required this.formStatusData});

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

    await ref.read(authProvider).signInWithGoogle(context).then(
      (value) async {
        if (value != null) {
          AnalyticsService().firebaseAnalytics.logLogin(loginMethod: "Google");

          if (FirebaseAuth.instance.currentUser != null) {
            await FirebaseAuth.instance.currentUser!.reload();

            AnalyticsService()
                .firebaseAnalytics
                .setUserId(id: FirebaseAuth.instance.currentUser!.uid);
          }
          ref.read(bookStateProvider.notifier).getPageData();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)!.loginSuccessful)));
        } else {}
      },
    );
  }

  final signInFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final resetFormKey = GlobalKey<FormState>();
  TextEditingController signInEmailController = TextEditingController();
  TextEditingController signInPasswordController = TextEditingController();
  TextEditingController registerEmailController = TextEditingController();
  TextEditingController registerNameController = TextEditingController();

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
          Positioned(
            top: 25,
            left: 10,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  size: 30,
                )),
          ),
          Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        formStatus == FormStatus.register
                            ? AppLocalizations.of(context)!.signUp
                            : formStatus == FormStatus.signIn
                                ? AppLocalizations.of(context)!.signIn
                                : AppLocalizations.of(context)!.resetPassword,
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
                              ? Const.screenSize.height / 1.7
                              : formStatus == FormStatus.signIn
                                  ? Const.screenSize.height / 2.1
                                  : Const.screenSize.height / 2.9,
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
                    return AppLocalizations.of(context)!.enterValidEmail;
                  }
                },
                controller: signInEmailController,
                hintText: AppLocalizations.of(context)!.email,
                autoCorrect: true,
                keyboardType: TextInputType.emailAddress,
                prefixIconData: Icons.mail,
              ),
            ),
            Expanded(
              flex: 3,
              child: TextFieldWidget(
                validator: (value) {
                  if (value!.length < 6 || value.length > 16) {
                    return AppLocalizations.of(context)!.passwordLength;
                  } else {
                    return null;
                  }
                },
                controller: signInPasswordController,
                obscureText: true,
                hintText: AppLocalizations.of(context)!.password,
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
                    child: Text(AppLocalizations.of(context)!.forgotPassword)),
              ),
            ),
            Expanded(
              flex: 2,
              child: AnimatedButton(
                  onTap: () async {
                    if (signInFormKey.currentState!.validate()) {
                      if (mounted) {
                        await ref
                            .read(authProvider)
                            .signInWithEmailAndPassword(
                                signInEmailController.text,
                                signInPasswordController.text,
                                context)
                            .then((value) async {
                          if (value != null) {
                            AnalyticsService()
                                .firebaseAnalytics
                                .logLogin(loginMethod: "E-mail");
                            if (FirebaseAuth.instance.currentUser != null) {
                              await FirebaseAuth.instance.currentUser!.reload();

                              AnalyticsService().firebaseAnalytics.setUserId(
                                  id: FirebaseAuth.instance.currentUser!.uid);
                            }
                            ref.read(bookStateProvider.notifier).getPageData();
                            ref
                                .read(indexBottomNavbarProvider.notifier)
                                .update((state) => 0);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BottomNavigationBarController(),
                                ),
                                (route) => false);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .loginSuccessful)));
                          } else {
                            return;
                          }
                        });
                      }
                    }
                  },
                  text: AppLocalizations.of(context)!.signIn,
                  widthSize: 200,
                  backgroundColor: const Color.fromRGBO(204, 149, 68, 1)),
            ),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Expanded(
                      child: Divider(
                    color: Colors.black38,
                    endIndent: 5,
                  )),
                  googleSignIn(),
                  const Expanded(
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
                  Text(AppLocalizations.of(context)!.notAMemberYet),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          formStatus = FormStatus.register;
                        });
                      },
                      child: Text(AppLocalizations.of(context)!.signUp)),
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
                  if (value!.length >= 3) {
                    return null;
                  } else {
                    return AppLocalizations.of(context)!.enterLongerName;
                  }
                },
                controller: registerNameController,
                hintText: AppLocalizations.of(context)!.fullName,
                autoCorrect: true,
                keyboardType: TextInputType.name,
                prefixIconData: Icons.account_circle,
              ),
            ),
            Expanded(
              flex: 3,
              child: TextFieldWidget(
                validator: (value) {
                  if (EmailValidator.validate(value!)) {
                    return null;
                  } else {
                    return AppLocalizations.of(context)!.enterValidEmail;
                  }
                },
                controller: registerEmailController,
                hintText: AppLocalizations.of(context)!.email,
                autoCorrect: true,
                keyboardType: TextInputType.emailAddress,
                prefixIconData: Icons.mail,
              ),
            ),
            Expanded(
              flex: 3,
              child: TextFieldWidget(
                validator: (value) {
                  if (value!.length < 6 || value.length > 16) {
                    return AppLocalizations.of(context)!.passwordLength;
                  } else if (value != registerPasswordConfirmController.text) {
                    return AppLocalizations.of(context)!.passwordsDoNotMatch;
                  } else if (value.contains(" ")) {
                    return AppLocalizations.of(context)!.passwordNoSpaces;
                  } else {
                    return null;
                  }
                },
                controller: registerPasswordController,
                obscureText: true,
                hintText: AppLocalizations.of(context)!.password,
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
                    return AppLocalizations.of(context)!.passwordLength;
                  } else if (value != registerPasswordConfirmController.text) {
                    return AppLocalizations.of(context)!.passwordsDoNotMatch;
                  } else if (value.contains(" ")) {
                    return AppLocalizations.of(context)!.passwordNoSpaces;
                  } else {
                    return null;
                  }
                },
                controller: registerPasswordConfirmController,
                obscureText: true,
                hintText: AppLocalizations.of(context)!.confirmPassword,
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
                              registerNameController.text,
                              registerEmailController.text,
                              registerPasswordController.text,
                              context)
                          .then(
                        (value) async {
                          if (value != null) {
                            AnalyticsService()
                                .firebaseAnalytics
                                .logSignUp(signUpMethod: "E-mail");
                            await FirebaseAuth.instance.currentUser!
                                .updateDisplayName(registerNameController.text);
                            await FirebaseAuth.instance.currentUser!.reload();
                            if (FirebaseAuth.instance.currentUser != null) {
                              AnalyticsService().firebaseAnalytics.setUserId(
                                  id: FirebaseAuth.instance.currentUser!.uid);
                            }

                            ref
                                .read(indexBottomNavbarProvider.notifier)
                                .update((state) => 0);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BottomNavigationBarController(),
                                ),
                                (route) => false);

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .createAccountSuccessful)));
                          } else {
                            return;
                          }
                        },
                      );
                    }
                  },
                  text: AppLocalizations.of(context)!.signUp,
                  widthSize: 200,
                  backgroundColor: const Color.fromRGBO(204, 149, 68, 1)),
            ),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Expanded(
                      child: Divider(
                    color: Colors.black38,
                    endIndent: 5,
                  )),
                  googleSignIn(),
                  const Expanded(
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
                  Text(AppLocalizations.of(context)!.alreadyAMember),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          formStatus = FormStatus.signIn;
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context)!.signIn,
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
                    return AppLocalizations.of(context)!.enterValidEmail;
                  }
                },
                controller: resetEmailController,
                hintText: AppLocalizations.of(context)!.email,
                autoCorrect: true,
                keyboardType: TextInputType.emailAddress,
                prefixIconData: Icons.mail,
              ),
            ),
            Expanded(
              flex: 3,
              child: AnimatedButton(
                  onTap: () {},
                  text: AppLocalizations.of(context)!.send,
                  widthSize: 200,
                  backgroundColor: const Color.fromRGBO(204, 149, 68, 1)),
            ),
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  const Expanded(
                      child: Divider(
                    color: Colors.black38,
                    endIndent: 5,
                  )),
                  googleSignIn(),
                  const Expanded(
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
                  child: Text(
                    AppLocalizations.of(context)!.signIn,
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
        isConnected = ref.read(connectivityProvider).isConnected;
        if (isConnected != true) {
          await internetConnectionErrorDialog(context, false);
        } else {
          await _signInWithGoogle(ref)!.whenComplete(() {
            if (ref.read(authProvider).currentUser != null) {
              ref.read(bookStateProvider.notifier).getPageData();
              Navigator.pop(context);
              Navigator.pop(context);
              ref.read(indexBottomNavbarProvider.notifier).update((state) => 0);
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(5),
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
