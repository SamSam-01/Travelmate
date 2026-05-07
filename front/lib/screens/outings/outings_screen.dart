import 'package:flutter/material.dart';
import 'package:front/commons.dart';
import 'package:front/models/activity_model.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/main.dart';
import 'package:front/services/activity_service.dart';
import 'package:front/services/planned_outing_service.dart';
import 'package:front/services/user_service.dart';
import 'package:front/utils/planned_outings_helper.dart';
import 'package:front/styles/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OutingsScreen extends StatefulWidget {
  const OutingsScreen({super.key});

  @override
  State<OutingsScreen> createState() => _OutingsScreenState();
}

class _OutingsScreenState extends State<OutingsScreen> {
  final _activityService = const ActivityService();
  final _plannedOutingService = const PlannedOutingService();
  final _userService = const UserService();

  late Future<_OutingsData> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  Future<_OutingsData> _loadData() async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      final results = await Future.wait([
        _plannedOutingService.fetchPlannedOutings(
          currentUserId: currentUserId ?? '',
        ),
        _userService.fetchUsers(),
        _activityService.fetchActivities(),
      ]);

      final outings = filterPlannedOutingsForUser(
        plannedOutings: results[0] as List<PlannedOuting>,
        userId: currentUserId,
      );

      return _OutingsData(
        outings: outings,
        users: results[1] as List<PlannedOutingUser>,
        activities: results[2] as List<Activity>,
      );
    } on PostgrestException catch (error) {
      throw _OutingsLoadException(error.message);
    } catch (_) {
      throw const _OutingsLoadException(
        'Impossible de charger les sorties planifiées.',
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _futureData = _loadData();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).snackBarTheme.backgroundColor,
      ),
    );
  }

  Future<void> _openCreateSheet(_OutingsData data) async {
    final createdOuting = await showModalBottomSheet<PlannedOuting>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PlannedOutingFormSheet(
        users: data.users,
        activities: data.activities,
      ),
    );

    if (!mounted || createdOuting == null) {
      return;
    }

    _showSnackBar('Sortie "${createdOuting.title}" créée.');
    await _refresh();
  }

  String _formatCreatedAt(DateTime? createdAt) {
    if (createdAt == null) {
      return 'Créée récemment';
    }

    final date = createdAt.toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return 'Créée le $day/$month/${date.year} à $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorties'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<_OutingsData>(
            future: _futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                final error = snapshot.error;
                return _OutingsError(
                  message: error is _OutingsLoadException
                      ? error.message
                      : 'Impossible de charger les sorties pour le moment.',
                  onRetry: _refresh,
                );
              }

              final data = snapshot.data ?? const _OutingsData();
              final outings = data.outings;

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed:
                            (data.users.isEmpty || data.activities.isEmpty)
                            ? null
                            : () => _openCreateSheet(data),
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Créer une sortie',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (data.users.isEmpty)
                      _EmptyUsersHint(onRetry: _refresh)
                    else if (data.activities.isEmpty)
                      _EmptyActivitiesHint(onRetry: _refresh)
                    else if (outings.isEmpty)
                      _EmptyOutingsState(onCreate: () => _openCreateSheet(data))
                    else
                      ...outings.map(
                        (outing) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PlannedOutingCard(
                            outing: outing,
                            createdAtLabel: _formatCreatedAt(outing.createdAt),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PlannedOutingCard extends StatelessWidget {
  const _PlannedOutingCard({
    required this.outing,
    required this.createdAtLabel,
  });

  final PlannedOuting outing;
  final String createdAtLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outing.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        createdAtLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.event_available_outlined,
                  color: CrazerColors.lime,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Utilisateurs',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: outing.users.isEmpty
                  ? [const Chip(label: Text('Aucun utilisateur'))]
                  : outing.users
                        .map(
                          (user) => Chip(
                            avatar: CircleAvatar(
                              child: Text(_initials(user.name)),
                            ),
                            label: Text(user.name),
                          ),
                        )
                        .toList(growable: false),
            ),
            const SizedBox(height: 16),
            Text(
              'Activités avec horaire',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (outing.activities.isEmpty)
              const Text('Aucune activité renseignée')
            else
              Column(
                children: [
                  for (final activity in outing.activities)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 72,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: CrazerColors.lime.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              activity.time.isEmpty ? '—:—' : activity.time,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              activity.title,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    String initial(String value) =>
        value.isEmpty ? '?' : value[0].toUpperCase();
    if (parts.length == 1) return initial(parts.first);
    return '${initial(parts.first)}${initial(parts.last)}';
  }
}

class _EmptyOutingsState extends StatelessWidget {
  const _EmptyOutingsState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'Aucune sortie planifiée',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Crée une sortie avec un titre, des utilisateurs et des activités horodatées.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Créer la première sortie'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyUsersHint extends StatelessWidget {
  const _EmptyUsersHint({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'Aucun utilisateur disponible',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'La liste des profils Supabase est vide pour le moment.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Rafraîchir'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivitiesHint extends StatelessWidget {
  const _EmptyActivitiesHint({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_note_outlined, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'Aucune activité disponible',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'La table activities doit contenir au moins une activité pour créer une sortie liée.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Rafraîchir'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutingsError extends StatelessWidget {
  const _OutingsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 56, color: scheme.error),
          const SizedBox(height: 16),
          Text(
            'Impossible de charger les sorties',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _OutingsData {
  const _OutingsData({
    this.outings = const <PlannedOuting>[],
    this.users = const <PlannedOutingUser>[],
    this.activities = const <Activity>[],
  });

  final List<PlannedOuting> outings;
  final List<PlannedOutingUser> users;
  final List<Activity> activities;
}

class _OutingsLoadException implements Exception {
  const _OutingsLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _PlannedOutingFormSheet extends StatefulWidget {
  const _PlannedOutingFormSheet({
    required this.users,
    required this.activities,
  });

  final List<PlannedOutingUser> users;
  final List<Activity> activities;

  @override
  State<_PlannedOutingFormSheet> createState() =>
      _PlannedOutingFormSheetState();
}

class _PlannedOutingFormSheetState extends State<_PlannedOutingFormSheet> {
  final _service = const PlannedOutingService();
  final _titleController = TextEditingController();
  final List<_ActivityDraft> _activityDrafts = [_ActivityDraft()];
  final Set<String> _selectedUserIds = <String>{};

  var _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    for (final draft in _activityDrafts) {
      draft.dispose();
    }
    super.dispose();
  }

  void _addActivity() {
    setState(() {
      _activityDrafts.add(_ActivityDraft());
    });
  }

  void _removeActivity(int index) {
    if (_activityDrafts.length == 1) {
      return;
    }

    setState(() {
      _activityDrafts.removeAt(index).dispose();
    });
  }

  Future<void> _pickTime(int index) async {
    final current = _activityDrafts[index].timeController.text;
    final initialTime = _parseTimeOfDay(current) ?? TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _activityDrafts[index].timeController.text = picked.format(context);
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final selectedUsers = widget.users
        .where((user) => _selectedUserIds.contains(user.id))
        .toList(growable: false);
    final activities = _activityDrafts
        .map(
          (draft) => draft.selectedActivity == null
              ? null
              : PlannedOutingActivity.fromActivity(
                  draft.selectedActivity!,
                  time: draft.timeController.text.trim(),
                ),
        )
        .whereType<PlannedOutingActivity>()
        .where(
          (activity) =>
              activity.activityId.isNotEmpty && activity.time.isNotEmpty,
        )
        .toList(growable: false);

    if (title.isEmpty) {
      _showSnackBar('Ajoute un titre.', isError: true);
      return;
    }

    if (selectedUsers.isEmpty) {
      _showSnackBar('Sélectionne au moins un utilisateur.', isError: true);
      return;
    }

    if (activities.isEmpty) {
      _showSnackBar(
        'Ajoute au moins une activité avec horaire.',
        isError: true,
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final outing = await _service.createPlannedOuting(
        title: title,
        users: selectedUsers,
        activities: activities,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(outing);
    } on PostgrestException catch (error) {
      if (mounted) _showSnackBar(error.message, isError: true);
    } catch (_) {
      if (mounted) {
        _showSnackBar(
          'Impossible de créer la sortie planifiée.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  TimeOfDay? _parseTimeOfDay(String value) {
    final normalized = value.trim();
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(normalized);
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).snackBarTheme.backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Créer une sortie planifiée',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Titre',
                hintText: 'Ex. Dimanche à la plage',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Utilisateurs',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.users
                  .map(
                    (user) => FilterChip(
                      selected: _selectedUserIds.contains(user.id),
                      label: Text(user.name),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedUserIds.add(user.id);
                          } else {
                            _selectedUserIds.remove(user.id);
                          }
                        });
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Activités liées',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addActivity,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.activities.isEmpty)
              Text(
                'Aucune activité disponible pour le moment.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (var index = 0; index < _activityDrafts.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ActivityDraftRow(
                    activities: widget.activities,
                    draft: _activityDrafts[index],
                    index: index + 1,
                    canRemove: _activityDrafts.length > 1,
                    onSelectActivity: (activity) {
                      setState(() {
                        _activityDrafts[index].selectedActivity = activity;
                      });
                    },
                    onPickTime: () => _pickTime(index),
                    onRemove: () => _removeActivity(index),
                  ),
                ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Création...' : 'Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityDraft {
  _ActivityDraft();

  final TextEditingController timeController = TextEditingController();
  Activity? selectedActivity;

  void dispose() {
    timeController.dispose();
  }
}

class _ActivityDraftRow extends StatelessWidget {
  const _ActivityDraftRow({
    required this.activities,
    required this.draft,
    required this.index,
    required this.canRemove,
    required this.onSelectActivity,
    required this.onPickTime,
    required this.onRemove,
  });

  final List<Activity> activities;
  final _ActivityDraft draft;
  final int index;
  final bool canRemove;
  final ValueChanged<Activity?> onSelectActivity;
  final VoidCallback onPickTime;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Activité $index',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            DropdownButtonFormField<Activity>(
              value: draft.selectedActivity,
              items: activities
                  .map(
                    (activity) => DropdownMenuItem<Activity>(
                      value: activity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(activity.title),
                          if (activity.subtitle.isNotEmpty)
                            Text(
                              activity.subtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: onSelectActivity,
              decoration: const InputDecoration(
                labelText: 'Activité',
                hintText: 'Choisir une activité liée',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: draft.timeController,
              readOnly: true,
              onTap: onPickTime,
              decoration: InputDecoration(
                labelText: 'Heure',
                hintText: 'Sélectionne l’heure',
                suffixIcon: IconButton(
                  onPressed: onPickTime,
                  icon: const Icon(Icons.schedule_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
