import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/customer.dart';
import 'package:semedi_pos/service/customer_service.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerService _customerService;

  CustomerCubit(this._customerService) : super(CustomerInitial());

  initPage() async {
    emit(CustomerLoading());
    try {
      final List<Customer> customers = await _customerService.getCustomerList();
      emit(CustomerLoaded(customers: customers, filtered: customers));
    } catch (e) {
      emit(CustomerFailure(e.toString()));
    }
  }

  void onSearch(String query) {
    final currentState = state as CustomerLoaded;
    final filtered = currentState.customers
        .where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase()) ||
            c.phone.contains(query))
        .toList();
    emit(CustomerLoaded(
      customers: currentState.customers,
      filtered: filtered,
      searchQuery: query,
    ));
  }

  onAddCustomer(String name, String phone) async {
    emit(CustomerLoading());
    final customer = Customer(
      id: '',
      name: name,
      phone: phone,
      createdAt: DateTime.now(),
    );
    try {
      await _customerService.addCustomer(customer);
    } catch (e) {
      emit(CustomerFailure(e.toString()));
    }
    initPage();
  }

  onDeleteCustomer(Customer customer) async {
    emit(CustomerLoading());
    try {
      await _customerService.deleteCustomer(customer);
    } catch (e) {
      emit(CustomerFailure(e.toString()));
    }
    initPage();
  }

  onAddLoyaltyPoints(Customer customer, int points) async {
    emit(CustomerLoading());
    try {
      await _customerService.addLoyaltyPoints(
          customer.id, customer.loyaltyPoints, points);
    } catch (e) {
      emit(CustomerFailure(e.toString()));
    }
    initPage();
  }
}
