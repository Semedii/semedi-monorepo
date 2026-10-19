// management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/cubit/management/management_cubit.dart';
import 'package:semedi_pos/screens/management/menu_management_tab.dart';
import 'package:semedi_pos/screens/management/discount_management_tab.dart';
import 'package:semedi_pos/screens/management/modifier_management_tab.dart';
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
      length: 5,
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
              Tab(icon: Icon(Icons.tune), text: 'Modifiers'),
              Tab(icon: Icon(Icons.local_offer), text: 'Discounts'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: BlocProvider(
          create: (context) => ManagementCubit(_managementService)..initPage(),
          child: BlocConsumer<ManagementCubit, ManagementState>(
              listener: (context, state) {
            if (state is ManagementFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Failed ${state.message}"),
                  backgroundColor: AppColors.softRed,
                ),
              );
            }
          }, builder: (context, state) {
            final cubit = BlocProvider.of<ManagementCubit>(context);
            if (state is ManagementLoaded) {
              return TabBarView(
                children: [
                  MenuManagementTab(
                    menuItems: state.menuList,
                    onDelete: cubit.onDeleteMenu,
                    onAdd: cubit.onAddMenu,
                    onEdit: cubit.onEditMenu,
                  ),
                  TableManagementTab(
                    totalTableNumber: state.totalTableNumber,
                    onAdd: cubit.onAddTable,
                    onRemove: cubit.onRemoveTable,
                  ),
                  WaiterManagementTab(waiterList: state.waiterList),
                  ModifierManagementTab(
                    modifiers: state.modifierList,
                    onDelete: cubit.onDeleteModifier,
                    onAdd: cubit.onAddModifier,
                    onEdit: cubit.onEditModifier,
                  ),
                  DiscountManagementTab(
                    discounts: state.discountList,
                    onDelete: cubit.onDeleteDiscount,
                    onAdd: cubit.onAddDiscount,
                    onEdit: cubit.onEditDiscount,
                  ),
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
