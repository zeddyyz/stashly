import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/bookmark_controller.dart';
import '../controllers/theme_controller.dart';

/// View for app settings and information
class SettingsView extends StatefulWidget {
  /// Creates a new SettingsView
  const SettingsView({super.key});

  static const String routePath = '/settings';
  static const String routeName = 'settings';

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  PackageInfo? _packageInfo;
  late final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSection(
            title: 'Appearance',
            children: [
              Obx(
                () => SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark theme'),
                  value: _themeController.isDarkMode,
                  onChanged: (value) {
                    _themeController.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ),

              // Theme selection
              Obx(
                () => ListTile(
                  title: const Text('Theme Mode'),
                  subtitle: Text(_getThemeModeName(_themeController.themeMode.value)),
                  onTap: () => _showThemeModeDialog(),
                ),
              ),
            ],
          ),
          _buildSection(
            title: 'Premium Features',
            children: [
              ListTile(
                title: const Text('Upgrade to Premium'),
                subtitle: const Text('Remove bookmark limits and get more features'),
                trailing: const Icon(Icons.star),
                onTap: () {
                  // TODO: Implement premium upgrade flow
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Data Management',
            children: [
              ListTile(
                title: const Text('Export Bookmarks'),
                subtitle: const Text('Save your bookmarks as a file'),
                trailing: const Icon(Icons.download),
                onTap: () {
                  // TODO: Implement export functionality
                },
              ),
              ListTile(
                title: const Text('Import Bookmarks'),
                subtitle: const Text('Import bookmarks from a file'),
                trailing: const Icon(Icons.upload),
                onTap: () {
                  // TODO: Implement import functionality
                },
              ),
              ListTile(
                title: const Text('Clear All Data'),
                subtitle: const Text('Delete all bookmarks and settings'),
                trailing: const Icon(Icons.delete_forever, color: Colors.red),
                onTap: _showClearDataConfirmation,
              ),
            ],
          ),
          _buildSection(
            title: 'About',
            children: [
              ListTile(
                title: const Text('App Version'),
                subtitle: Text(
                  _packageInfo != null
                      ? '${_packageInfo!.version} (${_packageInfo!.buildNumber})'
                      : 'Loading...',
                ),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _launchUrl('https://stashly.app/privacy'),
              ),
              ListTile(
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _launchUrl('https://stashly.app/terms'),
              ),
              ListTile(
                title: const Text('Send Feedback'),
                trailing: const Icon(Icons.feedback),
                onTap: () => _launchUrl('mailto:support@stashly.app?subject=Stashly%20Feedback'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  /// Get a user-friendly name for the theme mode
  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  /// Show a dialog to select theme mode
  Future<void> _showThemeModeDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('System Default'),
                leading: Radio<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: _themeController.themeMode.value,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      _themeController.changeThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Light Mode'),
                leading: Radio<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: _themeController.themeMode.value,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      _themeController.changeThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Dark Mode'),
                leading: Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: _themeController.themeMode.value,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      _themeController.changeThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _showClearDataConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your bookmarks and reset all settings. '
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE EVERYTHING'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final controller = Get.find<BookmarkController>();
      final success = await controller.clearAllData();

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('All data has been cleared')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to clear data'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
