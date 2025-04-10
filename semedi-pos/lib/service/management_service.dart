import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:semedi_pos/models/menu.dart';
import 'package:semedi_pos/models/waiter.dart';

class ManagementService {
  Future<List<MenuItem>> getMenuList() async {
    final db = FirebaseFirestore.instance;
    final querySnapshot = await db
        .collection('shops')
        .doc('Barkulan')
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
    final db = FirebaseFirestore.instance;
    final querySnapshot = await db
        .collection('shops')
        .doc('Barkulan')
        .collection('metadata')
        .doc('totalTables')
        .get();
    int tableNumber = querySnapshot.data()?['totalTables'];
    return tableNumber;
  }

  Future<List<Waiter>> getWaitersList() async {
    final db = FirebaseFirestore.instance;
    final querySnapshot = await db
        .collection('users')
        .doc('waiterRoot')
        .collection('barkulan')
        .withConverter<Waiter>(
          fromFirestore: (snapshot, _) => Waiter.fromFirestore(snapshot),
          toFirestore: (_, __) => throw UnimplementedError(
              "Writing isn't allowed in user collection"),
        )
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
