import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:flutter/material.dart';

class DynamicDropdown extends StatelessWidget {
  final List<dynamic> items;
  final dynamic selectedValue;
  final Function(dynamic) onChanged;
  final AppLocalizations? appLoc;
  final ResponsiveUtils? responsive;
  final String? hint;

  const DynamicDropdown({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.appLoc,
    this.responsive,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<dynamic>(
      dropdownColor: Theme.of(context).colorScheme.secondary,
      initialValue: selectedValue,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<dynamic>>((value) {
        return DropdownMenuItem<dynamic>(
          value: value,
          child: MyText(
            text: value.toString(),
            fontScale: responsive!.scaleFont(12),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        fillColor: Theme.of(context).colorScheme.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              width: 0.5,
              color: Theme.of(context).colorScheme.primary), // Enabled state
        ),
        hintText: hint,
        contentPadding: responsive!.responsivePaddingS,
      ),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down),
    );
  }
}
