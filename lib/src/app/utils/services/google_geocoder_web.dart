// Web-native reverse geocoding — replaces mobile's `geocoding` package
// (its pubspec declares only android/ios platform packages, no web
// implementation at all — placemarkFromCoordinates() would throw
// MissingPluginException here) and avoids calling Google's Geocoding
// REST API directly via http.get(), which a browser blocks reading (that
// endpoint doesn't send permissive CORS headers, even though it works
// fine from mobile's native HTTP stack). Instead this calls the Maps
// JavaScript API's own client-side `google.maps.Geocoder` — already
// loaded via the script tag in web/index.html — which is designed
// exactly for this in-browser use case and has no CORS restriction.
import 'dart:js_interop';

@JS('google.maps.Geocoder')
extension type _JSGeocoder._(JSObject _) implements JSObject {
  external _JSGeocoder();
  external JSPromise<_GeocoderResponse> geocode(_GeocoderRequest request);
}

extension type _GeocoderRequest._(JSObject _) implements JSObject {
  external factory _GeocoderRequest({_LatLngLiteral location});
}

extension type _LatLngLiteral._(JSObject _) implements JSObject {
  external factory _LatLngLiteral({double lat, double lng});
}

extension type _GeocoderResponse._(JSObject _) implements JSObject {
  external JSArray<_GeocoderResult> get results;
}

extension type _GeocoderResult._(JSObject _) implements JSObject {
  @JS('address_components')
  external JSArray<_AddressComponent> get addressComponents;
}

extension type _AddressComponent._(JSObject _) implements JSObject {
  @JS('long_name')
  external String get longName;
  @JS('short_name')
  external String get shortName;
  external JSArray<JSString> get types;
}

/// Mirrors the shape mobile's `placemarkFromCoordinates(...).first` (a
/// `Placemark`) provides, so the call sites in location_picker.dart read
/// the same way regardless of which mechanism produced the address.
class GeocodedAddress {
  final String? country;
  final String? countryCode;
  final String? province;
  final String? postalCode;
  final String? locality;
  final String? street;

  GeocodedAddress({
    this.country,
    this.countryCode,
    this.province,
    this.postalCode,
    this.locality,
    this.street,
  });
}

Future<GeocodedAddress> reverseGeocodeWeb(double lat, double lng) async {
  final geocoder = _JSGeocoder();
  final response = await geocoder
      .geocode(_GeocoderRequest(location: _LatLngLiteral(lat: lat, lng: lng)))
      .toDart;
  final results = response.results.toDart;
  if (results.isEmpty) {
    throw Exception('No address found for this location');
  }
  final components = results.first.addressComponents.toDart;

  String? findLong(String type) {
    for (final c in components) {
      if (c.types.toDart.any((t) => t.toDart == type)) return c.longName;
    }
    return null;
  }

  String? findShort(String type) {
    for (final c in components) {
      if (c.types.toDart.any((t) => t.toDart == type)) return c.shortName;
    }
    return null;
  }

  final streetNumber = findLong('street_number');
  final route = findLong('route');
  final street =
      [streetNumber, route].whereType<String>().join(' ').trim();

  return GeocodedAddress(
    country: findLong('country'),
    countryCode: findShort('country'),
    province: findLong('administrative_area_level_1'),
    postalCode: findLong('postal_code'),
    locality: findLong('locality'),
    street: street.isEmpty ? null : street,
  );
}
