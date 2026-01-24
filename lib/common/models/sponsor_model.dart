class SponsorModel {
  bool? success;
  SponsorData? data;

  SponsorModel({this.success, this.data});

  SponsorModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? SponsorData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class SponsorData {
  List<Sponsor>? sponsors;
  int? count;

  SponsorData({this.sponsors, this.count});

  SponsorData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      sponsors = <Sponsor>[];
      json['data'].forEach((v) {
        sponsors!.add(Sponsor.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (sponsors != null) {
      data['data'] = sponsors!.map((v) => v.toJson()).toList();
    }
    data['count'] = count;
    return data;
  }
}

class Sponsor {
  String? sId;
  String? name;
  String? description;
  String? website;
  String? logo;
  String? logoKey;
  String? sponsorshipType;
  String? clientId;
  bool? isActive;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Sponsor(
      {this.sId,
      this.name,
      this.description,
      this.website,
      this.logo,
      this.logoKey,
      this.sponsorshipType,
      this.clientId,
      this.isActive,
      this.isDeleted,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Sponsor.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    website = json['website'];
    logo = json['logo'];
    logoKey = json['logoKey'];
    sponsorshipType = json['sponsorshipType'];
    clientId = json['clientId'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['website'] = website;
    data['logo'] = logo;
    data['logoKey'] = logoKey;
    data['sponsorshipType'] = sponsorshipType;
    data['clientId'] = clientId;
    data['isActive'] = isActive;
    data['isDeleted'] = isDeleted;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
