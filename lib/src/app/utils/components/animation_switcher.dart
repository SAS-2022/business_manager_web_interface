import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../theme/responsive_utils.dart';
import '../../widgets/Text/my_text.dart';
import '../../widgets/Text/my_text_field.dart';

class AnimationSwitcherWidget extends StatefulWidget {
  const AnimationSwitcherWidget(
      {super.key,
      required this.searchController,
      required this.isSearching,
      required this.title});
  final TextEditingController? searchController;
  final bool? isSearching;
  final String? title;

  @override
  State<AnimationSwitcherWidget> createState() =>
      _AnimationSwitcherWidgetState();
}

class _AnimationSwitcherWidgetState extends State<AnimationSwitcherWidget> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    responsive = ResponsiveUtils(context);
  }

  @override
  Widget build(BuildContext context) {
    appLoc = AppLocalizations.of(context);
    if (appLoc == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.5, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: widget.isSearching!
          ? Padding(
              key: const ValueKey('search'), // Important for AnimatedSwitcher
              padding: EdgeInsets.only(top: responsive!.scaleHeight(2)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      responsive!.scaleHeight(40), // Maximum height constraint
                  minHeight: responsive!.scaleHeight(25), // Minimum height
                ),
                child: MyTextField(
                  height: responsive!.deviceType == 1
                      ? responsive!.scaleHeight(40)
                      : responsive!.scaleHeight(28),
                  controller: widget.searchController!,
                  hintText: appLoc!.search,
                  focus: true,
                  fontSize: responsive!.deviceType == 1
                      ? responsive!.scaleFont(16)
                      : responsive!.scaleFont(12),
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                vertical:
                    responsive!.scaleHeight(8), // Consistent vertical padding
              ),
              child: MyText(
                key: const ValueKey('title'), // Important for AnimatedSwitcher
                text: widget.title!,
                fontScale: responsive!.scaleFont(25),
              ),
            ),
    );
  }
}
