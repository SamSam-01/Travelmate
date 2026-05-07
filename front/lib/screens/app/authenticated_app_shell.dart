import 'package:flutter/material.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/presentation/pages/friends_page.dart';
import 'package:front/screens/account/account_page.dart';
import 'package:front/screens/home/home_screen.dart';
import 'package:front/screens/maps/maps_screen.dart';
import 'package:front/theme/crazer_theme.dart';

enum AppShellTab { home, maps, friends, profile }

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
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      builder: (_) => const HomeScreen(),
    ),
    _AppTabItem(
      tab: AppShellTab.maps,
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
      builder: (_) => const MapsScreen(),
    ),
    _AppTabItem(
      tab: AppShellTab.friends,
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      builder: (_) => const FriendsPage(),
    ),
    _AppTabItem(
      tab: AppShellTab.profile,
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
    final localizations = AppLocalizations.of(context)!;
    final labels = <AppShellTab, String>{
      AppShellTab.home: localizations.navigationHome,
      AppShellTab.maps: localizations.navigationMaps,
      AppShellTab.friends: localizations.navigationFriends,
      AppShellTab.profile: localizations.navigationProfile,
    };

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
              label: labels[tab.tab]!,
            ),
        ],
      ),
    );
  }
}

class _AppTabItem {
  const _AppTabItem({
    required this.tab,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });

  final AppShellTab tab;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder builder;
}
