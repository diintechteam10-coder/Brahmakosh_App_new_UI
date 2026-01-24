class AvtarList {
  bool? success;
  List<Data>? data;
  int? count;

  AvtarList({this.success, this.data, this.count});

  AvtarList.fromJson(Map<String, dynamic> json) {
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
  String? agentId;
  String? gender;
  String? link;
  String? imageUrl;
  String? imageKey;
  String? videoUrl;
  String? videoKey;
  String? status;
  int? viewers;
  String? duration;
  String? clientId;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.name,
      this.description,
      this.agentId,
      this.gender,
      this.link,
      this.imageUrl,
      this.imageKey,
      this.videoUrl,
      this.videoKey,
      this.status,
      this.viewers,
      this.duration,
      this.clientId,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    agentId = json['agentId'];
    gender = json['gender'];
    link = json['link'];
    imageUrl = json['imageUrl'];
    imageKey = json['imageKey'];
    videoUrl = json['videoUrl'];
    videoKey = json['videoKey'];
    status = json['status'];
    viewers = json['viewers'];
    duration = json['duration'];
    clientId = json['clientId'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['agentId'] = this.agentId;
    data['gender'] = this.gender;
    data['link'] = this.link;
    data['imageUrl'] = this.imageUrl;
    data['imageKey'] = this.imageKey;
    data['videoUrl'] = this.videoUrl;
    data['videoKey'] = this.videoKey;
    data['status'] = this.status;
    data['viewers'] = this.viewers;
    data['duration'] = this.duration;
    data['clientId'] = this.clientId;
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
