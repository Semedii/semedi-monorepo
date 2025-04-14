import 'package:firebase_auth/firebase_auth.dart';
import 'package:semedi_pos/service/secure_storage_service.dart';

class AuthService {
  final SecureStorageService _secureStorage = SecureStorageService();

  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String? token = await userCredential.user?.getIdToken();

      if (token != null) {
        return token;
      } else {
        throw Exception("failed to get token");
      }
    } on FirebaseAuthException catch (e) {
      print("aaaa $e");
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  createUserWithEmailAndPassword(String emailAddress, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await _secureStorage.clear();
  }
}
