import 'package:firebase_auth/firebase_auth.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';

class AuthService {
  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  final SecureStorageService secureStorageService = SecureStorageService();

  signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String? token = await userCredential.user?.getIdToken();

      if (token != null) {
        // Waiter waiter = await _getUserFromWaiterList();
        // await secureStorageService.write('waiter_name', waiter.name);
        // await secureStorageService.write('restaurant', waiter.restaurant);
        return token;
      } else {
        throw Exception("Failed to get token");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  // Future<Waiter> _getUserFromWaiterList() async {
  //   final email = FirebaseAuth.instance.currentUser?.email;
  //   final db = FirebaseFirestore.instance;
  //   final querySnapshot = await db
  //       .collection('users')
  //       .doc('waiterRoot')
  //       .collection('waiters')
  //       .where('email', isEqualTo: email)
  //       .withConverter<Waiter>(
  //         fromFirestore: (snapshot, _) => Waiter.fromFirestore(snapshot),
  //         toFirestore: (_, __) => throw UnimplementedError(
  //             "Writing isn't allowed in user collection"),
  //       )
  //       .get();
  //   return querySnapshot.docs.first.data();
  // }

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await secureStorageService.clear();
  }
}
