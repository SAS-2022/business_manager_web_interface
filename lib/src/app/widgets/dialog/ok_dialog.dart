import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class OkDialog {
  Future<bool> showOkDialog(
      BuildContext context, AppLocalizations appLoc, String? title,
      {String? content}) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title!),
              content: Text(content ?? ''),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(appLoc.ok),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
