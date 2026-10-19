import 'package:flutter/material.dart';
import 'package:semedi/models/area_zone.dart';
import 'package:semedi/models/dining_tables.dart';
import 'package:semedi/utils/app_colors.dart';

class TableStatusPage extends StatelessWidget {
  const TableStatusPage({required this.zones, super.key});

  final List<AreaZone> zones;

  List<DiningTables> get _allTables =>
      zones.expand((z) => z.tables).toList();

  int get _vacantCount => _allTables
      .where((t) =>
          t.status == null ||
          t.status == 'vacant' ||
          t.status == 'available')
      .length;

  int get _occupiedCount =>
      _allTables.where((t) => t.status == 'occupied').length;

  int get _reservedCount =>
      _allTables.where((t) => t.status == 'reserved').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusSummary(),
            const SizedBox(height: 24),
            ...zones.map((zone) => _buildZoneSection(zone)),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Table Overview',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: AppColors.offWhite,
      elevation: 0,
      foregroundColor: Colors.black87,
    );
  }

  Widget _buildStatusSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            label: 'Vacant',
            count: _vacantCount,
            color: AppColors.green,
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            label: 'Occupied',
            count: _occupiedCount,
            color: AppColors.warmOrange,
            icon: Icons.restaurant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            label: 'Reserved',
            count: _reservedCount,
            color: AppColors.deepBlue,
            icon: Icons.event_available,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneSection(AreaZone zone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildZoneHeader(zone),
        const SizedBox(height: 12),
        _buildZoneGrid(zone.tables),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildZoneHeader(AreaZone zone) {
    final occupied =
        zone.tables.where((t) => t.status == 'occupied').length;
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.deepBlue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          zone.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$occupied/${zone.tables.length} occupied',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZoneGrid(List<DiningTables> tables) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.95,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) => _buildTableTile(tables[index]),
    );
  }

  Widget _buildTableTile(DiningTables table) {
    final status = _resolveStatus(table.status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: status.color.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${table.tableNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: status.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 10,
              color: status.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (table.capacity != null) ...[
            const SizedBox(height: 2),
            Text(
              '${table.capacity} seats',
              style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
            ),
          ],
        ],
      ),
    );
  }

  _TableStatus _resolveStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'occupied':
        return _TableStatus(AppColors.warmOrange, 'Occupied');
      case 'reserved':
        return _TableStatus(AppColors.deepBlue, 'Reserved');
      default:
        return _TableStatus(AppColors.green, 'Vacant');
    }
  }
}

class _TableStatus {
  final Color color;
  final String label;

  const _TableStatus(this.color, this.label);
}
