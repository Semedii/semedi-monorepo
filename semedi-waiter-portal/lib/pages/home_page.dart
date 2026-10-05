import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../components/app_button.dart';
import '../cubits/home/home_cubit.dart';
import '../main.dart';
import '../models/dining_tables.dart';
import '../models/area_zone.dart';
import '../services/auth_service.dart';
import '../services/service_locator.dart';
import '../utils/app_colors.dart';
import 'change_password_page.dart';
import 'order_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AuthService authService = getIt<AuthService>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _createHomeCubit(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state is HomeError) {
      return Scaffold(body: Center(child: Text(state.message)));
    }

    if (state is HomeLoaded) {
      return _buildPageBody(context, state);
    }

    return Container();
  }

  Widget _buildPageBody(BuildContext context, HomeLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(context, state),
      body: _buildZonesView(context, state),
      floatingActionButton: _buildNewOrderFAB(context, state),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  AppBar _buildAppBar(BuildContext context, HomeLoaded state) {
    return AppBar(
      backgroundColor: AppColors.offWhite,
      elevation: 0,
      title: _buildAppBarTitle(state),
      centerTitle: false,
      actions: [
        _buildSettings(context),
      ],
    );
  }

  Widget _buildSettings(BuildContext context) {
    return IconButton(
      onPressed: () => _showLogoutConfirmation(context),
      icon: const Icon(Icons.settings_outlined),
      tooltip: 'Settings',
    );
  }

  Text _buildAppBarTitle(HomeLoaded state) {
    return Text(
      state.restaurantName ?? '',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildZonesView(BuildContext context, HomeLoaded state) {
    final zones = state.diningTables;

    if (zones.isEmpty) {
      return const Center(
        child: Text('No tables available'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().fetchTables(),
      color: AppColors.deepBlue,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: zones.length,
        itemBuilder: (context, index) {
          final zone = zones[index];
          return _buildZoneSection(context, state, zone);
        },
      ),
    );
  }

  Widget _buildZoneSection(
      BuildContext context, HomeLoaded state, AreaZone zone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.deepBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                zone.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${zone.tables.length} tables',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildTablesGrid(context, zone.tables),
        if (zone != state.diningTables.last)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(height: 1),
          ),
      ],
    );
  }

  Widget _buildTablesGrid(BuildContext context, List<DiningTables> tables) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        return _buildTableCard(context, tables[index]);
      },
    );
  }

  Widget _buildTableCard(BuildContext context, DiningTables table) {
    final status = TableStatus.fromString(table.status ?? 'vacant');

    return GestureDetector(
      onTap: () => _navigateToOrderPage(context, table),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Table Number with Status Indicator
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: status.backgroundColor,
                    border: Border.all(
                      color: status.borderColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${table.tableNumber}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: status.textColor,
                      ),
                    ),
                  ),
                ),
                // Status badge
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: status.badgeColor, width: 2),
                    ),
                    child: Icon(
                      status.icon,
                      size: 14,
                      color: status.badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Capacity
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${table.capacity}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewOrderFAB(BuildContext context, HomeLoaded state) {
    return FloatingActionButton.extended(
      onPressed: () => _showTableSelection(context),
      backgroundColor: AppColors.deepBlue,
      elevation: 4,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'New Order',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showTableSelection(BuildContext context) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: BlocBuilder<HomeCubit, HomeState>(
            bloc: cubit,
            builder: (ctx, state) {
              if (state is! HomeLoaded) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildTableSelectionContent(ctx, cubit, state);
            },
          ),
        );
      },
    );
  }

  Widget _buildTableSelectionContent(
      BuildContext context, HomeCubit cubit, HomeLoaded state) {
    final zones = state.diningTables;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Table',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        // Legend
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: TableStatus.values.map((status) {
              return Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: status.backgroundColor,
                      border: Border.all(color: status.borderColor),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        // Zones List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: zones.length,
            itemBuilder: (ctx, index) {
              final zone = zones[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.85,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: zone.tables.length,
                    itemBuilder: (ctx, tableIndex) {
                      return _buildTableSelectionCard(
                          context, cubit, zone.tables[tableIndex]);
                    },
                  ),
                  if (index < zones.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableSelectionCard(
      BuildContext context, HomeCubit cubit, DiningTables table) {
    final status = TableStatus.fromString(table.status ?? 'vacant');
    final isAvailable = table.status == 'available' || table.status == 'vacant';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isAvailable ? () => _navigateToOrderPage(context, table) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isAvailable ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAvailable ? status.borderColor : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status.backgroundColor
                      .withValues(alpha: isAvailable ? 1 : 0.5),
                ),
                child: Center(
                  child: Text(
                    '${table.tableNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? status.textColor : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cap: ${table.capacity}',
                style: TextStyle(
                  fontSize: 10,
                  color:
                      isAvailable ? Colors.grey.shade700 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToOrderPage(BuildContext context, DiningTables table) {
    Navigator.pop(context); // Close bottom sheet if open
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(table: table),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildLogoutConfirmationContent(context),
    );
  }

  Padding _buildLogoutConfirmationContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildChangePassword(context),
          const SizedBox(height: 16),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildChangePassword(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.deepBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.lock_outline, color: AppColors.deepBlue),
      ),
      title: const Text(
        'Change Password',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _navigateToChangePassword(context),
    );
  }

  void _navigateToChangePassword(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordPage(),
      ),
    );
  }

  AppButton _buildLogoutButton(BuildContext context) {
    return AppButton(
      text: "Logout",
      onPressed: () => _performLogout(context),
    );
  }

  void _performLogout(BuildContext context) {
    getIt<AuthService>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MyApp()),
      (route) => false,
    );
  }

  HomeCubit _createHomeCubit() {
    return HomeCubit(getIt(), getIt(), getIt())..fetchTables();
  }
}

// Table status enum for better organization
enum TableStatus {
  vacant('vacant', Icons.check_circle, AppColors.green, Colors.white,
      AppColors.green, Colors.green),
  occupied('occupied', Icons.restaurant, AppColors.warmOrange, Colors.white,
      AppColors.warmOrange, AppColors.warmOrange),
  reserved('reserved', Icons.event_available, AppColors.deepBlue, Colors.white,
      AppColors.deepBlue, AppColors.deepBlue);

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color badgeColor;

  const TableStatus(
    this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.badgeColor,
  );

  static TableStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'occupied':
        return TableStatus.occupied;
      case 'reserved':
        return TableStatus.reserved;
      case 'vacant':
      case 'available':
      default:
        return TableStatus.vacant;
    }
  }
}
