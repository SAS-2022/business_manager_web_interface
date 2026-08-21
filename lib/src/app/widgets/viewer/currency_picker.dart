// import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';
import '../../../services/database_service.dart';
import '../../theme/responsive_utils.dart';
import '../../utils/components/snackbar_widget.dart';
import '../Text/my_text.dart';

class CurrencyPicker extends StatefulWidget {
  const CurrencyPicker(
      {super.key, this.uid, this.currencyChanged, required this.currentUser});
  final String? uid;
  final UserDetails currentUser;
  final ValueChanged<bool>? currencyChanged;

  @override
  State<CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<CurrencyPicker> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  SnackbarWidget snackbar = SnackbarWidget();
  DatabaseService db = DatabaseService();
  Currency? selectedCurreny;
  bool? currencyChanged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbar.context = context;
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  // ── Build — only visual changed, showCurrencyPicker + saveCurrency unchanged

  @override
  Widget build(BuildContext context) {
    final String displaySymbol = selectedCurreny != null
        ? selectedCurreny!.symbol
        : widget.currentUser.currency?['symbol'] ?? '\$';

    final String displayName = selectedCurreny != null
        ? selectedCurreny!.name
        : widget.currentUser.currency?['name'] ?? 'United States Dollar';

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            showCurrencyPicker(
              context: context,
              showFlag: true,
              showSearchField: true,
              showCurrencyName: true,
              showCurrencyCode: true,
              favorite: ['usd'],
              onSelect: (Currency currency) {
                setState(() {
                  selectedCurreny = currency;
                  if (widget.currentUser.currency != null &&
                      currency.name != widget.currentUser.currency!['name']) {
                    currencyChanged = true;
                  } else {
                    currencyChanged = false;
                  }
                  saveCurrency(widget.currentUser);
                });
              },
              theme: CurrencyPickerThemeData(
                bottomSheetHeight: responsive!.scaleHeight(600),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flagSize: responsive!.scaleWidth(35),
              ),
            );
          },
          child: Row(
            children: [
              // Symbol badge
              Container(
                padding: responsive!.responsivePaddingS,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.4),
                    width: 0.7,
                  ),
                ),
                child: MyText(
                  text: displaySymbol,
                  fontScale: responsive!.scaleFont(15),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: responsive!.scaleWidth(15)),
              // Currency name
              Expanded(
                child: MyText(
                  text: displayName,
                  fontScale: responsive!.scaleFont(13),
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Chevron indicating tappable
              Icon(
                Icons.chevron_right,
                size: responsive!.scaleHeight(16),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        if (isLoading) const Center(child: AnimatedArcLoader()),
      ],
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<void> saveCurrency(UserDetails currentUser) async {
    if (selectedCurreny != null) {
      setState(() => isLoading = true);
      UserDetails newUser = currentUser;
      var currency = {
        'name': selectedCurreny!.name,
        'code': selectedCurreny!.code,
        'symbol': selectedCurreny!.symbol,
      };
      newUser.currency = currency;
      await db.updateCurrentUser(user: newUser);
      if (mounted) setState(() => isLoading = false);
    }
  }
}

// ── SimpleCurrencyButton — UI updated, logic unchanged ────────────────────────

class SimpleCurrencyButton extends StatefulWidget {
  const SimpleCurrencyButton(
      {super.key, this.uid, required this.currentUser, this.currencyChanged});
  final String? uid;
  final UserDetails currentUser;
  final ValueChanged<bool>? currencyChanged;

  @override
  State<SimpleCurrencyButton> createState() => _SimpleCurrencyButtonState();
}

class _SimpleCurrencyButtonState extends State<SimpleCurrencyButton> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  SnackbarWidget snackbar = SnackbarWidget();
  DatabaseService db = DatabaseService();
  Currency? selectedCurrency;
  bool? currencyChanged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbar.context = context;
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: responsive!.responsivePaddingBottom,
      child: widget.currentUser.currency == null
          // No currency yet — show select button
          ? GestureDetector(
              onTap: () async {
                showCurrencyPicker(
                  context: context,
                  showFlag: true,
                  showSearchField: false,
                  showCurrencyName: true,
                  showCurrencyCode: true,
                  favorite: ['usd'],
                  onSelect: (Currency currency) {
                    setState(() {
                      selectedCurrency = currency;
                      if (widget.currentUser.currency == null &&
                          selectedCurrency != null) {
                        currencyChanged = true;
                      }
                      if (widget.currentUser.currency != null &&
                          currency.name !=
                              widget.currentUser.currency!['name']) {
                        currencyChanged = true;
                      } else {
                        currencyChanged = false;
                      }
                      saveCurrency(widget.currentUser);
                    });
                  },
                  theme: CurrencyPickerThemeData(
                    bottomSheetHeight: responsive!.scaleHeight(600),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    flagSize: responsive!.scaleWidth(35),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: responsive!.scaleHeight(14),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: MyText(
                    text: appLoc!.currency,
                    fontScale: responsive!.scaleFont(14),
                    fontWeight: FontWeight.w500,
                    fontColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            )
          // Currency already set — show current + change button
          : Column(
              children: [
                // Current currency display row
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14),
                    vertical: responsive!.scaleHeight(12),
                  ),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          Theme.of(context).dividerColor.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: MyText(
                          text: widget.currentUser.currency!['symbol'] ?? '',
                          fontScale: responsive!.scaleFont(13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: responsive!.scaleWidth(10)),
                      Expanded(
                        child: MyText(
                          text: widget.currentUser.currency!['name'] ?? '',
                          fontScale: responsive!.scaleFont(13),
                        ),
                      ),
                      MyText(
                        text: widget.currentUser.currency!['code'] ?? '',
                        fontScale: responsive!.scaleFont(12),
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: responsive!.scaleHeight(10)),
                // Change currency button
                GestureDetector(
                  onTap: () {
                    showCurrencyPicker(
                      context: context,
                      showFlag: true,
                      showSearchField: false,
                      showCurrencyName: true,
                      showCurrencyCode: true,
                      favorite: ['usd'],
                      onSelect: (Currency currency) {
                        setState(() {
                          selectedCurrency = currency;
                          if (widget.currentUser.currency != null &&
                              currency.name !=
                                  widget.currentUser.currency!['name']) {
                            currencyChanged = true;
                          } else {
                            currencyChanged = false;
                          }
                          saveCurrency(widget.currentUser);
                        });
                      },
                      theme: CurrencyPickerThemeData(
                        bottomSheetHeight: responsive!.scaleHeight(600),
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        flagSize: responsive!.scaleWidth(35),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: responsive!.scaleHeight(13),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: MyText(
                        text: appLoc!.changeCurrency,
                        fontScale: responsive!.scaleFont(13),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<void> saveCurrency(UserDetails currentUser) async {
    if (selectedCurrency != null) {
      setState(() => isLoading = true);
      UserDetails newUser = currentUser;
      var currency = {
        'name': selectedCurrency!.name,
        'code': selectedCurrency!.code,
        'symbol': selectedCurrency!.symbol,
      };
      newUser.currency = currency;
      await db.updateCurrentUser(user: newUser);
      if (widget.currencyChanged != null) {
        widget.currencyChanged!(currencyChanged!);
      }
      if (mounted) setState(() => isLoading = false);
    }
  }
}
