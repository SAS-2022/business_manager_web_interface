import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/models/date_model.dart';
import 'package:flutter/material.dart';

class PeriodDropdown extends StatelessWidget {
  final AppLocalizations appLoc;
  final ResponsiveUtils responsive;
  final ValueChanged<String> onPeriodChanged;
  final String? selectedPeriod;

  const PeriodDropdown({
    super.key,
    required this.appLoc,
    required this.responsive,
    required this.onPeriodChanged,
    this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final periods = DateRangeHelper.getPeriodOptions(appLoc);
    final primary = Theme.of(context).colorScheme.primary;
    final hasSelection = selectedPeriod != null;

    return Container(
      height: responsive.scaleHeight(34),
      padding: EdgeInsets.symmetric(horizontal: responsive.scaleWidth(10)),
      decoration: BoxDecoration(
        // Tinted background when a period is active, plain when idle
        color: hasSelection
            ? primary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasSelection
              ? primary.withValues(alpha: 0.4)
              : Theme.of(context).dividerColor.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPeriod,
          isDense: true,
          iconSize: responsive.scaleFont(14),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: responsive.scaleHeight(16),
            color: hasSelection
                ? primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          elevation: 2,
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.date_range_outlined,
                size: responsive.scaleHeight(13),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: responsive.scaleWidth(4)),
              MyText(
                text: appLoc.selectPeriod,
                fontScale: responsive.scaleFont(11),
                fontColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          selectedItemBuilder: (context) => periods.map((period) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.date_range_outlined,
                  size: responsive.scaleHeight(13),
                  color: primary,
                ),
                SizedBox(width: responsive.scaleWidth(4)),
                MyText(
                  text: period,
                  fontScale: responsive.scaleFont(11),
                  fontWeight: FontWeight.w500,
                  fontColor: primary,
                ),
              ],
            );
          }).toList(),
          items: periods.map((String period) {
            final isSelected = period == selectedPeriod;
            return DropdownMenuItem<String>(
              value: period,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.scaleWidth(8),
                  vertical: responsive.scaleHeight(4),
                ),
                decoration: isSelected
                    ? BoxDecoration(
                        color: primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: MyText(
                  text: period,
                  fontScale: responsive.scaleFont(12),
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  fontColor: isSelected
                      ? primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) onPeriodChanged(newValue);
          },
        ),
      ),
    );
  }
}
