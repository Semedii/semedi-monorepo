import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_kitchen/cubit/menu/menu_cubit.dart';
import 'package:semedi_kitchen/models/menu.dart';
import 'package:semedi_kitchen/services/menu_service.dart';
import 'package:semedi_kitchen/utils/app_colors.dart';

class MenuManagementScreen extends StatelessWidget {
  MenuManagementScreen({super.key});
  final MenuService _menuService = MenuService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocProvider(
        create: (context) => MenuCubit(_menuService)..initPage(),
        child: BlocBuilder<MenuCubit, MenuState>(
          builder: _mapStateToWidget,
        ),
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, MenuState state) {
    if (state is MenuLoaded) {
      return _buildMenuList(context, state.menuList);
    }
    return const Center(child: CircularProgressIndicator());
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Manage Menu'),
      centerTitle: true,
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildMenuList(BuildContext context, List<MenuItem> menuList) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: menuList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _buildMenuItemCard(context, menuList[index]),
    );
  }

  Card _buildMenuItemCard(BuildContext context, MenuItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildItemInfo(item),
            const Spacer(),
            _buildAvailabilitySwitch(context, item),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInfo(MenuItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${item.price.toStringAsFixed(2)}',
          style: TextStyle(
            color: AppColors.darkGrey.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySwitch(BuildContext context, MenuItem item) {
    final cubit = BlocProvider.of<MenuCubit>(context);
    return Switch(
      value: item.isAvailable,
      activeColor: AppColors.green,
      inactiveTrackColor: AppColors.softRed.withOpacity(0.5),
      onChanged: (value) => cubit.onMenuToggle(item, value),
    );
  }
}
