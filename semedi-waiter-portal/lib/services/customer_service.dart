import 'package:semedi/models/customer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerService {
  final _supabase = Supabase.instance.client;

  Future<Customer?> searchCustomer(String phone) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .ilike('phone', '%$phone%')
          .maybeSingle();
      if (response == null) return null;
      return Customer.fromJson(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addCustomer(String name, String phone) async {
    try {
      await _supabase.from('customers').insert({
        'name': name,
        'phone': phone,
        'loyalty_points': 0,
        'restaurant_id':
            _supabase.auth.currentUser!.userMetadata?['restaurant_id'],
      });
    } catch (e) {
      throw Exception(e);
    }
  }
}
