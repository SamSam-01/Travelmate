import 'package:flutter/material.dart';
import 'package:front/screens/account/account_page.dart';
import 'package:front/screens/home/home_screen.dart';
import 'package:front/screens/maps/maps_screen.dart';
import 'package:front/screens/outings/outings_screen.dart';
import 'package:front/styles/colors.dart';

enum AppShellTab { home, maps, outings, profile }

class AuthenticatedAppShell extends StatefulWidget {
  const AuthenticatedAppShell({
    super.key,
    this.initialTab = AppShellTab.home,
    this.profileRequiresSession = true,
  });

  final AppShellTab initialTab;
  final bool profileRequiresSession;

  @override
  State<AuthenticatedAppShell> createState() => _AuthenticatedAppShellState();
}

class _AuthenticatedAppShellState extends State<AuthenticatedAppShell> {
  late int _currentIndex;
  final Set<int> _visitedIndexes = <int>{};

  late final List<_AppTabItem> _tabs = [
    _AppTabItem(
      tab: AppShellTab.home,
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      builder: (_) => const HomeScreen(),
    ),
    _AppTabItem(
      tab: AppShellTab.maps,
      label: 'Maps',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
      builder: (_) => const MapsScreen(),
    ),
    _AppTabItem(
      tab: AppShellTab.outings,
      label: 'Sorties',
      icon: Icons.event_note_outlined,
      selectedIcon: Icons.event,
      builder: (_) => const OutingsScreen(),
    ),
    _AppTabItem(
      tab: AppShellTab.profile,
      label: 'Profil',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      builder: (_) =>
          AccountPage(requireSession: widget.profileRequiresSession),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = _tabs.indexWhere((item) => item.tab == widget.initialTab);
    if (_currentIndex < 0) {
      _currentIndex = 0;
    }
    _visitedIndexes.add(_currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (var index = 0; index < _tabs.length; index++)
            _visitedIndexes.contains(index)
                ? Builder(builder: _tabs[index].builder)
                : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: CrazerColors.surface,
        indicatorColor: CrazerColors.lime.withValues(alpha: 0.18),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          if (index == _currentIndex) return;
          setState(() {
            _currentIndex = index;
            _visitedIndexes.add(index);
          });
        },
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _AppTabItem {
  const _AppTabItem({
    required this.tab,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });

  final AppShellTab tab;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder builder;
}
