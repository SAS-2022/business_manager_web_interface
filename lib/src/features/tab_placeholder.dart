import 'package:flutter/material.dart';

/// Shared body for the four shell tab stubs (Home/Orders/Products/Settings)
/// until their real content is ported in a later stage.
class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.stageNote,
    this.uid,
  });

  final IconData icon;
  final String title;
  final String stageNote;
  final String? uid;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              stageNote,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (uid != null) ...[
              const SizedBox(height: 8),
              Text('uid: $uid', style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
