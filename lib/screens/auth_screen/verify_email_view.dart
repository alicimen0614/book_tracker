import 'dart:async';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/l10n/app_localizations.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/widgets/animated_button.dart';
import 'package:book_tracker/widgets/bottom_navigation_bar_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class VerifyEmailView extends ConsumerStatefulWidget {
  final bool isSignInAction;
  const VerifyEmailView({super.key, required this.isSignInAction});

  @override
  ConsumerState<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends ConsumerState<VerifyEmailView> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResendEmail = false;

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

      if (!isEmailVerified) {
        sendEmailVerification();

        timer = Timer.periodic(
          const Duration(seconds: 3),
          (_) => checkEmailVerified(),
        );
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!widget.isSignInAction) {
          ref.read(indexBottomNavbarProvider.notifier).update((state) => 0);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavigationBarController(),
              ),
              (route) => false);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.createAccountSuccessful)));
        } else {
          ref.read(bookStateProvider.notifier).getPageData();
          ref.read(indexBottomNavbarProvider.notifier).update((state) => 0);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavigationBarController(),
              ),
              (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)!.loginSuccessful)));
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Verify your email",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
            onPressed: () async {
              Navigator.pop(context);
              if (FirebaseAuth.instance.currentUser != null) {
                await FirebaseAuth.instance.signOut();
              }
            },
            icon: const Icon(Icons.arrow_back_rounded)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            SizedBox(
              height: Const.screenSize.height * 0.05,
            ),
            !isEmailVerified
                ? Image.asset(
                    "lib/assets/icons/email_pending.png",
                    height: Const.screenSize.height * 0.2,
                  )
                : Image.asset("lib/assets/icons/email_verified.png"),
            SizedBox(
              height: Const.screenSize.height * 0.05,
            ),
            Text.rich(
              TextSpan(
                text: "We've sent an email to ",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                children: [
                  TextSpan(
                    text: "${FirebaseAuth.instance.currentUser!.email}\n",
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text:
                        ' containing an activation link. Please click on the link to activate your account.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: Const.screenSize.height * 0.025,
            ),
            const Text(
              "If you do not receive the email within a few minutes, please check your spam folder.",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: Const.screenSize.height * 0.1,
            ),
            const Text(
              "Still can't find the email?",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Const.minSize),
            Center(
              child: AnimatedButton(
                  onTap: canResendEmail
                      ? sendEmailVerification
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  "Wait a few seconds to resent verification email")));
                        },
                  text: "Resend",
                  widthSize: Const.screenSize.width * 0.8,
                  backgroundColor: const Color.fromRGBO(204, 149, 68, 1)),
            )
          ],
        ),
      ),
    );
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 10));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }
}
