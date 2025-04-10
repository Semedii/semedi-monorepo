// management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/cubit/management/management_cubit.dart';
import 'package:semedi_pos/screens/management/menu_management_tab.dart';
import 'package:semedi_pos/screens/management/table_management_tab.dart';
import 'package:semedi_pos/screens/management/waiter_management_tab.dart';
import 'package:semedi_pos/service/management_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class ManagementScreen extends StatelessWidget {
  ManagementScreen({super.key});

  final ManagementService _managementService = ManagementService();

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
        body: BlocProvider(
          create: (context) => ManagementCubit(_managementService)..initPage(),
          child: BlocBuilder<ManagementCubit, ManagementState>(
              builder: (context, state) {
            final cubit = BlocProvider.of<ManagementCubit>(context);
            if (state is ManagementLoaded) {
              return TabBarView(
                children: [
                  MenuManagementTab(
                    menuItems: state.menuList,
                    onDelete: (menu) => cubit.onDeleteMenu(menu),
                    onEdit: (newMenu, oldMenu) => cubit.onEditMenu(
                      newMenu: newMenu,
                      oldMenu: oldMenu,
                    ),
                  ),
                  TableManagementTab(totalTableNumber: state.totalTableNumber),
                  WaiterManagementTab(waiterList: state.waiterList),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          }),
        ),
      ),
    );
  }
}
