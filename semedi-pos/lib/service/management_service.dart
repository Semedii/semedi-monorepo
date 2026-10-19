import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:semedi_pos/models/menu.dart';
import 'package:semedi_pos/models/menu_modifier.dart';
import 'package:semedi_pos/models/waiter.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class ManagementService {
  final db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;
  Future<List<MenuItem>?> getMenuList() async {
    final response =
        await _supabase.from('menu_items').select('name, price, available');

    return response.map((json) => MenuItem.fromJson(json)).toList();
  }

  getTotalTableNumber() async {
    final int tableNumber = await _supabase.from('dining_tables').count();
    return tableNumber;
  }

//todo
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

//todo
  addNewWaiter(Waiter waiter, String password) async {
    try {
      // await AuthService()
      //     .createUserWithEmailAndPassword(waiter.email, password);
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
      final response = await _supabase
          .from('menu_items')
          .select('name')
          .ilike('name', newItem.name);

      if (response.isNotEmpty) {
        throw Exception('Menu item with this name already exists');
      } else {
        await _supabase.from('menu_items').insert(newItem.toJson());
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteMenu(MenuItem menu) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select('name')
          .ilike('name', menu.name);

      if (response.isEmpty) {
        return;
      } else {
        await _supabase.from('menu_items').delete().eq('name', menu.name);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateMenu({
    required MenuItem oldItem,
    required MenuItem newItem,
  }) async {
    try {
      await _supabase
          .from('menu_items')
          .update(newItem.toJson())
          .eq('name', oldItem.name);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> incrementTotalTables() async {
    try {
      await _supabase.from('dining_tables').insert({
        'restaurant_id':
            _supabase.auth.currentUser?.userMetadata?['restaurant_id'],
        'status': 'available'
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> decrementTotalTables() async {
    try {
      final lastTableNumber = await getTotalTableNumber();
      await _supabase
          .from('dining_tables')
          .delete()
          .eq('table_number', lastTableNumber);
    } catch (e) {
      throw Exception(e);
    }
  }

  //todo

  Future<void> setExchangeRate(int exchangeRate) async {
    try {
      await _supabase
          .from('metadata')
          .update({'exchange_rate': exchangeRate}).eq(
        'restaurant_id',
        _supabase.auth.currentUser?.userMetadata?['restaurant_id'],
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<int?> getExchangeRate() async {
    try {
      final response = await _supabase.from('metadata').select('exchange_rate');
      int? rate = response.first['exchange_rate'];
      return rate;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<MenuModifier>?> getModifierList() async {
    final response = await _supabase
        .from('menu_modifiers')
        .select('name, extra_charge, available');
    return response.map((json) => MenuModifier.fromJson(json)).toList();
  }

  Future<void> addModifier(MenuModifier modifier) async {
    try {
      final response = await _supabase
          .from('menu_modifiers')
          .select('name')
          .ilike('name', modifier.name);

      if (response.isNotEmpty) {
        throw Exception('Modifier with this name already exists');
      } else {
        await _supabase.from('menu_modifiers').insert(modifier.toJson());
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteModifier(MenuModifier modifier) async {
    try {
      final response = await _supabase
          .from('menu_modifiers')
          .select('name')
          .ilike('name', modifier.name);

      if (response.isEmpty) {
        return;
      } else {
        await _supabase
            .from('menu_modifiers')
            .delete()
            .eq('name', modifier.name);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateModifier({
    required MenuModifier oldModifier,
    required MenuModifier newModifier,
  }) async {
    try {
      await _supabase
          .from('menu_modifiers')
          .update(newModifier.toJson())
          .eq('name', oldModifier.name);
    } catch (e) {
      throw Exception(e);
    }
  }
}
