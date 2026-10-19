import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/cubit/SalesHistory/sales_history_cubit.dart';
import 'package:semedi_pos/models/daily_summary.dart';
import 'package:semedi_pos/screens/sales_history_data.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class SalesHistoryListScreen extends StatelessWidget {
  SalesHistoryListScreen({super.key});
  final OrderService _orderService = OrderService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocProvider(
        create: (context) => _createCubit()..initPage(),
        child: BlocBuilder<SalesHistoryCubit, SalesHistoryState>(
          builder: _mapStateToWidget,
        ),
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, SalesHistoryState state) {
    if (state is SalesHistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is SalesHistoryLoaded) {
      return _buildPageBody(context, state);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPageBody(BuildContext context, SalesHistoryLoaded state) {
    return Column(
      children: [
        _buildFilterBar(context, state),
        Expanded(
          child: state.filteredList.isEmpty
              ? _buildEmptyState(state.selectedMonth)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.filteredList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _buildDayCard(context, state.filteredList[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context, SalesHistoryLoaded state) {
    final cubit = BlocProvider.of<SalesHistoryCubit>(context);
    final months = _extractMonths(state.dailySummaryList);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filter by month',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const Spacer(),
              _buildSortDropdown(context, cubit, state),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildAllChip(context, cubit, state),
                const SizedBox(width: 6),
                ...months.map(
                  (month) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildMonthChip(context, cubit, state, month),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllChip(
    BuildContext context,
    SalesHistoryCubit cubit,
    SalesHistoryLoaded state,
  ) {
    final isSelected = state.selectedMonth == null;
    return FilterChip(
      label: const Text('All'),
      selected: isSelected,
      onSelected: (_) => cubit.onClearFilter(),
      selectedColor: AppColors.deepBlue.withOpacity(0.15),
      checkmarkColor: AppColors.deepBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.deepBlue : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildMonthChip(
    BuildContext context,
    SalesHistoryCubit cubit,
    SalesHistoryLoaded state,
    String month,
  ) {
    final isSelected = state.selectedMonth == month;
    return FilterChip(
      label: Text(month),
      selected: isSelected,
      onSelected: (_) => isSelected
          ? cubit.onClearFilter()
          : cubit.onFilterByMonth(month),
      selectedColor: AppColors.deepBlue.withOpacity(0.15),
      checkmarkColor: AppColors.deepBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.deepBlue : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSortDropdown(
    BuildContext context,
    SalesHistoryCubit cubit,
    SalesHistoryLoaded state,
  ) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<SalesSort>(
        value: state.sort,
        isDense: true,
        icon: const Icon(Icons.sort, size: 18),
        items: const [
          DropdownMenuItem(
              value: SalesSort.dateDesc, child: Text('Date ↓')),
          DropdownMenuItem(
              value: SalesSort.dateAsc, child: Text('Date ↑')),
          DropdownMenuItem(
              value: SalesSort.revenueDesc, child: Text('Revenue ↓')),
          DropdownMenuItem(
              value: SalesSort.revenueAsc, child: Text('Revenue ↑')),
        ],
        onChanged: (sort) {
          if (sort != null) cubit.onSortChanged(sort);
        },
      ),
    );
  }

  Widget _buildEmptyState(String? month) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            month != null
                ? 'No records for $month'
                : 'No sales history yet',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  List<String> _extractMonths(List<DailySummary> summaries) {
    final months = <String>{};
    for (final s in summaries) {
      final parts = s.date.split('/');
      if (parts.length >= 2) {
        months.add('${parts[1]}/${parts.last}');
      }
    }
    final sorted = months.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: IconThemeData(color: AppColors.offWhite),
      backgroundColor: AppColors.deepBlue,
      title: Text(
        "Sales History",
        style: TextStyle(
          color: AppColors.offWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Card _buildDayCard(BuildContext context, DailySummary dailySummary) {
    return Card(
      elevation: 0,
      color: AppColors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SalesHistoryData(dailySummary)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayData(dailySummary),
              _buildTrailingIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildDayData(DailySummary dailySummary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDate(dailySummary),
        const SizedBox(height: 4),
        _buildOrderData(dailySummary),
      ],
    );
  }

  Text _buildDate(DailySummary dailySummary) {
    return Text(
      dailySummary.date,
      style: TextStyle(
        color: AppColors.offWhite,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Text _buildOrderData(DailySummary dailySummary) {
    return Text(
      '${dailySummary.totalOrders} Orders • \$${dailySummary.totalSales} ',
      style: TextStyle(
        color: AppColors.offWhite.withOpacity(0.8),
      ),
    );
  }

  Icon _buildTrailingIcon() {
    return Icon(
      Icons.chevron_right,
      color: AppColors.offWhite.withOpacity(0.6),
    );
  }

  SalesHistoryCubit _createCubit() {
    return SalesHistoryCubit(_orderService);
  }
}
