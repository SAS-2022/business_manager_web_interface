import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import '../../theme/responsive_utils.dart';

class CountryCodePhone extends StatefulWidget {
  const CountryCodePhone(
      {super.key, required this.onSelected, this.initialCode});
  final Function(String countryCode, String country) onSelected;
  final String? initialCode;

  @override
  State<CountryCodePhone> createState() => _CountryCodePhoneState();
}

class _CountryCodePhoneState extends State<CountryCodePhone> {
  //Initials
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;

  @override
  void didChangeDependencies() {
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: responsive!.scaleHeight(50),
      decoration: BoxDecoration(
          border: Border.all(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(5)),
      child: CountryCodePicker(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
        onChanged: (country) {
          widget.onSelected(country.dialCode!, country.code!);
        },
        initialSelection: widget.initialCode ?? 'US', // Default country
        favorite: const ['US', 'LB'], // Favorite countries
        showCountryOnly: false,
        showOnlyCountryWhenClosed: false,
        alignLeft: false,
        showFlag: false, // Remove flags if not needed
        textStyle: TextStyle(fontSize: responsive!.scaleFont(12)),
        searchDecoration: InputDecoration(
          hintText: appLoc!.search,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
