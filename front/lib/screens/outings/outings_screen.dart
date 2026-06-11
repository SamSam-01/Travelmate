import 'package:front/commons.dart';
import 'package:front/main.dart';
import 'package:front/models/activity_model.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/services/activity_service.dart';
import 'package:front/services/planned_outing_service.dart';
import 'package:front/services/user_service.dart';
import 'package:front/presentation/widgets/planned_outing_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:front/presentation/providers/outing_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OutingsScreen extends ConsumerStatefulWidget {
  const OutingsScreen({super.key});

  @override
  ConsumerState<OutingsScreen> createState() => _OutingsScreenState();
}

class _OutingsScreenState extends ConsumerState<OutingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _refresh() async {
    ref.invalidate(outingsDataProvider);
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

  Future<void> _openCreateSheet(OutingsData data) async {
    final createdOuting = await showModalBottomSheet<PlannedOuting>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => PlannedOutingFormSheet(
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
    final asyncData = ref.watch(outingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorties'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: asyncData.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _OutingsError(
              message: error.toString(),
              onRetry: _refresh,
            ),
            data: (data) {
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
                          child: PlannedOutingCard(
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

class PlannedOutingFormSheet extends StatefulWidget {
  const PlannedOutingFormSheet({
    required this.users,
    required this.activities,
    this.initialActivity,
    super.key,
  });

  final List<PlannedOutingUser> users;
  final List<Activity> activities;
  final Activity? initialActivity;

  @override
  State<PlannedOutingFormSheet> createState() => _PlannedOutingFormSheetState();
}

class _PlannedOutingFormSheetState extends State<PlannedOutingFormSheet> {
  final _service = const PlannedOutingService();
  final _titleController = TextEditingController();
  late final List<_ActivityDraft> _activityDrafts;
  late final List<Activity> _activities;
  final Set<String> _selectedUserIds = <String>{};

  var _saving = false;

  @override
  void initState() {
    super.initState();
    _activities = List.of(widget.activities);
    if (widget.initialActivity != null && !_activities.any((a) => a.id == widget.initialActivity!.id)) {
      _activities.insert(0, widget.initialActivity!);
    }

    _activityDrafts = [
      if (widget.initialActivity != null)
        _ActivityDraft()..selectedActivity = widget.initialActivity
      else
        _ActivityDraft(),
    ];
  }

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

  Future<void> _pickDateTime(int index) async {
    final now = DateTime.now();
    final current = _activityDrafts[index].timeController.text;

    // Parse current if available (format: DD/MM/YYYY HH:mm)
    DateTime? initialDate;
    TimeOfDay? initialTime;
    if (current.isNotEmpty && current.length >= 16) {
      try {
        final parts = current.split(' ');
        final dateParts = parts[0].split('/');
        final timeParts = parts[1].split(':');
        if (dateParts.length == 3 && timeParts.length == 2) {
          initialDate = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );
          initialTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      } catch (_) {}
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );

    if (pickedTime == null || !mounted) return;

    final day = pickedDate.day.toString().padLeft(2, '0');
    final month = pickedDate.month.toString().padLeft(2, '0');
    final year = pickedDate.year.toString();
    final hour = pickedTime.hour.toString().padLeft(2, '0');
    final minute = pickedTime.minute.toString().padLeft(2, '0');

    setState(() {
      _activityDrafts[index].timeController.text =
          '$day/$month/$year $hour:$minute';
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final selectedUsers = widget.users
        .where((user) => _selectedUserIds.contains(user.id))
        .toList();

    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId != null) {
      final creator = widget.users.where((u) => u.id == currentUserId).firstOrNull;
      if (creator != null && !selectedUsers.any((u) => u.id == creator.id)) {
        selectedUsers.add(creator);
      }
    }
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
          (activity) => activity.time.isNotEmpty,
        )
        .toList(growable: false);

    if (title.isEmpty) {
      _showSnackBar('Ajoute un titre.', isError: true);
      return;
    }

    if (selectedUsers.length <= 1) {
      _showSnackBar('Sélectionne au moins un invité.', isError: true);
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
                  .where((user) => user.id != supabase.auth.currentUser?.id)
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
            if (_activities.isEmpty)
              Text(
                'Aucune activité disponible pour le moment.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (var index = 0; index < _activityDrafts.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ActivityDraftRow(
                    activities: _activities,
                    draft: _activityDrafts[index],
                    index: index + 1,
                    canRemove: _activityDrafts.length > 1,
                    onSelectActivity: (activity) {
                      setState(() {
                        _activityDrafts[index].selectedActivity = activity;
                      });
                    },
                    onPickDateTime: () => _pickDateTime(index),
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
    required this.onPickDateTime,
    required this.onRemove,
  });

  final List<Activity> activities;
  final _ActivityDraft draft;
  final int index;
  final bool canRemove;
  final ValueChanged<Activity?> onSelectActivity;
  final VoidCallback onPickDateTime;
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
              initialValue: draft.selectedActivity,
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
              onTap: onPickDateTime,
              decoration: InputDecoration(
                labelText: 'Date et heure',
                hintText: 'Sélectionne la date et l’heure',
                suffixIcon: IconButton(
                  onPressed: onPickDateTime,
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
