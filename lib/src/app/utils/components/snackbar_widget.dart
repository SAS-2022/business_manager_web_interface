import 'package:flutter/material.dart';
import '../../widgets/Text/my_text.dart';

class SnackbarWidget {
  //Will show a snack bar
  late BuildContext context;
  late String content;
  Color? color;
  int? time;
  double? height;
  String? buttonText;
  VoidCallback? onButtonPressed;

  void showSnack() async {
    // Ensure we're still in the same context before showing
    if (!context.mounted) return;
    // Resolve the correct ScaffoldMessengerState for the current context.
    // Using maybeOf avoids crashes if no ScaffoldMessenger is in the tree.
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    // Dismiss any existing snackbar first to avoid stacking / off-screen issues.
    messenger.clearSnackBars();
    // Calculate bottom margin: if a bottom sheet or nav bar is present the
    // MediaQuery viewInsets will be non-zero; add extra clearance so the
    // snackbar never overlaps or goes off-screen.
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final extraBottom = (height ?? 20) + bottomPadding;
    final capturedButtonText = buttonText;
    final capturedOnButtonPressed = onButtonPressed;

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: MyText(
                text: content,
                fontColor: Theme.of(context).colorScheme.secondary,
                softWrap: true,
                textOverflow: TextOverflow.visible,
              ),
            ),
            if (capturedButtonText != null &&
                capturedOnButtonPressed != null) ...[
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  // Dismiss snackbar first
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  capturedOnButtonPressed();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  backgroundColor: Colors.transparent,
                ),
                child: MyText(
                  text: capturedButtonText,
                  fontColor: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        duration: Duration(seconds: time ?? 3),
        elevation: 15,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: extraBottom, left: 5, right: 5),
        // ignore: use_build_context_synchronously
        backgroundColor: color ?? Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
    // Reset one-shot fields after showing so stale values don't leak into
    // the next showSnack() call.
    time = null;
    buttonText = null;
    onButtonPressed = null;
    color = null;
  }

  void clear() {
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }
}
