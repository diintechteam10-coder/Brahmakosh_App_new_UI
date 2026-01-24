class GetCurrentLoc {
  bool? success;
  Data? data;

  GetCurrentLoc({this.success, this.data});

  GetCurrentLoc.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Location? location;

  Data({this.location});

  Data.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    return data;
  }
}

class Location {
  String? formattedAddress;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  double? latitude;
  double? longitude;
  String? placeId;

  Location(
      {this.formattedAddress,
      this.city,
      this.state,
      this.country,
      this.postalCode,
      this.latitude,
      this.longitude,
      this.placeId});

  Location.fromJson(Map<String, dynamic> json) {
    formattedAddress = json['formattedAddress'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    postalCode = json['postalCode'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    placeId = json['placeId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['formattedAddress'] = this.formattedAddress;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['postalCode'] = this.postalCode;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['placeId'] = this.placeId;
    return data;
  }
}
