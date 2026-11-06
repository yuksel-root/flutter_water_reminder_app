import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_event.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_state.dart';
import 'package:flutter_water_reminder_app/blocs/settings/settings_cubit.dart';
import 'package:flutter_water_reminder_app/blocs/settings/settings_state.dart';
import 'package:flutter_water_reminder_app/core/utils/water_formatter.dart';
import 'package:flutter_water_reminder_app/models/app_settings.dart';
import 'package:flutter_water_reminder_app/models/water/water_entry.dart';
import 'package:flutter_water_reminder_app/widgets/add_water_dialog.dart';
import 'package:flutter_water_reminder_app/widgets/edit_goal_dialog.dart';
import 'package:intl/intl.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Reminder'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<HomeBloc>().add(const HomeRefreshed());
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/home.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surface.withValues(alpha: 0.78),
                  colorScheme.surface.withValues(alpha: 0.94),
                ],
              ),
            ),
          ),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              final unit = settingsState.settings.waterUnit;

              return BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<HomeBloc>().add(const HomeRefreshed());
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        if (state.status == HomeStatus.loading)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: LinearProgressIndicator(minHeight: 3),
                          ),
                        _HomeHeader(state: state, unit: unit),
                        const SizedBox(height: 20),
                        _ProgressCard(state: state, unit: unit),
                        const SizedBox(height: 20),
                        const _QuickAdd(),
                        const SizedBox(height: 8),
                        _GoalButton(state: state),
                        if (state.status == HomeStatus.failure) ...[
                          const SizedBox(height: 16),
                          _HomeErrorCard(message: state.errorMessage),
                        ],
                        const SizedBox(height: 24),
                        _TodayEntries(entries: state.entries, unit: unit),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.state, required this.unit});

  final HomeState state;
  final WaterUnit unit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isComplete = state.progress >= 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isComplete
              ? 'Daily goal completed. Keep it up.'
              : '${formatWaterAmount(state.remainingMl, unit)} left to reach your goal.',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (isComplete) ...[
          const SizedBox(height: 10),
          Chip(
            avatar: Icon(
              Icons.check_circle,
              color: colorScheme.onPrimaryContainer,
            ),
            label: const Text('Goal reached'),
            backgroundColor: colorScheme.primaryContainer,
            labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
        ],
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.state, required this.unit});

  final HomeState state;
  final WaterUnit unit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 112,
              height: 112,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: state.progress,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    color: colorScheme.primary,
                  ),
                  Center(
                    child: Text(
                      '${(state.progress * 100).round()}%',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatWaterAmount(state.consumedMl, unit),
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'consumed today',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StatRow(
                    label: 'Goal',
                    value: formatWaterAmount(state.goalMl, unit),
                  ),
                  const SizedBox(height: 4),
                  _StatRow(
                    label: 'Remaining',
                    value: formatWaterAmount(state.remainingMl, unit),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _QuickAdd extends StatelessWidget {
  const _QuickAdd();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick add',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  context.read<HomeBloc>().add(const HomeWaterAdded(200));
                },
                icon: const Icon(Icons.local_drink_outlined),
                label: const Text('200 ml'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final amount = await showAddWaterDialog(context);

                  if (amount != null && context.mounted) {
                    context.read<HomeBloc>().add(HomeWaterAdded(amount));
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Custom'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoalButton extends StatelessWidget {
  const _GoalButton({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () async {
          final goal = await showEditGoalDialog(context, state.goalMl);

          if (goal != null && context.mounted) {
            context.read<HomeBloc>().add(HomeGoalUpdated(goal));
          }
        },
        icon: const Icon(Icons.flag_outlined),
        label: const Text('Edit daily goal'),
      ),
    );
  }
}

class _HomeErrorCard extends StatelessWidget {
  const _HomeErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.cloud_off_outlined, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Could not load your water data',
                    style: TextStyle(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.isEmpty ? 'Please try again.' : message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(const HomeRefreshed());
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onErrorContainer,
                    ),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayEntries extends StatelessWidget {
  const _TodayEntries({required this.entries, required this.unit});

  final List<WaterEntry> entries;
  final WaterUnit unit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (entries.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.water_drop_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('No water logged yet. Add your first glass.'),
                  ),
                ],
              ),
            ),
          )
        else
          ...entries.map(
            (entry) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.water_drop),
                ),
                title: Text(formatWaterAmount(entry.consumedMl, unit)),
                subtitle: Text(DateFormat('HH:mm').format(entry.createdAt)),
              ),
            ),
          ),
      ],
    );
  }
}
