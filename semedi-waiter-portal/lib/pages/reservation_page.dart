import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/cubits/reservation/reservation_cubit.dart';
import 'package:semedi/models/reservation.dart';
import 'package:semedi/services/reservation_service.dart';
import 'package:semedi/utils/app_colors.dart';

class ReservationPage extends StatelessWidget {
  ReservationPage({super.key});

  final ReservationService _reservationService = ReservationService();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ReservationCubit(_reservationService)..initPage(),
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
        child: state.reservations.isEmpty
            ? _buildEmptyState()
            : _buildReservationList(context, state),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("TODAY'S RESERVATIONS"),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Center _buildEmptyState() {
    return Center(
      child: Text(
        'No reservations for today',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
      ),
    );
  }

  ListView _buildReservationList(
      BuildContext context, ReservationLoaded state) {
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
        trailing: _buildTrailingActions(reservation, cubit),
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

  Widget _buildTrailingActions(
      Reservation reservation, ReservationCubit cubit) {
    if (reservation.status != 'upcoming') {
      return Text(
        reservation.status.toUpperCase(),
        style: TextStyle(
          color:
              reservation.status == 'seated' ? AppColors.deepBlue : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          icon: const Icon(Icons.chair, size: 16),
          label: const Text('SEAT'),
          onPressed: () => cubit.onSeatGuest(reservation),
        ),
        const SizedBox(width: 6),
        IconButton(
          icon: Icon(Icons.cancel, color: AppColors.softRed),
          onPressed: () => cubit.onCancelReservation(reservation),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
