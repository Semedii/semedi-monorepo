import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_kitchen/cubit/settings/settings_cubit.dart';
import 'package:semedi_kitchen/utils/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => KitchenSettingsCubit()..initPage(),
      child: BlocBuilder<KitchenSettingsCubit, KitchenSettingsState>(
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(
      BuildContext context, KitchenSettingsState state) {
    if (state is KitchenSettingsLoaded) {
      return _buildScreenBody(context, state);
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Scaffold _buildScreenBody(
      BuildContext context, KitchenSettingsLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Display', [
            _buildSwitchTile(
              'Show Completed Orders',
              state.displayCompletedOrders,
              (v) =>
                  context.read<KitchenSettingsCubit>().onToggleDisplayCompleted(v),
            ),
          ]),
          _buildSection('Alerts', [
            _buildSwitchTile(
              'Sound Alerts',
              state.soundAlerts,
              (v) =>
                  context.read<KitchenSettingsCubit>().onToggleSoundAlerts(v),
            ),
          ]),
          _buildSection('Auto-Complete', [
            _buildAutoMarkTile(context, state),
          ]),
          _buildSection('About', [
            _buildInfoTile('Version', '1.0.0+1'),
            _buildInfoTile('App', 'Semedi Kitchen Display'),
            _buildInfoTile('Framework', 'Built with Flutter'),
          ]),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('KITCHEN SETTINGS'),
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

  Widget _buildSwitchTile(
      String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      activeColor: AppColors.deepBlue,
      onChanged: onChanged,
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

  Widget _buildAutoMarkTile(
      BuildContext context, KitchenSettingsLoaded state) {
    final options = [10, 15, 20, 30, 45, 60];
    return ListTile(
      leading: Icon(Icons.timer, color: AppColors.deepBlue),
      title: const Text('Auto-mark done after'),
      trailing: DropdownButton<int>(
        value: state.autoMarkDoneAfterMinutes,
        underline: const SizedBox(),
        items: options
            .map((m) => DropdownMenuItem(
                  value: m,
                  child: Text('$m min'),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) {
            context.read<KitchenSettingsCubit>().onSetAutoMarkMinutes(v);
          }
        },
      ),
    );
  }
}
