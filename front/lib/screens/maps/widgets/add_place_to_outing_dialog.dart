import 'package:flutter/material.dart';
import 'package:front/main.dart';
import 'package:front/models/activity_model.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/screens/maps/models/selected_map_place.dart';
import 'package:front/screens/outings/outings_screen.dart';
import 'package:front/services/activity_service.dart';
import 'package:front/services/planned_outing_service.dart';
import 'package:front/services/user_service.dart';
import 'package:front/widgets/home_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/presentation/providers/outing_providers.dart';

class AddPlaceToOutingDialog extends ConsumerStatefulWidget {
  const AddPlaceToOutingDialog({required this.place, super.key});

  final SelectedMapPlace place;

  @override
  ConsumerState<AddPlaceToOutingDialog> createState() => _AddPlaceToOutingDialogState();
}

class _AddPlaceToOutingDialogState extends ConsumerState<AddPlaceToOutingDialog> {
  final _activityService = const ActivityService();
  final _plannedOutingService = const PlannedOutingService();
  final _userService = const UserService();

  bool _isLoading = true;
  String? _error;
  List<PlannedOuting>? _outings;
  List<PlannedOutingUser>? _users;
  List<Activity>? _activities;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      final results = await Future.wait([
        _plannedOutingService.fetchPlannedOutings(
          currentUserId: currentUserId ?? '',
        ),
        _userService.fetchUsers(),
        _activityService.fetchActivities(),
      ]);

      if (!mounted) return;

      setState(() {
        _outings = results[0] as List<PlannedOuting>;
        _users = results[1] as List<PlannedOutingUser>;
        _activities = results[2] as List<Activity>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger les données.';
        _isLoading = false;
      });
    }
  }

  Activity _createActivityFromPlace() {
    return Activity(
      id: '',
      title: widget.place.name,
      subtitle: widget.place.address ?? '',
      badge: widget.place.category ?? 'Lieu',
      tone: HomeCarouselTone.city, // default tone
      icon: Icons.location_on_outlined,
      sortOrder: 0,
    );
  }

  Future<void> _handleCreateNew() async {
    if (_users == null || _activities == null) return;

    final initialActivity = _createActivityFromPlace();

    final createdOuting = await showModalBottomSheet<PlannedOuting>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => PlannedOutingFormSheet(
        users: _users!,
        activities: _activities!,
        initialActivity: initialActivity,
      ),
    );

    if (!mounted) return;

    if (createdOuting != null) {
      ref.invalidate(outingsDataProvider);
    }

    Navigator.of(context).pop(); // Close dialog after
  }

  Future<void> _handleAddToExisting(PlannedOuting outing) async {
    final formattedTime = await _pickDateTime();
    if (formattedTime == null || !mounted) return;

    try {
      // Create activity model
      final baseActivity = _createActivityFromPlace();
      final outingActivity = PlannedOutingActivity.fromActivity(
        baseActivity,
        time: formattedTime,
      );

      await _plannedOutingService.addActivityToOuting(
        outingId: outing.id,
        activity: outingActivity,
        sortOrder: outing.activities.length,
      );

      if (!mounted) return;
      ref.invalidate(outingsDataProvider);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lieu ajouté à la sortie "${outing.title}"')),
      );
    } catch (e, st) {
      debugPrint('Add activity error: $e');
      debugPrint(st.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout à la sortie : $e")),
      );
    }
  }

  Future<String?> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      helpText: "Sélectionnez la date pour cette activité",
    );

    if (pickedDate == null || !mounted) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: "Sélectionnez l'heure pour cette activité",
    );

    if (pickedTime == null || !mounted) return null;

    final day = pickedDate.day.toString().padLeft(2, '0');
    final month = pickedDate.month.toString().padLeft(2, '0');
    final year = pickedDate.year.toString();
    final hour = pickedTime.hour.toString().padLeft(2, '0');
    final minute = pickedTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return AlertDialog(
        title: const Text('Erreur'),
        content: Text(_error!),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      );
    }

    final myOutings = _outings ?? [];

    return Dialog(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Ajouter "${widget.place.name}"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          if (myOutings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('Aucune sortie existante.')),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: myOutings.length,
                itemBuilder: (context, index) {
                  final outing = myOutings[index];
                  return ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(outing.title),
                    subtitle: Text('${outing.activities.length} activité(s)'),
                    onTap: () => _handleAddToExisting(outing),
                  );
                },
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton.icon(
              onPressed: _handleCreateNew,
              icon: const Icon(Icons.add),
              label: const Text('Créer une nouvelle sortie'),
            ),
          ),
        ],
      ),
    );
  }
}
