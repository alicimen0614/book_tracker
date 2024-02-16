import 'package:book_tracker/widgets/error_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _firebaseAuth = FirebaseAuth.instance;

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
          infoMessage: "Çıkış yapılırken bir hata meydana geldi");
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
      errorSnackBar(context, e.toString());
      return null;
    }
    // Trigger the authentication flow
  }

  Future createUserWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Parola en az 6 karakter içermelidir.'),
            action: SnackBarAction(label: 'Tamam', onPressed: () {}),
            behavior: SnackBarBehavior.floating,
          ));

          break;
        case 'email-already-in-use':
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
                'E-posta adresi zaten başka bir hesap tarafından kullanılıyor.'),
            action: SnackBarAction(label: 'Tamam', onPressed: () {}),
            behavior: SnackBarBehavior.floating,
          ));
          break;
        case 'invalid-email':
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('E-posta adresi geçersiz.')));
          break;
        default:
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Bilinmeyen bir hata meydana geldi: ${e.message}')));
          break;
      }
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: "Hesap oluşturulurken bir hata meydana geldi");
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
            content: const Text('E-posta veya parola geçersiz.'),
            action: SnackBarAction(label: 'Tamam', onPressed: () {}),
            behavior: SnackBarBehavior.floating,
          ));

          break;
        case 'wrong-password':
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('E-posta veya parola geçersiz.'),
            action: SnackBarAction(label: 'Tamam', onPressed: () {}),
            behavior: SnackBarBehavior.floating,
          ));
          break;
        case 'invalid-email':
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('E-posta adresi geçersiz.')));
          break;

        case 'user-disabled':
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Bu e-posta adresine sahip kullanıcı devre dışı bırakılmış.')));
          break;
        default:
          ScaffoldMessenger.of(context).clearSnackBars;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Bilinmeyen bir hata meydana geldi')));
          break;
      }
      return null;
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: "Giriş yapılırken bir hata meydana geldi");
      return null;
    }
  }
}
