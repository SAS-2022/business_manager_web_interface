import 'package:business_manager_web_ui/src/features/tab_placeholder.dart';
import 'package:flutter/material.dart';

/// Stub for a later stage (Settings). Mirrors business_manager's
/// features/settings/settings_screen.dart path so real content can be
/// dropped in without touching the shell/router. `isActive` is kept
/// (default true) for constructor compatibility with the mobile signature.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.uid, this.isActive = true});

  final String? uid;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return TabPlaceholder(
      icon: Icons.settings_outlined,
      title: 'Menu',
      stageNote: 'Settings content lands in a later stage.',
      uid: uid,
    );
  }
}
