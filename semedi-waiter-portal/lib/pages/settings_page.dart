import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_waiter_portal/cubits/settings/settings_cubit.dart';
import 'package:semedi_waiter_portal/utils/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WaiterSettingsCubit()..initPage(),
      child: BlocBuilder<WaiterSettingsCubit, WaiterSettingsState>(
        builder: _mapStateToWidget,
      ),
    );
  }

  Widget _mapStateToWidget(
      BuildContext context, WaiterSettingsState state) {
    if (state is WaiterSettingsLoaded) {
      return _buildScreenBody(context, state);
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Scaffold _buildScreenBody(
      BuildContext context, WaiterSettingsLoaded state) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Display', [
            _buildTableViewSelector(context, state),
          ]),
          _buildSection('Notifications', [
            _buildSwitchTile(
              'Vibration',
              state.vibrationEnabled,
              (v) =>
                  context.read<WaiterSettingsCubit>().onToggleVibration(v),
            ),
          ]),
          _buildSection('Screen', [
            _buildSwitchTile(
              'Keep Screen Awake',
              state.keepScreenOn,
              (v) => context.read<WaiterSettingsCubit>().onToggleScreen(v),
            ),
          ]),
          _buildSection('About', [
            _buildInfoTile('Version', '1.0.0+1'),
            _buildInfoTile('App', 'Semedi Waiter Portal'),
            _buildInfoTile('Framework', 'Built with Flutter'),
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

  Widget _buildTableViewSelector(
      BuildContext context, WaiterSettingsLoaded state) {
    return ListTile(
      leading: Icon(Icons.table_chart, color: AppColors.deepBlue),
      title: const Text('Default Table View'),
      trailing: DropdownButton<String>(
        value: state.defaultTableView,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'grid', child: Text('Grid')),
          DropdownMenuItem(value: 'list', child: Text('List')),
        ],
        onChanged: (v) {
          if (v != null) {
            context.read<WaiterSettingsCubit>().onSetTableView(v);
          }
        },
      ),
    );
  }
}
