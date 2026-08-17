import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class YesAndNoDialog {
  Future<bool> showYNDialog(
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
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(appLoc.yes),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(appLoc.no),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
