import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/cubit/settings/settings_cubit.dart';
import 'package:semedi_pos/utils/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit()..initPage(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(BuildContext context, SettingsState state) {
    if (state is SettingsLoaded) {
      return _buildScreenBody(context, state);
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Scaffold _buildScreenBody(BuildContext context, SettingsLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Restaurant', [
            _buildInfoTile('Name', state.restaurantName.isEmpty ? '—' : state.restaurantName),
            _buildInfoTile('App Version', state.appVersion),
          ]),
          _buildSection('Printer', [
            _buildSwitchTile(
              'Thermal Printer',
              state.thermalPrinterEnabled,
              (v) => context.read<SettingsCubit>().onTogglePrinter(v),
            ),
          ]),
          _buildSection('Notifications', [
            _buildSwitchTile(
              'Sound Alerts',
              state.soundNotificationsEnabled,
              (v) => context.read<SettingsCubit>().onToggleSound(v),
            ),
            _buildSwitchTile(
              'Auto Refresh',
              state.autoRefreshEnabled,
              (v) => context.read<SettingsCubit>().onToggleAutoRefresh(v),
            ),
          ]),
          _buildSection('Display', [
            _buildDisplayTile(),
          ]),
          _buildSection('About', [
            _buildInfoTile('Version', '1.0.0+1'),
            _buildInfoTile('Framework', 'Built with Flutter'),
            _buildInfoTile('Backend', 'Supabase + Firebase'),
          ]),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('SETTINGS'),
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Column _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue,
            ),
          ),
        ),
        const Divider(height: 1),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  ListTile _buildInfoTile(String label, String value) {
    return ListTile(
      leading: Icon(Icons.info_outline, color: AppColors.deepBlue),
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildSwitchTile(
      String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      activeColor: AppColors.deepBlue,
      onChanged: onChanged,
    );
  }

  ListTile _buildDisplayTile() {
    return ListTile(
      leading: Icon(Icons.brightness_6, color: AppColors.deepBlue),
      title: const Text('Brightness'),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
    );
  }
}
