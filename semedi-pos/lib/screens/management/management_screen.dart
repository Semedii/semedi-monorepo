// management_screen.dart
import 'package:flutter/material.dart';
import 'package:semedi_pos/screens/management/menu_management_tab.dart';
import 'package:semedi_pos/screens/management/table_management_tab.dart';
import 'package:semedi_pos/screens/management/waiter_management_tab.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MANAGEMENT'),
          backgroundColor: AppColors.deepBlue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.restaurant), text: 'Menu'),
              Tab(icon: Icon(Icons.table_restaurant), text: 'Tables'),
              Tab(icon: Icon(Icons.person), text: 'Waiters'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            MenuManagementTab(),
            TableManagementTab(),
            WaiterManagementTab(),
          ],
        ),
      ),
    );
  }
}
