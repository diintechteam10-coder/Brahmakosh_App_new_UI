class BrahmReel {
  bool? success;
  ReelResponseData? data;
  int? count;

  BrahmReel({this.success, this.data, this.count});

  BrahmReel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? new ReelResponseData.fromJson(json['data'])
        : null;
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['count'] = this.count;
    return data;
  }
}

class ReelResponseData {
  List<ReelItem>? data;

  ReelResponseData({this.data});

  ReelResponseData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ReelItem>[];
      json['data'].forEach((v) {
        data!.add(new ReelItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReelItem {
  String? sId;
  String? name;
  String? description;
  String? category;
  String? type;
  String? video;
  String? videoKey;
  String? image;
  String? imageKey;
  String? imagePrompt;
  String? videoPrompt;
  String? clientId;
  bool? isActive;
  int? views;
  int? likes;
  int? shares;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? videoUrl;
  String? imageUrl;

  ReelItem({
    this.sId,
    this.name,
    this.description,
    this.category,
    this.type,
    this.video,
    this.videoKey,
    this.image,
    this.imageKey,
    this.imagePrompt,
    this.videoPrompt,
    this.clientId,
    this.isActive,
    this.views,
    this.likes,
    this.shares,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.videoUrl,
    this.imageUrl,
  });

  ReelItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    category = json['category'];
    type = json['type'];
    video = json['video'];
    videoKey = json['videoKey'];
    image = json['image'];
    imageKey = json['imageKey'];
    imagePrompt = json['imagePrompt'];
    videoPrompt = json['videoPrompt'];
    clientId = json['clientId'];
    isActive = json['isActive'];
    views = json['views'];
    likes = json['likes'];
    shares = json['shares'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    videoUrl = json['videoUrl'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['category'] = this.category;
    data['type'] = this.type;
    data['video'] = this.video;
    data['videoKey'] = this.videoKey;
    data['image'] = this.image;
    data['imageKey'] = this.imageKey;
    data['imagePrompt'] = this.imagePrompt;
    data['videoPrompt'] = this.videoPrompt;
    data['clientId'] = this.clientId;
    data['isActive'] = this.isActive;
    data['views'] = this.views;
    data['likes'] = this.likes;
    data['shares'] = this.shares;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['videoUrl'] = this.videoUrl;
    data['imageUrl'] = this.imageUrl;
    return data;
  }
}
