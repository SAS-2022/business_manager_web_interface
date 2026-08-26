import 'dart:convert';

class LocationModel {
  String? name;
  String? mapCountry;
  String? countryCode;
  String? addressName;
  String? province;
  String? postalCode;
  String? street;
  double? lat;
  double? lng;
  // Web-only change: a Static Maps API URL rather than mobile's downloaded
  // + base64-stored image bytes. Google's Static Maps API doesn't send
  // permissive CORS headers, so a browser can't read the response body via
  // http.get() the way mobile's native HTTP stack can — but the same URL
  // loads fine as an <img> (Image.network), which is the API's actual
  // intended client-side usage. See location_picker.dart's _getMapSnapshot.
  String? snapshot;
  LocationModel(
      {this.name,
      this.mapCountry,
      this.countryCode,
      this.addressName,
      this.province,
      this.postalCode,
      this.street,
      this.lat,
      this.lng,
      this.snapshot});

  @override
  String toString() {
    return 'LocationModel(name: $name, mapCountry: $mapCountry, countryCode: $countryCode, addressName: $addressName, province: $province, postalCode: $postalCode, street: $street, lat: $lat, lng: $lng, snapshot: $snapshot)';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mapCountry': mapCountry,
      'countryCode': countryCode,
      'addressName': addressName,
      'province': province,
      'postalCode': postalCode,
      'street': street,
      'lat': lat,
      'lng': lng,
      'snapshot': snapshot,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      name: map['name'],
      mapCountry: map['mapCountry'],
      countryCode: map['countryCode'],
      addressName: map['addressName'],
      province: map['province'],
      postalCode: map['postalCode'],
      street: map['street'],
      lat: map['lat']?.toDouble(),
      lng: map['lng']?.toDouble(),
      snapshot: map['snapshot'],
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationModel.fromJson(String source) =>
      LocationModel.fromMap(json.decode(source));
}
