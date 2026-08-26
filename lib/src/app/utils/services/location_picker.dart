import 'dart:async';
import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/constants/apis.dart';
import 'package:business_manager_web_ui/src/app/constants/enums.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/services/google_geocoder_web.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/warning_dialog.dart';
import 'package:flutter/services.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/location_model.dart';
import '../../widgets/Text/my_text.dart';
import '../../widgets/buttons/my_button.dart';

class MapViewWidget extends StatefulWidget {
  const MapViewWidget({super.key, this.uid, this.locationNotifier});
  final String? uid;
  final ValueNotifier<LocationModel>? locationNotifier;

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  LatLng? _center;
  LatLng? _selectedPosition;
  String? _selectedCountry,
      _selectedProvince,
      _selectedPostalCode,
      _selectedAddressName,
      _selectedStreet,
      _selectedCountryCode;
  //Services
  final SnackbarWidget _snackbarWidget = SnackbarWidget();
  final WarningDialog _warningDialog = WarningDialog();
  TextEditingController locationName = TextEditingController();
  GoogleMapController? mapController;
  AppLocalizations? appLoc;
  ResponsiveUtils? responsive;
  double? lat, lng, zoom = 15;
  CameraPosition? _cameraPosition;
  String? apiKey;

  // Error handling states
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  LocationErrorType _errorType = LocationErrorType.unknown;

  @override
  void didChangeDependencies() {
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    getApiKey();
    widget.locationNotifier?.value = LocationModel();
    _snackbarWidget.context = context;
    super.initState();
  }

  // Web-native: mobile picks between two platform-restricted keys
  // (Platform.isAndroid/isIOS, dart:io — unavailable on web) and
  // self-tests the key with a REST geocoding call. The REST self-test
  // isn't viable here (that endpoint doesn't send permissive CORS
  // headers, so a browser can't read the response), and isn't needed
  // either — the Maps JavaScript API (loaded via the script tag in
  // web/index.html) shows its own visible error state if the key is
  // missing/restricted incorrectly, same as any other web app embedding it.
  void getApiKey() {
    try {
      apiKey = webMaps;
      if (apiKey == null || apiKey!.isEmpty) {
        _setError(LocationErrorType.apiKeyError,
            'Google Maps API key not configured');
        return;
      }
      _initializeLocation();
    } catch (e) {
      _setError(LocationErrorType.apiKeyError,
          'Failed to load API configuration: $e');
    }
  }

  Future<void> _initializeLocation() async {
    try {
      await _determinePosition();
    } catch (e) {
      _warningDialog.showWarningDialog(
          // ignore: use_build_context_synchronously
          context,
          appLoc!,
          '${appLoc!.error}: $e');
      return;
    }
  }

  Future<void> _determinePosition() async {
    if (_hasError) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location service is enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('🌐 Location Service Enabled: $serviceEnabled');
      if (!serviceEnabled) {
        _setError(
            LocationErrorType.serviceDisabled,
            appLoc?.locServiceDisabled ??
                'Location services are disabled. Please enable them to use this feature.');
        return;
      }

      // Get permission
      permission = await Geolocator.checkPermission();
      debugPrint('🌐 Location Permission Status: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setError(
              LocationErrorType.permissionDenied,
              appLoc?.locServiceDenied ??
                  'Location permissions are denied. Please grant location access to select your location.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setError(
            LocationErrorType.permissionDeniedForever,
            appLoc?.locServiceDeniedForever ??
                'Location permissions are permanently denied. if you wish to set your location you need to head to your device settings and enable them from there.');
        return;
      }

