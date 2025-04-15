import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi_kitchen/models/menu.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';
import 'package:semedi_kitchen/services/service_locator.dart';

class MenuService {
  final db = FirebaseFirestore.instance;
  final _secureStorageService = getIt<SecureStorageService>();
  Future<List<MenuItem>> getMenuList() async {
    String? restaurant = await _getRestaurantName();
    final querySnapshot = await db
        .collection('shops')
        .doc(restaurant)
        .collection('menu')
        .withConverter<MenuItem>(
          fromFirestore: (snapshot, _) => MenuItem.fromFirestore(snapshot),
          toFirestore: (_, __) =>
              throw UnsupportedError('Writes not supported'),
        )
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> disableOrEnableMenu({required MenuItem menu}) async {
    try {
      String? restaurant = await _getRestaurantName();
      final querySnapshot = await db
          .collection('shops')
          .doc(restaurant)
          .collection('menu')
          .where('name', isEqualTo: menu.name)
          .get();
      querySnapshot.docs.first.reference
          .update({'isAvailable': !menu.isAvailable});
    } catch (e) {
      throw Exception('Failed to update status: ${e.toString()}');
    }
  }

  Future<String?> _getRestaurantName() async {
    String? restaurant = await _secureStorageService.read('restaurant');
    return restaurant;
  }
}
