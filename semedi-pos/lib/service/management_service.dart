import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:semedi_pos/models/menu.dart';
import 'package:semedi_pos/models/waiter.dart';
import 'package:semedi_pos/service/auth_service.dart';
import 'package:semedi_pos/service/secure_storage_service%20copy.dart';

class ManagementService {
  final db = FirebaseFirestore.instance;
  Future<List<MenuItem>?> getMenuList() async {
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

  getTotalTableNumber() async {
    String? restaurant = await _getRestaurantName();
    final querySnapshot = await db
        .collection('shops')
        .doc(restaurant)
        .collection('metadata')
        .doc('totalTables')
        .get();
    int tableNumber = querySnapshot.data()?['totalTables'];
    return tableNumber;
  }

  Future<List<Waiter>> getWaitersList() async {
    final querySnapshot = await db
        .collection('users')
        .doc('waiterRoot')
        .collection('waiters')
        .withConverter<Waiter>(
          fromFirestore: (snapshot, _) => Waiter.fromFirestore(snapshot),
          toFirestore: (_, __) => throw UnimplementedError(
              "Writing isn't allowed in user collection"),
        )
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  addNewWaiter(Waiter waiter, String password) async {
    try {
      await AuthService()
          .createUserWithEmailAndPassword(waiter.email, password);
      await db
          .collection('users')
          .doc('waiterRoot')
          .collection('waiters')
          .add(waiter.toFirestore());
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addMenu(MenuItem newItem) async {
    try {
      String? restaurant = await _getRestaurantName();
      final existingItem = await db
          .collection('shops')
          .doc(restaurant)
          .collection('menu')
          .where('name', isEqualTo: newItem.name)
          .get();

      if (existingItem.docs.isNotEmpty) {
        throw Exception('Menu item with this name already exists');
      }

      await db
          .collection('shops')
          .doc(restaurant)
          .collection('menu')
          .add(newItem.toFirestore());
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteMenu(MenuItem menu) async {
    try {
      String? restaurant = await _getRestaurantName();
      var menuQuery = await db
          .collection('shops')
          .doc(restaurant)
          .collection('menu')
          .where('name', isEqualTo: menu.name)
          .get();

      if (menuQuery.docs.isEmpty) {
        return;
      }
      await menuQuery.docs.first.reference.delete();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateMenu({
    required MenuItem oldItem,
    required MenuItem newItem,
  }) async {
    try {
      String? restaurant = await _getRestaurantName();
      final menuQuery = await db
          .collection('shops')
          .doc(restaurant)
          .collection('menu')
          .where('name', isEqualTo: oldItem.name)
          .get();

      if (menuQuery.docs.isEmpty) {
        throw Exception('Menu item not found');
      }

      await menuQuery.docs.first.reference.update(newItem.toFirestore());
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> incrementTotalTables() async {
    try {
      String? restaurant = await _getRestaurantName();
      final docRef = db
          .collection('shops')
          .doc(restaurant)
          .collection('metadata')
          .doc('totalTables');

      await docRef.update({
        'totalTables': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> decrementTotalTables() async {
    try {
      String? restaurant = await _getRestaurantName();
      final docRef = db
          .collection('shops')
          .doc(restaurant)
          .collection('metadata')
          .doc('totalTables');

      await docRef.update({
        'totalTables': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> setExchangeRate(int exchangeRate) async {
    try {
      String? restaurant = await _getRestaurantName();
      await db
          .collection('shops')
          .doc(restaurant)
          .collection('metadata')
          .doc('exchangeRate')
          .set({'rate': exchangeRate});
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<int> getExchangeRate() async {
    try {
      String? restaurant = await _getRestaurantName();
      final snapshot = await db
          .collection('shops')
          .doc(restaurant)
          .collection('metadata')
          .doc('exchangeRate')
          .get();
      int exchangeRate = snapshot['rate'];
      return exchangeRate;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String?> _getRestaurantName() async {
    String? restaurant = await SecureStorageService().read('restaurant');
    return restaurant;
  }
}
