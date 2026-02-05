class SpiritualConfigurationResponse {
  bool? success;
  List<SpiritualConfiguration>? data;
  int? count;

  SpiritualConfigurationResponse({this.success, this.data, this.count});

  SpiritualConfigurationResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <SpiritualConfiguration>[];
      json['data'].forEach((v) {
        data!.add(SpiritualConfiguration.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['count'] = count;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SpiritualConfiguration {
  String? sId;
  String? title;
  String? description;
  String? duration;
  String? type;
  String? emotion;
  int? karmaPoints;
  String? chantingType;
  String? customChantingType;
  bool? isActive;
  bool? isDeleted;
  String? clientId;
  String? categoryId;
  int? iV;
  String? createdAt;
  String? updatedAt;

  SpiritualConfiguration({
    this.sId,
    this.title,
    this.description,
    this.duration,
    this.type,
    this.emotion,
    this.karmaPoints,
    this.chantingType,
    this.customChantingType,
    this.isActive,
    this.isDeleted,
    this.clientId,
    this.categoryId,
    this.iV,
    this.createdAt,
    this.updatedAt,
  });

  SpiritualConfiguration.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    duration = json['duration'];
    type = json['type'];
    emotion = json['emotion'];
    karmaPoints = json['karmaPoints'];
    chantingType = json['chantingType'];
    customChantingType = json['customChantingType'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    clientId = json['clientId'];
    categoryId = json['categoryId'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['description'] = description;
    data['duration'] = duration;
    data['type'] = type;
    data['emotion'] = emotion;
    data['karmaPoints'] = karmaPoints;
    data['chantingType'] = chantingType;
    data['customChantingType'] = customChantingType;
    data['isActive'] = isActive;
    data['isDeleted'] = isDeleted;
    data['clientId'] = clientId;
    data['categoryId'] = categoryId;
    data['__v'] = iV;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
