import 'dart:convert';
import 'dart:typed_data';

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
  Uint8List? snapshot;
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
      'snapshot': snapshot != null ? base64Encode(snapshot as List<int>) : null,
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
      snapshot: map['snapshot'] != null ? base64Decode(map['snapshot']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationModel.fromJson(String source) =>
      LocationModel.fromMap(json.decode(source));
}
