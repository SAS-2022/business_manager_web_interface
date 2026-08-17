import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DeletionDialog {
  Future<bool> showDeletionDialog(BuildContext context, AppLocalizations appLoc,
      {int? number}) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(appLoc.delete),
              content: number != null
                  ? Text(appLoc.deleteConfirmationWithCount(number))
                  : Text(appLoc.deleteConfirmation),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(appLoc.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(appLoc.delete),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> showAccountDeletionDialog(
      BuildContext context, AppLocalizations appLoc) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(appLoc.delete),
              content: Text(appLoc.accountDeletionMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(appLoc.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(appLoc.delete),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> showCancelDialog(
      BuildContext context, AppLocalizations appLoc) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(appLoc.cancel),
              content: Text(appLoc.cancelConfirmation),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(appLoc.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(appLoc.ok),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> showRestoreDialog(
      BuildContext context, AppLocalizations appLoc) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(appLoc.restore),
              content: Text(appLoc.restoreConfirmation),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(appLoc.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(appLoc.ok),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
