import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi/models/menu.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/services/service_locator.dart';

class MenuService {
  final db = FirebaseFirestore.instance;
  final secureStorageService = getIt<SecureStorageService>();
  Future<List<MenuItem>> getMenu() async {
    String? restaurantName = await _getRestaurantName();
    final querySnapshot = await db
        .collection('shops')
        .doc(restaurantName)
        .collection('menu')
        .withConverter<MenuItem>(
          fromFirestore: (snapshot, _) => MenuItem.fromFirestore(snapshot),
          toFirestore: (_, __) =>
              throw UnsupportedError('Writes not supported'),
        )
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  getTotalTableNumber() async {
    String? restaurantName = await _getRestaurantName();
    final querySnapshot = await db
        .collection('shops')
        .doc(restaurantName)
        .collection('metadata')
        .doc('totalTables')
        .get();
    int tableNumber = querySnapshot.data()?['totalTables'];
    return tableNumber;
  }

  _getRestaurantName() async {
    String? restaurantName = await secureStorageService.read('restaurant');
    return restaurantName;
  }
}
