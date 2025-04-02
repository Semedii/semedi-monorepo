import 'package:semedi/utils/order_status_enum.dart';

class Order {
  final int tableNumber;
  final List<String> orderItems;
  final OrderStatusEnum orderStatus;
  final String? note;

  Order({
    required this.tableNumber,
    required this.orderItems,
    required this.orderStatus,
    this.note,
  });
}
