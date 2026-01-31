class SpiritualClipResponse {
  bool? success;
  List<SpiritualClip>? data;
  int? count;
  String? configurationId;

  SpiritualClipResponse({
    this.success,
    this.data,
    this.count,
    this.configurationId,
  });

  SpiritualClipResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <SpiritualClip>[];
      json['data'].forEach((v) {
        data!.add(SpiritualClip.fromJson(v));
      });
    }
    count = json['count'];
    configurationId = json['configurationId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['count'] = count;
    data['configurationId'] = configurationId;
    return data;
  }
}

class SpiritualClip {
  String? sId;
  String? title;
  String? description;
  String? fileUrl;
  String? type;
  String? configurationId;
  String? createdAt;
  String? updatedAt;

  SpiritualClip({
    this.sId,
    this.title,
    this.description,
    this.fileUrl,
    this.type,
    this.configurationId,
    this.createdAt,
    this.updatedAt,
  });

  SpiritualClip.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    fileUrl = json['url'] ?? json['fileUrl']; // Fallback for flexibility
    type = json['type'];
    configurationId = json['configurationId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['description'] = description;
    data['url'] = fileUrl;
    data['type'] = type;
    data['configurationId'] = configurationId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
