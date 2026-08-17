import 'package:business_manager_web_ui/src/features/tab_placeholder.dart';
import 'package:flutter/material.dart';

/// Stub for Stage 6 (Home dashboard). Mirrors business_manager's
/// features/home/home_screen.dart path so real content can be dropped in
/// without touching the shell/router.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.uid});

  final String? uid;

  @override
  Widget build(BuildContext context) {
    return TabPlaceholder(
      icon: Icons.home_outlined,
      title: 'Home',
      stageNote: 'Dashboard content lands in Stage 6.',
      uid: uid,
    );
  }
}
