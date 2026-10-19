import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/cubit/shift/shift_cubit.dart';
import 'package:semedi_pos/models/shift.dart';
import 'package:semedi_pos/service/shift_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class ShiftScreen extends StatelessWidget {
  ShiftScreen({super.key});

  final TextEditingController cashierController = TextEditingController();
  final TextEditingController openingFloatController = TextEditingController();
  final TextEditingController closingFloatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShiftCubit(ShiftService())..initPage(),
      child: BlocConsumer<ShiftCubit, ShiftState>(
        listener: (context, state) {
          if (state is ShiftFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.softRed,
              ),
            );
          }
        },
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, ShiftState state) {
    if (state is ShiftLoaded) {
      return _buildScreenBody(context, state);
    }
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _buildScreenBody(BuildContext context, ShiftLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            state.currentShift == null
                ? _buildOpenShiftCard(context)
                : _buildActiveShift(context, state.currentShift!),
            const SizedBox(height: 32),
            _buildShiftHistoryHeader(),
            const SizedBox(height: 12),
            _buildShiftHistory(state.shiftHistory),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('SHIFT MANAGEMENT'),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildOpenShiftCard(BuildContext context) {
    final cubit = BlocProvider.of<ShiftCubit>(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No Active Shift',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 20),
            TxtFormField(
              controller: cashierController,
              labelText: 'Cashier Name',
            ),
            const SizedBox(height: 16),
            TxtFormField(
              controller: openingFloatController,
              labelText: 'Opening Float (\$)',
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'OPEN SHIFT',
              onPressed: () {
                cubit.onOpenShift(
                  cashierController.text,
                  double.tryParse(openingFloatController.text) ?? 0,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveShift(BuildContext context, Shift shift) {
    final cubit = BlocProvider.of<ShiftCubit>(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Shift Open',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildShiftInfoRow('Cashier', shift.cashierName),
            _buildShiftInfoRow('Opened At', _formatTime(shift.openedAt)),
            _buildShiftInfoRow(
                'Opening Float', '\$${shift.openingFloat.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            TxtFormField(
              controller: closingFloatController,
              labelText: 'Closing Float (\$)',
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'CLOSE SHIFT',
              color: AppColors.softRed,
              onPressed: () {
                cubit.onCloseShift(
                  double.tryParse(closingFloatController.text) ?? 0,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Row _buildShiftInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Text _buildShiftHistoryHeader() {
    return Text(
      'Recent Shifts',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
      ),
    );
  }

  Widget _buildShiftHistory(List<Shift> shifts) {
    if (shifts.isEmpty) {
      return Text(
        'No shift history yet.',
        style: TextStyle(color: Colors.grey.shade500),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shifts.length,
      itemBuilder: (context, index) => _buildShiftHistoryTile(shifts[index]),
    );
  }

  Card _buildShiftHistoryTile(Shift shift) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.access_time,
          color: shift.isOpen ? AppColors.green : Colors.grey,
        ),
        title: Text(shift.cashierName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${_formatTime(shift.openedAt)} → ${shift.closedAt != null ? _formatTime(shift.closedAt!) : 'Open'}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${shift.openingFloat.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            if (shift.closingFloat != null)
              Text('\$${shift.closingFloat!.toStringAsFixed(2)}',
                  style:
                      TextStyle(color: AppColors.deepBlue, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.day}/${dt.month}';
  }
}
