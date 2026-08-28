import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:flutter/material.dart';

class SocialMediaSignIn extends StatefulWidget {
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;
  const SocialMediaSignIn({
    super.key,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
  });

  @override
  State<SocialMediaSignIn> createState() => _SocialMediaSignInState();
}

class _SocialMediaSignInState extends State<SocialMediaSignIn> {
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google Button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary,
                blurRadius: 2,
                spreadRadius: 1,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          width: responsive!.screenWidth * 0.7,
          child: ElevatedButton(
            onPressed: widget.onGoogleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(16),
                vertical: responsive!.scaleHeight(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/google_logo.png',
                  height: responsive!.scaleHeight(24),
                  width: responsive!.scaleHeight(24),
                  filterQuality: FilterQuality.high,
                ),
                SizedBox(width: responsive!.scaleWidth(8)),
                Text(
                  'Google',
                  style: TextStyle(
                    fontSize: responsive!.scaleHeight(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: responsive!.scaleHeight(10)),

        // Apple Button - only show on iOS
        if (Theme.of(context).platform == TargetPlatform.iOS) ...[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary,
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            width: responsive!.screenWidth * 0.7,
            child: ElevatedButton(
              onPressed: widget.onAppleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(16),
                  vertical: responsive!.scaleHeight(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/apple_logo.png',
                    height: responsive!.scaleHeight(24),
                    width: responsive!.scaleHeight(24),
                    color: Colors.white,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(width: responsive!.scaleWidth(8)),
                  Text(
                    'Apple',
                    style: TextStyle(
                      fontSize: responsive!.scaleHeight(16),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
