import 'package:flutter/material.dart';
import 'package:front/models/activity_model.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/screens/outings/widgets/create_outing_components.dart';
import 'package:front/services/planned_outing_service.dart';
import 'package:front/styles/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateOutingFlowScreen extends StatefulWidget {
  const CreateOutingFlowScreen({
    super.key,
    required this.users,
    required this.activities,
  });

  final List<PlannedOutingUser> users;
  final List<Activity> activities;

  @override
  State<CreateOutingFlowScreen> createState() => _CreateOutingFlowScreenState();
}

class _CreateOutingFlowScreenState extends State<CreateOutingFlowScreen> {
  final _service = const PlannedOutingService();
  var _draft = const _CreateOutingDraft();
  var _saving = false;

  bool get _canSubmit =>
      _draft.title.isNotEmpty &&
      _draft.selectedUserIds.isNotEmpty &&
      _draft.scheduledFor != null &&
      _draft.selectedActivityIds.isNotEmpty;

  Future<void> _openDetailsStep() async {
    final result = await Navigator.of(context).push<_DetailsStepResult>(
      MaterialPageRoute(
        builder: (_) => _OutingDetailsStepPage(
          users: widget.users,
          initialTitle: _draft.title,
          initialVisibility: _draft.visibility,
          initialSelectedUserIds: _draft.selectedUserIds,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _draft = _draft.copyWith(
        title: result.title,
        visibility: result.visibility,
        selectedUserIds: result.selectedUserIds,
      );
    });
  }

  Future<void> _openWhenStep() async {
    final result = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(
        builder: (_) => _OutingWhenStepPage(initialDateTime: _draft.scheduledFor),
      ),
    );

    if (result == null) return;

    setState(() {
      _draft = _draft.copyWith(scheduledFor: result);
    });
  }

