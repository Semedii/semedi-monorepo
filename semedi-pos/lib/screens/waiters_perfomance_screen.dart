import 'package:flutter/material.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class WaitersPerfomanceScreen extends StatelessWidget {
  // Mock data - replace with your actual data source
  final List<Map<String, dynamic>> waitersData = [
    {
      'name': 'Juan Dela Cruz',
      'paid_orders': 24,
      'unpaid_orders': 3,
      'total_sales': 18500.00,
    },
    {
      'name': 'Maria Santos',
      'paid_orders': 18,
      'unpaid_orders': 5,
      'total_sales': 14200.00,
    },
    {
      'name': 'Ahmed Ali',
      'paid_orders': 32,
      'unpaid_orders': 2,
      'total_sales': 24150.00,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WAITERS PERFORMANCE REPORT',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.offWhite,
            )),
        backgroundColor: AppColors.deepBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll<Color>(
                      AppColors.deepBlue.withOpacity(0.05),
                    ),
                    columns: const [
                      DataColumn(
                          label: Text('WAITER',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('PAID ORDERS',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('UNPAID ORDERS',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('NUMBER OF ORDERS',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('TOTAL SALES',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('VIEW',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: waitersData.map((waiter) {
                      return DataRow(
                        cells: [
                          DataCell(Text(waiter['name'])),
                          DataCell(
                            Text(
                              waiter['paid_orders'].toString(),
                              style: TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              waiter['unpaid_orders'].toString(),
                              style: TextStyle(
                                color: AppColors.warmOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '12',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '₱${waiter['total_sales'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              color: AppColors.deepBlue,
                              onPressed: () {
                                // View detailed report
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text('PRINT REPORT'),
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    side: BorderSide(color: AppColors.deepBlue),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('EXPORT'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
