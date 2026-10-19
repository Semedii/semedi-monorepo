import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/components/app_button.dart';
import 'package:semedi_pos/components/txt_form_field.dart';
import 'package:semedi_pos/cubit/reservation/reservation_cubit.dart';
import 'package:semedi_pos/models/reservation.dart';
import 'package:semedi_pos/service/reservation_service.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class ReservationScreen extends StatelessWidget {
  ReservationScreen({super.key});

  final ReservationService _reservationService = ReservationService();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReservationCubit(_reservationService)..initPage(),
      child: BlocConsumer<ReservationCubit, ReservationState>(
        listener: (context, state) {
          if (state is ReservationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: AppColors.softRed,
              ),
            );
          }
        },
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, ReservationState state) {
    if (state is ReservationLoaded) {
      return _buildBody(context, state);
    }
    return Scaffold(
      appBar: _buildAppBar(),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _buildBody(BuildContext context, ReservationLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAddButton(context),
            const SizedBox(height: 16),
            Expanded(child: _buildReservationList(context, state)),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('RESERVATIONS'),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Align _buildAddButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AppButton(
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.add, color: Colors.white),
            Text('ADD RESERVATION', style: TextStyle(color: Colors.white)),
          ],
        ),
        onPressed: () => _buildAddDialog(context),
      ),
    );
  }

  ListView _buildReservationList(
      BuildContext context, ReservationLoaded state) {
    if (state.reservations.isEmpty) {
      return ListView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Text(
                'No reservations today',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      itemCount: state.reservations.length,
      itemBuilder: (context, index) =>
          _buildReservationCard(context, state.reservations[index]),
    );
  }

  Card _buildReservationCard(BuildContext context, Reservation reservation) {
    final cubit = BlocProvider.of<ReservationCubit>(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: _buildStatusAvatar(reservation),
        title: Text(
          '${reservation.guestName}   Table ${reservation.tableNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: _buildSubtitle(reservation),
        trailing: _buildTrailingActions(context, reservation, cubit),
      ),
    );
  }

  CircleAvatar _buildStatusAvatar(Reservation reservation) {
    Color color;
    if (reservation.status == 'seated') {
      color = AppColors.deepBlue;
    } else if (reservation.status == 'cancelled') {
      color = Colors.grey;
    } else {
      color = AppColors.green;
    }
    return CircleAvatar(
      backgroundColor: color,
      child: Text(
        reservation.guestCount.toString(),
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Column _buildSubtitle(Reservation reservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_formatTime(reservation.reservedAt)} · ${reservation.guestCount} guests',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        if (reservation.note != null && reservation.note!.isNotEmpty)
          Text(
            reservation.note!,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
      ],
    );
  }

  Row _buildTrailingActions(
    BuildContext context,
    Reservation reservation,
    ReservationCubit cubit,
  ) {
    if (reservation.status != 'upcoming') {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Text(
          reservation.status.toUpperCase(),
          style: TextStyle(
            color: reservation.status == 'seated'
                ? AppColors.deepBlue
                : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ]);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.chair, color: AppColors.green),
          tooltip: 'Seat Guest',
          onPressed: () => cubit.onSeatGuest(reservation),
        ),
        IconButton(
          icon: Icon(Icons.cancel, color: AppColors.softRed),
          tooltip: 'Cancel',
          onPressed: () => cubit.onCancelReservation(reservation),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _buildAddDialog(BuildContext context) {
    final cubit = BlocProvider.of<ReservationCubit>(context);
    final guestNameController = TextEditingController();
    final phoneController = TextEditingController();
    final guestCountController = TextEditingController();
    final tableNumberController = TextEditingController();
    final noteController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.offWhite,
        title: const Text('Add Reservation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TxtFormField(
                controller: guestNameController,
                labelText: 'Guest Name',
              ),
              const SizedBox(height: 12),
              TxtFormField(
                controller: phoneController,
                labelText: 'Phone',
              ),
              const SizedBox(height: 12),
              TxtFormField(
                controller: guestCountController,
                labelText: 'Guest Count',
              ),
              const SizedBox(height: 12),
              TxtFormField(
                controller: tableNumberController,
                labelText: 'Table Number',
              ),
              const SizedBox(height: 12),
              TxtFormField(
                controller: dateController,
                labelText: 'Date & Time (YYYY-MM-DD HH:mm)',
              ),
              const SizedBox(height: 12),
              TxtFormField(
                controller: noteController,
                labelText: 'Note (optional)',
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            isOutlined: true,
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          AppButton(
            text: 'Add',
            onPressed: () {
              try {
                final dateTime = DateTime.parse(
                    dateController.text.trim().replaceAll(' ', 'T'));
                cubit.onAddReservation(
                  guestName: guestNameController.text.trim(),
                  phone: phoneController.text.trim(),
                  guestCount: int.parse(guestCountController.text.trim()),
                  tableNumber: int.parse(tableNumberController.text.trim()),
                  reservedAt: dateTime,
                  note: noteController.text.trim().isEmpty
                      ? null
                      : noteController.text.trim(),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please check your input'),
                    backgroundColor: AppColors.softRed,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