  Future<void> _openActivitiesStep() async {
    final result = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (_) => _OutingActivitiesStepPage(
          activities: widget.activities,
          initialSelectedActivityIds: _draft.selectedActivityIds,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _draft = _draft.copyWith(selectedActivityIds: result);
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      showCrazerSnackBar(
        context,
        'Complète toutes les étapes avant de confirmer.',
        isError: true,
      );
      return;
    }

    final selectedUsers = widget.users
        .where((user) => _draft.selectedUserIds.contains(user.id))
        .toList(growable: false);
    final selectedActivities = widget.activities
        .where((activity) => _draft.selectedActivityIds.contains(activity.id))
        .map((activity) => PlannedOutingActivity.fromActivity(activity, time: ''))
        .toList(growable: false);

    setState(() {
      _saving = true;
    });

    try {
      final outing = await _service.createPlannedOuting(
        title: _draft.title,
        users: selectedUsers,
        activities: selectedActivities,
        visibility: _draft.visibility,
        scheduledFor: _draft.scheduledFor,
      );

      if (!mounted) return;
      Navigator.of(context).pop(outing);
    } on PostgrestException catch (error) {
      if (mounted) showCrazerSnackBar(context, error.message, isError: true);
    } catch (_) {
      if (mounted) {
        showCrazerSnackBar(
          context,
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

  @override
  Widget build(BuildContext context) {
    return CrazerStepScaffold(
      title: 'Créer une sortie',
      children: [
        CrazerStepActionCard(
          stepNumber: 1,
          title: 'Détails',
          summary: _detailsSummary(widget.users, _draft),
          completed: _draft.title.isNotEmpty && _draft.selectedUserIds.isNotEmpty,
          buttonLabel: 'Modifier les détails',
          onPressed: _openDetailsStep,
        ),
        const SizedBox(height: 12),
        CrazerStepActionCard(
          stepNumber: 2,
          title: 'Quand ?',
          summary: _draft.scheduledFor == null
              ? 'Aucune date définie.'
              : _formatDateTime(_draft.scheduledFor!),
          completed: _draft.scheduledFor != null,
          buttonLabel: 'Définir la date',
          onPressed: _openWhenStep,
        ),
        const SizedBox(height: 12),
        CrazerStepActionCard(
          stepNumber: 3,
          title: 'Quelles activités ?',
          summary: _activitiesSummary(widget.activities, _draft.selectedActivityIds),
          completed: _draft.selectedActivityIds.isNotEmpty,
          buttonLabel: 'Choisir les activités',
          onPressed: _openActivitiesStep,
        ),
        const SizedBox(height: 16),
        CrazerPrimaryButton(
          height: 52,
          label: _saving ? 'Création...' : 'Confirmer la sortie',
          onPressed: _saving ? null : _submit,
        ),
      ],
    );
  }
}

class _OutingDetailsStepPage extends StatefulWidget {
  const _OutingDetailsStepPage({
    required this.users,
    required this.initialTitle,
    required this.initialVisibility,
    required this.initialSelectedUserIds,
  });

  final List<PlannedOutingUser> users;
  final String initialTitle;
  final OutingVisibility initialVisibility;
  final Set<String> initialSelectedUserIds;

  @override
  State<_OutingDetailsStepPage> createState() => _OutingDetailsStepPageState();
}

class _OutingDetailsStepPageState extends State<_OutingDetailsStepPage> {
  late final TextEditingController _titleController;
  late OutingVisibility _visibility;
  late Set<String> _selectedUserIds;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _visibility = widget.initialVisibility;
    _selectedUserIds = <String>{...widget.initialSelectedUserIds};
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _confirm() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showCrazerSnackBar(context, 'Ajoute un titre.', isError: true);
      return;
    }
    if (_selectedUserIds.isEmpty) {
      showCrazerSnackBar(context, 'Sélectionne au moins un ami.', isError: true);
      return;
    }

    Navigator.of(context).pop(
      _DetailsStepResult(
        title: title,
        visibility: _visibility,
        selectedUserIds: _selectedUserIds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CrazerStepScaffold(
      title: 'Étape 1 — Détails',
      children: [
        TextField(
          controller: _titleController,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Titre',
            hintText: 'Ex. Week-end plage',
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<OutingVisibility>(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.black;
              }
              return Theme.of(context).colorScheme.onSurface;
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return CrazerColors.lime;
              }
              return Theme.of(context).colorScheme.surface;
            }),
          ),
          segments: const <ButtonSegment<OutingVisibility>>[
            ButtonSegment<OutingVisibility>(
              value: OutingVisibility.private,
              label: Text('Privée'),
              icon: Icon(Icons.lock_outline),
            ),
            ButtonSegment<OutingVisibility>(
              value: OutingVisibility.public,
              label: Text('Publique'),
              icon: Icon(Icons.public),
            ),
          ],
          selected: <OutingVisibility>{_visibility},
          onSelectionChanged: (selection) {
            setState(() {
              _visibility = selection.first;
            });
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Amis participants',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
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
        CrazerPrimaryButton(label: 'Confirmer', onPressed: _confirm),
      ],
    );
  }
}

class _OutingWhenStepPage extends StatefulWidget {
  const _OutingWhenStepPage({required this.initialDateTime});

  final DateTime? initialDateTime;

  @override
  State<_OutingWhenStepPage> createState() => _OutingWhenStepPageState();
}

class _OutingWhenStepPageState extends State<_OutingWhenStepPage> {
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initial = _selectedDateTime ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _confirm() {
    if (_selectedDateTime == null) {
      showCrazerSnackBar(context, 'Choisis une date et une heure.', isError: true);
      return;
    }
    Navigator.of(context).pop(_selectedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return CrazerStepScaffold(
      title: 'Étape 2 — Quand ?',
      children: [
        CrazerOutlineButton(
          label: 'Choisir la date et l’heure',
          icon: Icons.calendar_month_outlined,
          onPressed: _pickDateTime,
        ),
        const SizedBox(height: 12),
        Text(
          _selectedDateTime == null
              ? 'Aucune date sélectionnée.'
              : _formatDateTime(_selectedDateTime!),
        ),
        const SizedBox(height: 20),
        CrazerPrimaryButton(label: 'Confirmer', onPressed: _confirm),
      ],
    );
  }
}

class _OutingActivitiesStepPage extends StatefulWidget {
  const _OutingActivitiesStepPage({
    required this.activities,
    required this.initialSelectedActivityIds,
  });

  final List<Activity> activities;
  final Set<String> initialSelectedActivityIds;

  @override
  State<_OutingActivitiesStepPage> createState() => _OutingActivitiesStepPageState();
}

class _OutingActivitiesStepPageState extends State<_OutingActivitiesStepPage> {
  late Set<String> _selectedActivityIds;

  @override
  void initState() {
    super.initState();
    _selectedActivityIds = <String>{...widget.initialSelectedActivityIds};
  }

  void _confirm() {
    if (_selectedActivityIds.isEmpty) {
      showCrazerSnackBar(
        context,
        'Sélectionne au moins une activité.',
        isError: true,
      );
      return;
    }
    Navigator.of(context).pop(_selectedActivityIds);
  }

  @override
  Widget build(BuildContext context) {
    return CrazerStepScaffold(
      title: 'Étape 3 — Activités',
      children: [
        for (final activity in widget.activities)
          CheckboxListTile(
            value: _selectedActivityIds.contains(activity.id),
            activeColor: CrazerColors.lime,
            checkColor: Colors.black,
            title: Text(activity.title),
            subtitle: activity.subtitle.isEmpty ? null : Text(activity.subtitle),
            onChanged: (selected) {
              setState(() {
                if (selected ?? false) {
                  _selectedActivityIds.add(activity.id);
                } else {
                  _selectedActivityIds.remove(activity.id);
                }
              });
            },
          ),
        const SizedBox(height: 8),
        CrazerPrimaryButton(label: 'Confirmer', onPressed: _confirm),
      ],
    );
  }
}

class _CreateOutingDraft {
  const _CreateOutingDraft({
    this.title = '',
    this.visibility = OutingVisibility.private,
    this.scheduledFor,
    this.selectedUserIds = const <String>{},
    this.selectedActivityIds = const <String>{},
  });

  final String title;
  final OutingVisibility visibility;
  final DateTime? scheduledFor;
  final Set<String> selectedUserIds;
  final Set<String> selectedActivityIds;

  _CreateOutingDraft copyWith({
    String? title,
    OutingVisibility? visibility,
    DateTime? scheduledFor,
    Set<String>? selectedUserIds,
    Set<String>? selectedActivityIds,
  }) {
    return _CreateOutingDraft(
      title: title ?? this.title,
      visibility: visibility ?? this.visibility,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      selectedUserIds: selectedUserIds ?? this.selectedUserIds,
      selectedActivityIds: selectedActivityIds ?? this.selectedActivityIds,
    );
  }
}

class _DetailsStepResult {
  const _DetailsStepResult({
    required this.title,
    required this.visibility,
    required this.selectedUserIds,
  });

  final String title;
  final OutingVisibility visibility;
  final Set<String> selectedUserIds;
}

String _detailsSummary(List<PlannedOutingUser> users, _CreateOutingDraft draft) {
  if (draft.title.isEmpty && draft.selectedUserIds.isEmpty) {
    return 'Titre, visibilité et amis participants non renseignés.';
  }

  final selectedNames = users
      .where((user) => draft.selectedUserIds.contains(user.id))
      .map((user) => user.name)
      .take(3)
      .join(', ');

  final participants = draft.selectedUserIds.isEmpty
      ? 'Aucun ami'
      : '${draft.selectedUserIds.length} ami${draft.selectedUserIds.length > 1 ? 's' : ''}';

  return '${draft.title.isEmpty ? 'Sans titre' : draft.title} • ${draft.visibility.label} • $participants${selectedNames.isEmpty ? '' : ' ($selectedNames)'}';
}

String _activitiesSummary(List<Activity> activities, Set<String> selectedIds) {
  if (selectedIds.isEmpty) return 'Aucune activité sélectionnée.';

  final selectedTitles = activities
      .where((activity) => selectedIds.contains(activity.id))
      .map((activity) => activity.title)
      .take(3)
      .join(', ');
  return '${selectedIds.length} activité${selectedIds.length > 1 ? 's' : ''} • $selectedTitles';
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/${local.year} à $hour:$minute';
}
