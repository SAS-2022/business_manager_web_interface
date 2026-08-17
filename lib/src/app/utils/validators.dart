import 'package:business_manager_web_ui/l10n/app_localizations.dart';

class PasswordValidator {
  static final _numberRegex = RegExp(r'[0-9]');
  static final _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  AppLocalizations? appLoc;

  static ValidationResult validate(String password, AppLocalizations appLoc) {
    if (password.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: appLoc.passwordRequired,
      );
    }

    if (password.length < 8) {
      return ValidationResult(
        isValid: false,
        errorMessage: appLoc.shortPassword,
      );
    }

    if (!_numberRegex.hasMatch(password)) {
      return ValidationResult(
        isValid: false,
        errorMessage: appLoc.needNumber,
      );
    }

    if (!_specialCharRegex.hasMatch(password)) {
      return ValidationResult(
        isValid: false,
        errorMessage: appLoc.needSpCharacter,
      );
    }

    return ValidationResult(isValid: true);
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}
