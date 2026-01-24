class ChantingMantra {
  bool? success;
  List<Data>? data;
  int? count;

  ChantingMantra({this.success, this.data, this.count});

  ChantingMantra.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['count'] = this.count;
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  String? description;
  int? malaCount;
  String? videoUrl;
  String? videoKey;
  String? imageUrl;
  String? imageKey;
  int? duration;
  String? clientId;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? totalCount;
  int? iV;

  Data(
      {this.sId,
      this.name,
      this.description,
      this.malaCount,
      this.videoUrl,
      this.videoKey,
      this.imageUrl,
      this.imageKey,
      this.duration,
      this.clientId,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.totalCount,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    malaCount = json['malaCount'];
    videoUrl = json['videoUrl'];
    videoKey = json['videoKey'];
    imageUrl = json['imageUrl'];
    imageKey = json['imageKey'];
    duration = json['duration'];
    clientId = json['clientId'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    totalCount = json['totalCount'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['malaCount'] = this.malaCount;
    data['videoUrl'] = this.videoUrl;
    data['videoKey'] = this.videoKey;
    data['imageUrl'] = this.imageUrl;
    data['imageKey'] = this.imageKey;
    data['duration'] = this.duration;
    data['clientId'] = this.clientId;
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['totalCount'] = this.totalCount;
    data['__v'] = this.iV;
    return data;
  }
}
