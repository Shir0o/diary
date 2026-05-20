import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../helpers/font_helper.dart';
import '../services/auth_service.dart';

class SideDrawer extends StatelessWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;
  final AuthService authService;

  const SideDrawer({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<GoogleSignInAccount?>(
      stream: authService.onCurrentUserChanged,
      initialData: authService.currentUser,
      builder: (context, snapshot) {
        return NavigationDrawer(
          onDestinationSelected: onItemSelected,
          selectedIndex: selectedIndex,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
              child: Text(
                'Diary App',
                style: safeGoogleFont(
                  'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.timeline_outlined),
              selectedIcon: Icon(Icons.timeline),
              label: Text('Timeline'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: Text('Calendar'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.archive_outlined),
              selectedIcon: Icon(Icons.archive),
              label: Text('Archive'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.delete_outline),
              selectedIcon: Icon(Icons.delete),
              label: Text('Trash'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library),
              label: Text('Media'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: Text('Analytics'),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
              child: Divider(),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.help_outline),
              selectedIcon: Icon(Icons.help),
              label: Text('Help'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.info_outline),
              selectedIcon: Icon(Icons.info),
              label: Text('About'),
            ),
          ],
        );
      },
    );
  }
}
