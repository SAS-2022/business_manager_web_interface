import 'package:flutter/material.dart';

/// Generic placeholder for routes this screen links to that aren't built
/// yet (business type onboarding, add/edit product). Avoids a broken
/// navigation while keeping the linking screen itself fully functional.
class RouteStubScreen extends StatelessWidget {
  const RouteStubScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title — coming in a later stage.')),
    );
  }
}
