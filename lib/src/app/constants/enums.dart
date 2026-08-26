// Error enum for location — mobile's enums.dart also holds FileSource/
// MediaType/AppLanguage/AppTheme, all superseded on web already (direct
// ImagePicker calls replace FileSource/MediaType; AppLanguage/AppTheme
// live in app_settings/app_config.dart instead), so only this is needed.
enum LocationErrorType {
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  networkError,
  apiKeyError,
  unknown,
}
