import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:semedi_kitchen/models/kitchen_user.dart';
import 'package:semedi_kitchen/services/app_session_service.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';
import 'package:semedi_kitchen/services/service_locator.dart';

class AuthService {
  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  final secureStorageService = getIt<SecureStorageService>();

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

  Future<KitchenUser?> getUserFromKitchenList() async {
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
      await SecureStorageService().write('restaurant', kitchenUser.restaurant);
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
    GetIt.instance<AppSessionService>().reset();
    await secureStorageService.clear();
  }
}
