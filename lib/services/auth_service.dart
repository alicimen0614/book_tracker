import 'package:book_tracker/widgets/error_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:book_tracker/l10n/app_localizations.dart';

class AuthService {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentUser {
    return _firebaseAuth.currentUser;
  }

  Future<String?> get currentUserToken async {
    if (_firebaseAuth.currentUser != null) {
      return await _firebaseAuth.currentUser!.getIdToken();
    }
    return "";
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _firebaseAuth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: AppLocalizations.of(context)!.errorWhileLoggingOut);
    }
  }

  Future<void> sendPasswordResetEmail(String mailEntry,BuildContext context) async {
      try {
         await _firebaseAuth
          .sendPasswordResetEmail(email: mailEntry);
    
        
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'invalid-email':
            throw AppLocalizations.of(context)!.enterValidEmail;
          case 'user-not-found':
            throw AppLocalizations.of(context)!.userNotFound;
          default:
            throw '${AppLocalizations.of(context)!.somethingWentWrong} ${AppLocalizations.of(context)!.tryAgainLater}';
        }

      }
     
  }

  Stream<User?> get authState {
    return _firebaseAuth.authStateChanges();
  }

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        return userCredential.user;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      errorSnackBar(context, e.toString());
      return null;
    }
    // Trigger the authentication flow
  }

  Future<User?> createUserWithEmailAndPassword(
      String name, String email, String password, BuildContext context) async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      _firestore
          .collection("usersBooks")
          .doc(userCredential.user!.uid)
          .set({"name": name});

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.passwordMinLength),
            action: SnackBarAction(
                label: AppLocalizations.of(context)!.okay, onPressed: () {}),
            behavior: SnackBarBehavior.floating,
          ));

          return null;

        case 'email-already-in-use':
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.emailAlreadyInUse),
            action: SnackBarAction(label: 'Tamam', onPressed: () {}),
            behavior: SnackBarBehavior.floating,
          ));
          return null;
        case 'invalid-email':
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.invalidEmailAddress)));
          return null;
        default:
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.appEncounteredError)));
          return null;
      }
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: AppLocalizations.of(context)!.errorCreatingAccount);
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.invalidEmailOrPassword),
            action: SnackBarAction(
                label: AppLocalizations.of(context)!.okay, onPressed: () {}),
            behavior: SnackBarBehavior.floating,
          ));

          break;
        case 'wrong-password':
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.invalidEmailOrPassword),
            action: SnackBarAction(
                label: AppLocalizations.of(context)!.okay, onPressed: () {}),
            behavior: SnackBarBehavior.floating,
          ));
          break;
        case 'invalid-email':
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.invalidEmailAddress)));
          break;

        case 'user-disabled':
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)!.userDisabled)));
          break;
        default:
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.appEncounteredError)));
          break;
      }
      return null;
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: AppLocalizations.of(context)!.errorDuringLogin);
      return null;
    }
  }
}
