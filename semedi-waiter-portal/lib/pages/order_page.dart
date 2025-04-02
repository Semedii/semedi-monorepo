import 'package:flutter/material.dart';
import 'package:semedi/components/app_button.dart';
import 'package:semedi/components/txt_form_field.dart'; // Make sure this path is correct

class OrderPage extends StatelessWidget {
  const OrderPage({required this.tableNumber, super.key});
  final int tableNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Table $tableNumber Order"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TxtFormField(
              labelText: 'Item 1',
              onChanged: (s) {},
            ),
            const SizedBox(height: 16),
            TxtFormField(
              labelText: 'Item 2',
              onChanged: (s) {},
            ),
            const SizedBox(height: 16),
            TxtFormField(
              labelText: 'Note for the kitchen',
              onChanged: (s) {},
            ),
            const SizedBox(height: 24),
            AppButton(
              text: "Submit Order",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
