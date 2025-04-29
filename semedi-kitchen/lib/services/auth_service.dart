import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semedi_kitchen/models/kitchen_user.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';
import 'package:semedi_kitchen/services/service_locator.dart';

class AuthService {
  final secureStorageService = getIt<SecureStorageService>();
  Stream<KitchenUser?> get authStateWithUser {
    return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
      final kitchenUser = await _getUserFromKitchenList();
      try {
        if (user == null) {
          await secureStorageService.clear();
          return null;
        }

        if (kitchenUser != null) {
          await secureStorageService.write(
              'restaurant', kitchenUser.restaurant);
        }
      } catch (e) {
        throw Exception(e);
      }
      return kitchenUser;
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

  Future<KitchenUser?> _getUserFromKitchenList() async {
    try {
      final email = FirebaseAuth.instance.currentUser?.email;
      final db = FirebaseFirestore.instance;
      final querySnapshot = await db
          .collection('users')
          .doc('kitchenRoot')
          .collection('kitchens')
          .where('email', isEqualTo: email)
          .withConverter<KitchenUser>(
            fromFirestore: (snapshot, _) => KitchenUser.fromFirestore(snapshot),
            toFirestore: (_, __) => throw UnimplementedError(
                "Writing isn't allowed in user collection"),
          )
          .get();
      KitchenUser? kitchenUser = querySnapshot.docs.first.data();
      return kitchenUser;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await secureStorageService.clear();
  }
}
