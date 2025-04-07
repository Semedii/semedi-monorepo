import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi/models/menu.dart';

class MenuService {
  Future<List<MenuItem>> getMenu() async {
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
}
