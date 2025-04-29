import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semedi_pos/models/cashier.dart';
import 'package:semedi_pos/service/secure_storage_service.dart';

class AuthService {
  final SecureStorageService _secureStorage = SecureStorageService();

  Stream<Cashier?> get authStateWithUser {
    return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
      if (user == null) {
        await _secureStorage.clear();
        return null;
      }
      final cashier = await getUserFromCashierList();
      try {
        await _secureStorage.write('restaurant', cashier.restaurant);
      } catch (e) {
        throw Exception(e);
      }
      return cashier;
    });
  }

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

  getUserFromCashierList() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    final db = FirebaseFirestore.instance;
    try {
      final querySnapshot = await db
          .collection('users')
          .doc('cashierRoot')
          .collection('cashiers')
          .where('email', isEqualTo: email)
          .withConverter<Cashier>(
            fromFirestore: (snapshot, _) => Cashier.fromFirestore(snapshot),
            toFirestore: (_, __) => throw UnimplementedError(
                "Writing isn't allowed in user collection"),
          )
          .get();
      return querySnapshot.docs.first.data();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await _secureStorage.clear();
  }
}
