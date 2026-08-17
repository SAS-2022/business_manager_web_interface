import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class WarningDialog {
  Future<bool> showWarningDialog(BuildContext context, AppLocalizations appLoc,
      String warningMessage) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLoc.warning),
          content: Text(warningMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(appLoc.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(appLoc.discard),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
