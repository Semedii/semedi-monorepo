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
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.dailySummaryList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final dailySummary = state.dailySummaryList[index];
        return _buildDayCard(context, dailySummary);
      },
    );
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
