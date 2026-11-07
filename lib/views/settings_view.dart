import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/auth/auth_cubit.dart';
import 'package:flutter_water_reminder_app/blocs/auth/auth_state.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_event.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_state.dart';
import 'package:flutter_water_reminder_app/blocs/settings/settings_cubit.dart';
import 'package:flutter_water_reminder_app/blocs/settings/settings_state.dart';
import 'package:flutter_water_reminder_app/core/utils/water_formatter.dart';
import 'package:flutter_water_reminder_app/models/app_settings.dart';
import 'package:flutter_water_reminder_app/models/water/water_reminder.dart';
import 'package:flutter_water_reminder_app/widgets/edit_goal_dialog.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.tertiaryContainer, colorScheme.surface],
          ),
        ),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                if (state.status == SettingsStatus.loading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
                if (state.status == SettingsStatus.failure) ...[
                  _SettingsErrorBanner(message: state.errorMessage),
                  const SizedBox(height: 16),
                ],
                _SettingsSection(
                  title: 'Account',
                  icon: Icons.account_circle_outlined,
                  children: [
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, authState) {
                        return _AccountSection(authState: authState);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsSection(
                  title: 'Appearance',
                  icon: Icons.palette_outlined,
                  children: [
                    _ThemeSelector(settings: state.settings),
                    const Divider(height: 24),
                    _LanguageSelector(settings: state.settings),
                    const Divider(height: 24),
                    _UnitSelector(settings: state.settings),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsSection(
                  title: 'Notifications',
                  icon: Icons.notifications_outlined,
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Notifications'),
                      subtitle: const Text('Master switch for all reminders'),
                      value: state.settings.notificationsEnabled,
                      onChanged: (value) {
                        context.read<SettingsCubit>().setNotificationsEnabled(
                          value,
                        );
                      },
                    ),
                    const Divider(height: 24),
                    _ReminderList(
                      reminders: state.reminders,
                      enabled: state.settings.notificationsEnabled,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => _addReminder(context),
                        icon: const Icon(Icons.add_alarm),
                        label: const Text('Add reminder'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsSection(
                  title: 'Goal',
                  icon: Icons.flag_outlined,
                  children: [
                    BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, homeState) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.water_drop_outlined),
                          title: const Text('Daily goal'),
                          subtitle: Text(
                            formatWaterAmount(
                              homeState.goalMl,
                              state.settings.waterUnit,
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: () async {
                              final goal = await showEditGoalDialog(
                                context,
                                homeState.goalMl,
                              );

                              if (goal != null && context.mounted) {
                                context.read<HomeBloc>().add(
                                  HomeGoalUpdated(goal),
                                );
                              }
                            },
                            child: const Text('Edit'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _SettingsSection(
                  title: 'About',
                  icon: Icons.info_outline,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Water Reminder'),
                      subtitle: Text('Version 1.0.0'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _addReminder(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null || !context.mounted) return;

    await context.read<SettingsCubit>().saveReminder(
      WaterReminder(
        hour: time.hour,
        minute: time.minute,
        mode: ReminderMode.sound,
        soundName: 'default',
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = authState.user;

    if (authState.isGoogleConnected && user != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage: user.photoURL == null
                  ? null
                  : NetworkImage(user.photoURL!),
              child: user.photoURL == null
                  ? const Icon(Icons.person_outline)
                  : null,
            ),
            title: Text(user.displayName ?? 'Google account'),
            subtitle: Text(user.email ?? 'Connected'),
            trailing: Icon(Icons.verified, color: colorScheme.primary),
          ),
          if (authState.successMessage != null)
            Text(
              authState.successMessage!,
              style: TextStyle(color: colorScheme.primary),
            ),
          if (authState.errorMessage != null)
            Text(
              authState.errorMessage!,
              style: TextStyle(color: colorScheme.error),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.person_outline),
          title: Text('Guest'),
          subtitle: Text(
            'Your data is stored anonymously until you connect Google.',
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: authState.isLoading
                ? null
                : () => context.read<AuthCubit>().connectGoogle(),
            icon: authState.isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.login),
            label: Text(
              authState.isLoading ? 'Connecting...' : 'Connect Google',
            ),
          ),
        ),
        if (authState.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            authState.errorMessage!,
            style: TextStyle(color: colorScheme.error),
          ),
        ],
        if (authState.successMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            authState.successMessage!,
            style: TextStyle(color: colorScheme.primary),
          ),
        ],
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Theme', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<AppThemeMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: AppThemeMode.system, label: Text('System')),
            ButtonSegment(value: AppThemeMode.light, label: Text('Light')),
            ButtonSegment(value: AppThemeMode.dark, label: Text('Dark')),
          ],
          selected: {settings.themeMode},
          onSelectionChanged: (selection) {
            context.read<SettingsCubit>().setThemeMode(selection.first);
          },
        ),
      ],
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Language', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'tr', label: Text('Türkçe')),
            ButtonSegment(value: 'en', label: Text('English')),
          ],
          selected: {settings.languageCode},
          onSelectionChanged: (selection) {
            context.read<SettingsCubit>().setLanguageCode(selection.first);
          },
        ),
      ],
    );
  }
}

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Water unit', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<WaterUnit>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: WaterUnit.ml, label: Text('ml')),
            ButtonSegment(value: WaterUnit.oz, label: Text('oz')),
          ],
          selected: {settings.waterUnit},
          onSelectionChanged: (selection) {
            context.read<SettingsCubit>().setWaterUnit(selection.first);
          },
        ),
      ],
    );
  }
}

class _ReminderList extends StatelessWidget {
  const _ReminderList({required this.reminders, required this.enabled});

  final List<WaterReminder> reminders;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (reminders.isEmpty) {
      return Text(
        'No reminders yet.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      );
    }

    return Column(
      children: reminders.map((reminder) {
        final id = reminder.id;

        return ListTile(
          key: ValueKey(reminder.id),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.alarm),
          title: Text(reminder.timeLabel),
          subtitle: Text(_modeLabel(reminder.mode)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: reminder.isEnabled,
                onChanged: id == null || !enabled
                    ? null
                    : (_) {
                        context.read<SettingsCubit>().toggleReminder(id);
                      },
              ),
              PopupMenuButton<ReminderMode>(
                enabled: enabled,
                onSelected: (mode) {
                  context.read<SettingsCubit>().saveReminder(
                    reminder.copyWith(mode: mode),
                  );
                },
                itemBuilder: (context) {
                  return ReminderMode.values
                      .map(
                        (mode) => PopupMenuItem(
                          value: mode,
                          child: Text(_modeLabel(mode)),
                        ),
                      )
                      .toList();
                },
                icon: const Icon(Icons.more_vert),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: id == null
                    ? null
                    : () {
                        context.read<SettingsCubit>().deleteReminder(id);
                      },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _modeLabel(ReminderMode mode) {
    switch (mode) {
      case ReminderMode.sound:
        return 'Sound';
      case ReminderMode.vibration:
        return 'Vibration';
      case ReminderMode.silent:
        return 'Silent';
    }
  }
}

class _SettingsErrorBanner extends StatelessWidget {
  const _SettingsErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.isEmpty ? 'Could not load settings.' : message,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<SettingsCubit>().load();
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onErrorContainer,
              ),
              child: const Text('Reload'),
            ),
          ],
        ),
      ),
    );
  }
}