      // If permissions are granted, get current location
      var currentLocation = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 15), // Add timeout
      );
      debugPrint(
          '🌐 Current Location: Lat ${currentLocation.latitude}, Lng ${currentLocation.longitude}');
      if (mounted) {
        setState(() {
          lat = currentLocation.latitude;
          lng = currentLocation.longitude;
          _center = LatLng(lat!, lng!);
          _isLoading = false;
        });
      }

      // Animate camera after a short delay
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mapController != null && mounted) {
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _center!, zoom: zoom ?? 17),
            ),
          );
        }
      });
    } on TimeoutException {
      _setError(LocationErrorType.networkError,
          'Location request timed out. Please check your connection and try again.');
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    } catch (e) {
      _setError(LocationErrorType.unknown,
          'Failed to get your location: ${e.toString()}');
    }
  }

  void _setError(LocationErrorType type, String message) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorType = type;
        _errorMessage = message;
        _isLoading = false;
      });

      // Show snackbar for non-permission errors
      if (type != LocationErrorType.permissionDenied &&
          type != LocationErrorType.permissionDeniedForever) {
        _snackbarWidget.content = message;
        _snackbarWidget.time = 4;
        _snackbarWidget.showSnack();
      }
    }
  }

  void _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'PERMISSION_DENIED':
        _setError(LocationErrorType.permissionDenied,
            'Location permission denied. Please grant location access.');
        break;
      case 'LOCATION_SERVICE_DISABLED':
        _setError(LocationErrorType.serviceDisabled,
            'Location services are disabled. Please enable them.');
        break;
      case 'SERVICE_STATUS_ERROR':
        _setError(LocationErrorType.serviceDisabled,
            'Location service error. Please try again.');
        break;
      default:
        _setError(LocationErrorType.unknown,
            'Location error: ${e.message ?? 'Unknown error'}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        return _buildBody();
      }),
    ));
  }

  Widget _buildBody() {
    // Show error state
    if (_hasError) {
      return _buildErrorState();
    }

    // Show loading state
    if (_isLoading) {
      return SizedBox(
        height: responsive!.screenHeight,
        child: const Center(
          child: AnimatedArcLoader(),
        ),
      );
    }

    // Show map
    return _openGoogleMap();
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getErrorIcon(),
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 20),
          MyText(
              text: _getErrorTitle(),
              align: TextAlign.center,
              fontScale: responsive!.scaleFont(12)),
          const SizedBox(height: 10),
          MyText(
              text: _errorMessage,
              align: TextAlign.center,
              fontScale: responsive!.scaleFont(12)),
          const SizedBox(height: 30),
          _buildErrorActionButtons(),
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (_errorType) {
      case LocationErrorType.permissionDenied:
      case LocationErrorType.permissionDeniedForever:
        return Icons.location_off;
      case LocationErrorType.serviceDisabled:
        return Icons.location_disabled;
      case LocationErrorType.networkError:
        return Icons.wifi_off;
      case LocationErrorType.apiKeyError:
        return Icons.error_outline;
      default:
        return Icons.error;
    }
  }

  String _getErrorTitle() {
    switch (_errorType) {
      case LocationErrorType.permissionDenied:
        return appLoc?.locationPermissionDenied ?? 'Permission Required';
      case LocationErrorType.permissionDeniedForever:
        return appLoc?.locationPermissionPermanentlyDenied ??
            'Permission Denied';
      case LocationErrorType.serviceDisabled:
        return appLoc?.locationServicesDisabled ?? 'Location Disabled';
      case LocationErrorType.networkError:
        return appLoc?.networkError ?? 'Connection Error';
      case LocationErrorType.apiKeyError:
        return appLoc?.configurationError ?? 'Configuration Error';
      default:
        return appLoc?.somethingWentWrong ?? 'Something Went Wrong';
    }
  }

  Widget _buildErrorActionButtons() {
    return Column(
      children: [
        // Retry button for most errors
        if (_errorType != LocationErrorType.permissionDeniedForever)
          GestureDetector(
            onTap: () {
              _retryLocation();
            },
            child: MyButton(
              text: appLoc?.retry ?? 'Try Again',
              textColor: Colors.white,
            ),
          ),

        const SizedBox(height: 10),

        // Settings button for permission errors
        if (_errorType == LocationErrorType.permissionDeniedForever ||
            _errorType == LocationErrorType.serviceDisabled)
          OutlinedButton(
            onPressed: _openSettings,
            child: MyText(text: appLoc?.openSettings ?? 'Open Settings'),
          ),

        const SizedBox(height: 10),

        // Cancel button
        TextButton(
          onPressed: () => GoRouter.of(context).pop(),
          child: MyText(text: appLoc?.cancel ?? 'Cancel'),
        ),
      ],
    );
  }

  void _retryLocation() {
    _initializeLocation();
  }

  // Web-native: Geolocator.openLocationSettings() throws UnsupportedError
  // on web (geolocator_web) — there's no native settings screen to open.
  // Site-level location permission can only be changed through the
  // browser's own address-bar UI, which isn't scriptable, so this shows
  // guidance instead of attempting to open anything.
  void _openSettings() {
    _snackbarWidget.content = appLoc?.locationPermissionPermanentlyDenied ??
        'Please enable location access for this site in your browser settings.';
    _snackbarWidget.time = 5;
    _snackbarWidget.showSnack();
  }

  Widget _openGoogleMap() {
    if (apiKey == null || apiKey!.isEmpty) {
      return Center(
        child: MyText(text: appLoc!.noApiKeyDetected),
      );
    }
    return _center != null
        ? Stack(
            children: [
              GoogleMap(
                onMapCreated: (controller) {
                  setState(() {
                    mapController = controller;
                  });
                },
                mapToolbarEnabled: true,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                initialCameraPosition:
                    CameraPosition(target: _center!, zoom: zoom!),
                onCameraMove: (position) async {
                  _cameraPosition = position;
                  if (_cameraPosition != null) {
                    try {
                      final address = await reverseGeocodeWeb(
                          _cameraPosition!.target.latitude,
                          _cameraPosition!.target.longitude);
                      if (mounted) {
                        setState(() {
                          _selectedPosition = LatLng(
                              _cameraPosition!.target.latitude,
                              _cameraPosition!.target.longitude);
                          _selectedCountry = address.country;
                          _selectedCountryCode = address.countryCode;
                          _selectedProvince = address.province;
                          _selectedPostalCode = address.postalCode;
                          _selectedAddressName = address.locality;
                          _selectedStreet = address.street;
                        });
                      }
                    } catch (e) {
                      _showGeocodingError(
                          'Failed to get address details. Please try again.');
                    }
                  }
                },
                onCameraIdle: () async {
                  if (_cameraPosition != null) {
                    try {
                      final address = await reverseGeocodeWeb(
                          _cameraPosition!.target.latitude,
                          _cameraPosition!.target.longitude);
                      if (mounted) {
                        setState(() {
                          _selectedPosition = LatLng(
                              _cameraPosition!.target.latitude,
                              _cameraPosition!.target.longitude);
                          _selectedCountry = address.country;
                          _selectedCountryCode = address.countryCode;
                          _selectedProvince = address.province;
                          _selectedPostalCode = address.postalCode;
                          _selectedAddressName = address.locality;
                          _selectedStreet = address.street;
                        });
                      }
                    } catch (e) {
                      _showGeocodingError(
                          'Failed to get address details. Please try again.');
                    }
                  }
                },
              ),
              Center(
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.black),
                  ),
                ),
              ),
              _selectedCountry != null && _selectedAddressName != null
                  ? Positioned(
                      top: responsive!.screenWidth / 6,
                      left: 30,
                      right: 30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 1,
                                spreadRadius: 2),
                          ],
                        ),
                        child: MyText(
                          text:
                              '$_selectedCountry $_selectedProvince $_selectedAddressName',
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),

              //Add a bottom to select location
              Positioned(
                  bottom: responsive!.screenHeight * 0.04,
                  left: (responsive!.screenWidth / 2) -
                      (responsive!.screenWidth * 0.25),
                  child: SizedBox(
                    width: responsive!.screenWidth * 0.5,
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          if (_selectedCountry != null &&
                              _selectedAddressName != null &&
                              _selectedPosition != null) {
                            var locationModel = LocationModel(
                              name: _selectedAddressName,
                              mapCountry: _selectedCountry,
                              countryCode: _selectedCountryCode,
                              addressName: _selectedAddressName,
                              province: _selectedProvince,
                              postalCode: _selectedPostalCode,
                              street: _selectedStreet,
                              lat: _selectedPosition?.latitude,
                              lng: _selectedPosition?.longitude,
                            );

                            try {
                              final snapshot = await _getMapSnapshot(LatLng(
                                  locationModel.lat!, locationModel.lng!));
                              locationModel.snapshot = snapshot;
                            } catch (e) {
                              throw Exception(e);
                            }
                            widget.locationNotifier?.value = locationModel;
                          }
                          if (mounted) {
                            GoRouter.of(context).pop();
                          }
                        } on MapSnapshotError catch (e) {
                          _handleMapSnapshotError(e);
                        } catch (e) {
                          _handleMapSnapshotError(
                            MapSnapshotError(
                              type: MapSnapshotErrorType.unknown,
                              message: 'Unexpected error: ${e.toString()}',
                            ),
                          );
                        }
                      },
                      child: MyButton(
                        text: appLoc!.selectLocation,
                        textColor: Colors.white,
                      ),
                    ),
                  )),

              //Cancel
              Positioned(
                bottom: responsive!.screenHeight * 0.04,
                left:
                    (responsive!.screenWidth / 3) - responsive!.screenWidth / 4,
                child: SizedBox(
                  width: responsive!.screenHeight * 0.05,
                  height: responsive!.screenHeight * 0.05,
                  child: Center(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        GoRouter.of(context).pop();
                      },
                      icon: Icon(
                        Icons.cancel,
                        size: responsive!.screenWidth * 0.1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : SizedBox(
            height: responsive!.screenHeight,
            child: const Center(
              child: AnimatedArcLoader(),
            ),
          );
  }

  // Web-native: returns the Static Maps URL directly for Image.network to
  // load (an <img>-style request needs no CORS headers), instead of
  // mobile's http.get() + stored raw bytes — the Static Maps API doesn't
  // send permissive CORS headers, so a browser XHR/fetch read of the
  // response body would be blocked even though the exact same URL loads
  // fine as an image (its actual intended client-side use). No network
  // call needed here at all.
  Future<String> _getMapSnapshot(LatLng position) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw MapSnapshotError(
        type: MapSnapshotErrorType.apiKeyMissing,
        message: 'Google Maps API key is not configured',
      );
    }
    if (position.latitude < -90 ||
        position.latitude > 90 ||
        position.longitude < -180 ||
        position.longitude > 180) {
      throw MapSnapshotError(
        type: MapSnapshotErrorType.invalidCoordinates,
        message:
            'Invalid coordinates provided: ${position.latitude}, ${position.longitude}',
      );
    }

    return 'https://maps.googleapis.com/maps/api/staticmap?center=${position.latitude},${position.longitude}&zoom=16&size=400x200&maptype=roadmap&markers=color:red%7C${position.latitude},${position.longitude}&key=$apiKey';
  }

  void _showGeocodingError(String message) {
    if (mounted) {
      _snackbarWidget.content = message;
      _snackbarWidget.time = 4;
      _snackbarWidget.showSnack();

      // Set default values to prevent null errors
      setState(() {
        _selectedCountry = 'Unknown';
        _selectedCountryCode = '';
        _selectedProvince = 'Unknown';
        _selectedPostalCode = '';
        _selectedAddressName = 'Unknown';
        _selectedStreet = 'Unknown';
      });
    }
  }

  void _handleMapSnapshotError(MapSnapshotError error) {
    debugPrint('🗺️ Map Snapshot Error: ${error.toString()}');

    // Show user-friendly error message
    String userMessage;

    switch (error.type) {
      case MapSnapshotErrorType.apiKeyMissing:
      case MapSnapshotErrorType.apiKeyInvalid:
        userMessage = 'Map configuration error. Please contact support.';
        break;
      case MapSnapshotErrorType.networkError:
        userMessage =
            'No internet connection. Please check your network and try again.';
        break;
      case MapSnapshotErrorType.timeout:
        userMessage = 'Request timed out. Please try again.';
        break;
      case MapSnapshotErrorType.rateLimited:
        userMessage = 'Too many requests. Please wait a moment and try again.';
        break;
      case MapSnapshotErrorType.invalidCoordinates:
        userMessage =
            'Invalid location coordinates. Please select a different location.';
        break;
      default:
        userMessage = 'Failed to load map preview. Please try again.';
    }

    if (mounted) {
      // Show snackbar or dialog with error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

class MapSnapshotError implements Exception {
  final MapSnapshotErrorType type;
  final String message;
  final int? statusCode;

  MapSnapshotError({
    required this.type,
    required this.message,
    this.statusCode,
  });

  @override
  String toString() {
    return 'MapSnapshotError [${type.name}]${statusCode != null ? ' (HTTP $statusCode)' : ''}: $message';
  }
}

enum MapSnapshotErrorType {
  apiKeyMissing,
  apiKeyInvalid,
  invalidCoordinates,
  invalidRequest,
  networkError,
  timeout,
  rateLimited,
  serverError,
  notFound,
  invalidResponse,
  unknown,
}
