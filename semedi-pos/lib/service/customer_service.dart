import 'package:semedi_pos/models/customer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerService {
  final _supabase = Supabase.instance.client;

  Future<List<Customer>> getCustomerList() async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .order('name', ascending: true);
      return response.map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Customer>> searchCustomer(String query) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .or('name.ilike.%$query%,phone.ilike.%$query%');
      return response.map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      final response = await _supabase
          .from('customers')
          .select('phone')
          .eq('phone', customer.phone);

      if (response.isNotEmpty) {
        throw Exception('Customer with this phone already exists');
      } else {
        await _supabase.from('customers').insert(customer.toJson());
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateCustomer({
    required Customer oldCustomer,
    required Customer newCustomer,
  }) async {
    try {
      await _supabase
          .from('customers')
          .update(newCustomer.toJson())
          .eq('id', oldCustomer.id);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteCustomer(Customer customer) async {
    try {
      await _supabase.from('customers').delete().eq('id', customer.id);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addLoyaltyPoints(String customerId, int currentPoints, int pointsToAdd) async {
    try {
      await _supabase
          .from('customers')
          .update({'loyalty_points': currentPoints + pointsToAdd})
          .eq('id', customerId);
    } catch (e) {
      throw Exception(e);
    }
  }
}
